-module('ex221221').
-export([pmap/2, execute/3,
         pfilter/2, check/3,
         parfold/3, partition/2, parthelp/6, dofold/3,
         master/1, listlink/2, master_loop/2,
         testMap/0, testFilter/0]).

% ------------
% Parallel map
% ------------
pmap(F, L) ->
  Ps = [spawn(?MODULE, execute, [F, X, self()]) || X <- L],
  [receive
     {Pid, X} -> X
  end || Pid <- Ps].

execute(F, X, Pid) ->
  Pid ! {self(), F(X)}.

testMap() ->
  pmap(fun (X) -> X+X end, [1,2,3,4]).

% ---------------
% Parallel filter
% ---------------
pfilter(P, L) ->
  Ps = [spawn(?MODULE, check, [P, X, self()]) || X <- L],
  lists:foldl(fun (F, Vo) ->
                  receive
                    {F, true,  X} -> Vo ++ [X];
                    {F, false, _} -> Vo
                  end
              end, [], Ps).

check(P, X, Pid) ->
  Pid ! {self(), P(X), X}.

testFilter() ->
  pfilter(fun (X) -> X > 2 end, [1,2,3,4]).

% -------------
% Parallel fold
% -------------
parfold(F, L, N) ->
  Ls = partition(L, N),
  Ps = [spawn(?MODULE, dofold, [self(), F, X]) || X <- Ls],
  [R|Rs] = [receive
              {P, V} -> V
            end || P <- Ps],
  lists:foldl(F, R, Rs).

partition(L, N) ->
  M = length(L),
  Chunk = M div N,
  End = M - Chunk * (N - 1),
  parthelp(L, N, 1, Chunk, End, []).

parthelp(L, 1, P, _, E, Res) -> Res ++ [lists:sublist(L, P, E)];
parthelp(L, N, P, C, E, Res) ->
  R = lists:sublist(L, P, C),
  parthelp(L, N - 1, P + C, C, E, Res ++ [R]).

dofold(Pid, F, [X|Xs]) ->
  Pid ! {self(), lists:foldl(F, X, Xs)}.

% --------------
% Master process
% --------------
master(Fs) ->
  process_flag(trap_exit, true),
  Workers = listlink(Fs, #{}),
  master_loop(Workers, length(Fs)).

listlink([], M) -> M;
listlink([F|Fs], M) ->
  Pid = spawn_link(F),
  listlink(Fs, M#{Pid => F}).

master_loop(_, 0) -> ok;
master_loop(Ws, N) ->
  receive
    {'EXIT', Child, normal} -> % normal exit
      io:format("Child ~p exited normally, ~w remaining", [Child, N - 1]),
      master_loop(Ws, N - 1);
    {'EXIT', Child, _} -> % error
      io:format("Child ~p exited abnormally, restarting", [Child]),
      #{Child := F} = Ws,
      Pid = spawn_link(F),
      master_loop(Ws#{Pid => F}, N)
  end.
