%Included libraries
:- use_module(library(apply)).
:- use_module(library(lists)).

%Example AI that simply draws cards
% example_ai_1(game_state(no_error,_,_,_,_), play(drawcard,empty)).
% 
% 
%Example AI that will only play a card if the count can be made with 1 card.
% example_ai_2(game_state(no_error,Count,_,_,PState), play(Play,empty)) :-
%   pstate(hand,PState,Hand), example_ai_2_rec(Count,Hand,Play).
% 
% example_ai_2_rec(_,[],drawcard).
% example_ai_2_rec(Count,[Card|_],[wild(Card,Count)]) :- face(Card, k).
% example_ai_2_rec(Count,[Card|_],[Card]) :- value(Card,Count).
% example_ai_2_rec(Count,[Card|Hand],Play) :- value(Card,V), V\=Count, example_ai_2_rec(Count,Hand,Play).

%%DEALING WITH PAIRS
head([X|_], X).
tail([_|X], X).

partition_pairs(TenPile, JPile, QPile, Pile, Cards, FinalTenPile, FinalJPile, FinalQPile, FinalPile) :-
  length(Cards, Length),
  (Length =:= 0 ->
    FinalTenPile = TenPile,
    FinalJPile = JPile,
    FinalQPile = QPile,
    FinalPile = Pile,
    !
  ;Length > 0 ->
    head(Cards, Head),
    face(Head, Face),
    (   Face = 10 ->
            NewTenPile = [Head|TenPile],
            tail(Cards, Tail),
            partition_pairs(NewTenPile, JPile, QPile, Pile, Tail, FinalTenPile, FinalJPile, FinalQPile, FinalPile)
    ;   Face = j ->
            tail(Cards, Tail),
            NewJPile = [Head|JPile],
            partition_pairs(TenPile, NewJPile, QPile, Pile, Tail, FinalTenPile, FinalJPile, FinalQPile, FinalPile)
    ;   Face = q ->
            tail(Cards, Tail),
            NewQPile = [Head|QPile],
            partition_pairs(TenPile, JPile, NewQPile, Pile, Tail, FinalTenPile, FinalJPile, FinalQPile, FinalPile)
    ;   tail(Cards, Tail),
        NewPile = [Head|Pile],
        partition_pairs(TenPile, JPile, QPile, NewPile, Tail, FinalTenPile, FinalJPile, FinalQPile, FinalPile)
    )
   ).


pairs_combo(Pairs, Remaining, FinalPairsList) :-
  length(Remaining, RemainingLength),
  (RemainingLength < 2 ->
    length(Pairs, PairsLength),
    (RemainingLength =:= 0 ->
      (PairsLength =:= 0 ->
        FinalPairsList = [], !
      ;PairsLength =:= 1 ->
        FinalPairsList = Pairs, !
      )
    ;RemainingLength =:= 1 ->
      (PairsLength =:= 0 ->
        FinalPairsList = Remaining, !
      ;PairsLength =:= 1 ->
        FinalPairsList = [Remaining|Pairs], !
      )
    )
  ;RemainingLength >= 2 ->
    head(Remaining, Head),
    tail(Remaining, Tail),
    head(Tail, SecondElement),
    NewPair = pair(Head, SecondElement),
    NewPairsList = [NewPair|Pairs],
    tail(Tail, TailThirdElement),
    pairs_combo(NewPairsList, TailThirdElement, FinalPairsList)
  ).
  
handle_pairs(Hand, PairHand) :-
  partition_pairs([], [], [], [], Hand, FinalTenPile, FinalJPile, FinalQPile, FinalPile),
  pairs_combo([], FinalTenPile, FinalTensList),
  pairs_combo([], FinalJPile, FinalJList),
  pairs_combo([], FinalQPile, FinalQList),
  TensAndPile = [FinalTensList|FinalPile],
  JAndQ = [FinalJList|FinalQList],
  flatten(TensAndPile, NewTensAndPile),
  flatten(JAndQ, NewJAndQ),
  Test = [NewJAndQ|NewTensAndPile],
  flatten(Test, PairHand).

%%DEALING WITH KINGS
king(card(_, k)).

set_kings_one_rec(Rest, SetKingsList, FinalKings) :-
  length(Rest, Length),
  (Length =:= 0 ->
    FinalKings = SetKingsList
  ;Length > 0 ->
    head(Rest, Head),
    SetKing = wild(Head, 1),
    List = [SetKing|SetKingsList],
    tail(Rest, Tail),
    set_kings_one_rec(Tail, List, FinalKings)
  ).

handle_kings(Count, Cards, KingHand) :-
  partition(king, Cards, Kings, NonKings),
  length(Kings, Length),
  (Length = 0 ->
    KingHand = NonKings
  ;Length > 0 ->
    maplist(play_value, NonKings, Values),
    sum_list(Values, Sum),
    ExtraKings is Length - 1,
    Value is Count - Sum - ExtraKings,
    KingValue is max(1, Value),
    head(Kings, Head),
    NewKing = wild(Head, KingValue),
    NewKingHand = NewKing,
    (ExtraKings =< 0 ->
      KingOnlyHand = NewKingHand
    ;ExtraKings > 0 ->
      tail(Kings, Tail),
      set_kings_one_rec(Tail, [], SetRestKings),
      KingOnlyHand = [SetRestKings|NewKingHand]
    ),
    KingHand = [KingOnlyHand|NonKings]
  ).

