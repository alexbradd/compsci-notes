-- User(_SSN, Name, Email, Type)
-- Reservation(_UserSSN, RoomCode, Date, StartTime, EndTime)
-- Room(_RoomID, Type, CostPerHour)
-- 1. Write a trigger that prevents the reservation of already booked rooms
-- 2. Enrich the schema to track the number of hours that have been reserved but
--    not used by users. Write a trigger that sets the 'unreliable' type to any
--    user that toatizes 50 hours of unused reservations
create trigger NotBook
before insert on Reservation
for each row
when exists (select *
             from Rservation
             where RoomCode = new.RoomCode and
               Date = new.Data and
               StartTime < new.EndTime and EndTime > new.StartTime)
  rollback;

-- Usage(_UserSSN, RoomCode, Date, StartTime, EndTime)
-- User(..., WastedHours)
create trigger UpdateWastedHours
after insert on Usage
for each row
declare X integer; -- variable declaration
when 0 < (select EndTime - StartTime - (new.EndTime - new.StartTime) into X
          from Reservation
          where RoomCode = new.RoomCode and Date = new.Date and
            StartTime <= newStartTime and EndTime >= new.EndTime)
  update User
  set WastedHours = WastedHours + X
  where SSN = new.UserSSN;

create trigger UpdateType
after update of WastedHours on User
for each row
when old.WastedHours < 50 and new.WastedHours >= 50
  update User
  set Type = "Unreliable"
  where SSN = old.SSN;

--------------------------------------------------------------------------------
-- Pace(_PageID, Content, IsHome, MinDistanceFromHome)
-- Hyperlink(_FromPageId, _ToPageId)
-- Design a set of trigger that keep MinDistance correctly updated when:
-- 1. The homepage is created
-- 2. a new hyperlink is added
create trigger InsertHomePage
before insert on Page
for each row
when (new.IsHome) = "y"
new.MinDistanceFromHome = 0;

create trigger InsertHyperlink
after insert on Hyperlink
for each row
when (select MinDistanceFromHome from Page where PageId = new.FromPageId) + 1 <
     (select MinDistanceFromHome from Page where PageId = new.toPageId)
  update Page
  set MinDistanceFromHome = 1 +
    (select MinDistanceFromHome
      from Page
      where PageId = new.FromPageId)
  where PageId = new.ToPageId;

create trigger UpdateDistance
after update of MinDistanceFromHome on Page
for each row
when exists (select *
              from page as P join Hyperlink as H on H.ToPageId = P.PageId
              where H.FromPageId = new.PageId and
                P.MinDistanceFromHome > new.MinDistanceFromHome + 1)
  update Page
  set MinDistanceFromHome = new.MinDistanceFromHome + 1
  where PageId in (select P.PageId
                    from Page as P join Hyperlink as H oin H.ToPageId = P.PageId
                    where H.FromPageId = new.PageId and
                      P.MinDistanceFromHome > new.MinDistanceFromHome + 1);

--------------------------------------------------------------------------------
-- Student(_StudentId, LastName, Name, Country)
-- Course(_CourseId, Name, Professor)
-- Exam(_CourseId, ExamDate, ClassRoom, Time, PubblicationDate, IsClosed)
-- Grades(_CourseId, StudentId, ExamDate, Grade, IsRejected)
-- StatsByDate(_ExamDate, TotalNumberOfStudents)
-- StatsByExam(CourseId, ExamDate, AveragePublishedGrade, averageFinalGrade)
-- Write a set of triggers that allow keeping the following statistics updated:
-- 1. For each date, the toal number of students who did the exam
-- 2. For each exam, the average grades initially published by the professor and
--    the average final grade of the exam when it is closed
-- Only the last 10 statistics for each course are kept in the table

-- row version
create trigger StatisticByDate
after insert on Grades
for each row
begin
  if (exists select * from StatsByDate where ExamDate = new.ExamDate)
    update StatsByDate set TotalNumberOfStudets = TotalNumberOfStudents + 1
      where ExamDate = new.ExamDate;
  else
    insert into StatsByDate valeus (new.ExamDate, 1);
end;

-- statement version
create trigger StatisticByDate
after insert on Grades
for each statement
referencing new table as InsertdGrades
begin
  declare newDate date;
  select distinct ExamDate into newDate from InsertedGrades;

  if (not exists select * from StatsByDate where ExamDate = new.ExamDate)
    insert into StatsByDate values (new.ExamDate, (select count(*) from InsertedGrades));
  else
    update StatsByDate set TotalNumberOfStudets = (select count(*) from InsertedGrades)
      where ExamDate = newDate;
end;

create trigger AveragePublishedExams
after insert on Grades
for each statement
referencing new table as InsertedGrades
  insert into StatsByExam
    select CourseId, Examdate, Average(Grade), 0.0
    from InsertedGrades
    group by CourseId, ExamDate;

create trigger FinalAverage
after update of closed on exam
for each row
when old.closed="N" and new.Closed = "Y"
  update StatsByExam
  set AverageFinalGrade = (select Average(grade)
                            from Grades
                            where CourseId = new.CourseId and
                              examDate = new.ExamDate and
                              Rejected<>"N")
  where CourseId = new.CourseId and ExamDate = new.ExamDate;

create trigger Last10
after isnert on StatsByExam
for each row
when (10 < select count(*)
            from StatsByExam
            where CourseId = new.CourseId)
  delete from StatsByExam
  where CourseId = new.CourseId and
    Examdate = (select min(ExamDate)
                  from StatsByExam
                  where CourseId = new.CourseId);
