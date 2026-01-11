% facts
grade(alice, "A").
grade(brian, "B").
grade(carrie, "C").
grade(david, "A").
grade(jerry, "F").
grade(erica, "B").
grade(frank, "C").
grade(gina, "B").


% rules
good_grade(X) :- grade(X, "A"); grade(X, "B").
good_student(X) :- good_grade(X).
exist_fail :- grade(_, "F"), !.