handle_kings_rec(Count, NonEmptyCombos, KingHand, List, ValueSetCombos) :-
  length(NonEmptyCombos, Length),
  (Length =:= 0 ->
    ValueSetCombos = List
  ;Length > 0 ->
    head(NonEmptyCombos, Head),
    handle_kings(Count, Head, KingHand),
    NewList = [KingHand|List],
    tail(NonEmptyCombos, Tail),
    handle_kings_rec(Count, Tail, _KingHand, NewList, ValueSetCombos)
  ).

%%FINDING ALL VALID COMBOS THAT MAKE THE COUNT
valid_plays(Count, ValueSetCombos, List, PossiblePlays) :-
  length(ValueSetCombos, Length),
  (Length =:= 0 ->
    PossiblePlays = List
  ;Length > 0 ->
    head(ValueSetCombos, Head),
    maplist(play_value, Head, CardValues),
    sum_list(CardValues, ListValue),
    (Count =:= ListValue ->
      NewList = [Head|List],
      tail(ValueSetCombos, Tail),
      valid_plays(Count, Tail, NewList, PossiblePlays)
    ;Count > ListValue ->
      tail(ValueSetCombos, Tail),
      valid_plays(Count, Tail, List, PossiblePlays)
    ;Count < ListValue ->
      tail(ValueSetCombos, Tail),
      valid_plays(Count, Tail, List, PossiblePlays)
    )
  ).

%%FINDING A VALID PLAY WITH THE MOST CARDS
wild(wild(_, _)).

most_cards(PossiblePlays, Max, List, MaxCardsPlays) :-
  length(PossiblePlays, PlayLength),
  (PlayLength =:= 0 ->
    %flatten(List, MaxCardsPlays)
    MaxCardsPlays = List
  ;PlayLength > 0 ->
    head(PossiblePlays, Head),
    length(Head, Length),
    (Length < Max ->
      tail(PossiblePlays, Tail),
      most_cards(Tail, Max, List, MaxCardsPlays)
    ;Length =:= Max ->
      NewList = [Head|List],
      tail(PossiblePlays, Tail),
      most_cards(Tail, Max, NewList, MaxCardsPlays)
    ;Length > Max ->
      NewMax = Length,
      NewList = [Head],
      tail(PossiblePlays, Tail),
      most_cards(Tail, NewMax, NewList, MaxCardsPlays)
    )
  ).
  
least_kings(Combos, Min, List, FinalCombos) :-
  length(Combos, Length),
  (Length =:= 0 ->
    FinalCombos = List
  ;Length > 0 ->
    head(Combos, Head),
    partition(wild, Combos, Kings, _NonKings),
    length(Kings, NumKings),
    (NumKings > Min ->
      tail(Combos, Tail),
      least_kings(Tail, Min, List, FinalCombos)
    ;NumKings =:= Min ->
      NewList = [Head, List],
      tail(Combos, Tail),
      least_kings(Tail, Min, NewList, FinalCombos)
    ;NumKings < Min ->
      NewMin = NumKings,
      NewList = [Head],
      tail(Combos, Tail),
      least_kings(Tail, NewMin, NewList, FinalCombos)
    )
  ).

%%AI 1
empty([]).

count_sublists(List, Count) :-
  include(is_list, List, Sublists),
  length(Sublists, Count).

project_ai_1(game_state(no_error, Count, _, _, PState), play(Play, empty)) :-
  pstate(hand, PState, Hand),
  write(Hand),
  handle_pairs(Hand, PairHand),
  combinations(PairHand, Combos),
  exclude(empty, Combos, NonEmptyCombos),
  handle_kings_rec(Count, NonEmptyCombos, _KingHand, [], ValueSetCombos),
  valid_plays(Count, ValueSetCombos, [], PossiblePlays),
  length(PossiblePlays, Length),
  write(PossiblePlays),
  (Length =:= 0 ->
    Play = drawcard
  ;Length =:= 1 ->
    head(PossiblePlays, Head),
    Play = Head
  ;Length > 1 ->
    most_cards(PossiblePlays, 0, [], MaxCardsPlays),
    count_sublists(MaxCardsPlays, PlayLength),
    (PlayLength =:= 1 ->
      flatten(MaxCardsPlays, Play) %Play = MaxCardsPlays
    ;PlayLength > 1 ->
      least_kings(MaxCardsPlays, 100, [], FinalChoicePlays),
      write(FinalChoicePlays),
      head(FinalChoicePlays, Head),
      flatten(Head, Play)
    )
  ).
  
%Test Your code
player1(GameState, Play) :- user_interface(GameState,Play).
player2(GameState, Play) :- project_ai_1(GameState,Play).


%player1(GameState, Play) :- user_interface(GameState,Play).
%player2(GameState, Play) :- project_ai_2(GameState,Play).

%player2(GameState, Play) :- project_ai_1(GameState,Play).
%player2(GameState, Play) :- project_ai_2(GameState,Play).


%player1(GameState, Play) :- example_ai_1(GameState,Play).
%player2(GameState, Play) :- example_ai_2(GameState,Play).
