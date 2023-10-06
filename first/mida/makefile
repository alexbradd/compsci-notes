all: notes.pdf es.pdf

notes.pdf: $(wildcard img/notes/*.png)
	img_to_pdf.sh ./img/notes ./img/notes/bookmarks.ps notes.pdf

es.pdf: $(wildcard img/es/*.png)
	img_to_pdf.sh ./img/es ./img/es/bookmarks.ps es.pdf

clean:
	rm notes.pdf
	rm es.pdf
