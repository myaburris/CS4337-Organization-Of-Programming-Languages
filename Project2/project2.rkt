; #lang racket is not needed because this file will be included from base.rkt

;; Example AI that always draw's cards.
(define (example-ai-1 err count last_play other_score pstate) (if err '() '(draw-card, ())))

;; Example AI that will only play a card if the count can be made with 1 card.
(define (example-ai-2 err count last_play other_score pstate) 
  (if err '() (example-ai-2-rec count (pstate->hand pstate))))
(define (example-ai-2-rec count hand)
    (cond [(null? hand) '(draw-card, ())]
		[(eq? (face (car hand)) 'K) (list (list (mkwild (car hand) count)) '())]
		[(= (value (car hand)) count) (list (list (car hand)) '())]
		[else (example-ai-2-rec count (cdr hand))]))

;; AI 1: get rid of most cards first
(define (project-ai-1 err count last_play other_score pstate))
  (if err '() (all-combinations (pstate->hand pstate) count))

;finds all possible combinations in its hand
(define (all-combinations hand count)
  (playable-combo ((combinations hand) count)))

;finds all combinations that equal the count value
(define (playable-combo combo-list count)
  (cond [(null? (filter-map (= (calc-play-value combo) count) combo-list)) '(draw-card, ())]
        [**condition 2- if only 1 combo**]
        [**condition 3- if more than one combo**]))

;calculates the play value of a combinaiton of cards
(define (calc-play-value combo)
  (if (null? combo) 0 (split-add combo)))

;prelim-sum: the face cards total value and pairs total value; prelim-sum made so that it can be used as a value when dealing with kings
(define prelim-sum 0)

;splits combo into three types: normal cards, pairable cards, kings and adds the three values together
(define (split-add combo)
  (+ (set! prelim-sum (+ (normal-sum (filter-map (split-add-normal card) combo)) (pairable-sum (filter-map (can-pair? card) combo) combo))) (kings-sum () () () ())))

;looks for normal cards and filters them out from the combination
(define (split-add-normal card)
  (if (or (eqv? (face card) 10) (eqv? (face card) 'J) (eqv? (face card) 'Q) (eqv? (face card) 'K)) #f #t))

;adds normal card's values together
(define (normal-sum normal-filtered-list)
  (if (null? normal-filtered-list) 0 (+ (value (car normal-filtered-list)) (normal-sum (cdr normal-filtered-list)))))

;adds pairable card's values together
(define (pairable-sum pair-filtered-list combo)
  (cond [(null? pair-filtered-list) 0]
        [(= (length pair-filtered-list) 1) 10]
        [else (- (normal-sum pair-filtered-list) (pairs-sum (combinations (pair-filtered-list) 2) combo))]))

;pairs pariable cards together and calculates their total value
(define (pairs-sum pairs-list combo)
  (cond [(null? pairs-list) 0]
        [(eqv? (same-face? (caar pairs-list) (cadr pairs-list)) #t) (+ 10 (remove-indiv-cards combo pairs-list))]
        [else (+ 0 (pairs-sum (cdr pairs-list) combo))]))

;removes individual cards in pair and replaces it the pair format in combo
(define (remove-indiv-cards combo pairs-list)
  (remove (caar pairs-list) (combo) (compare-card pairs-list combo))
  (remove (caar pairs-list) (combo) (compare-card pairs-list combo))
  (append combo (car pairs-list))
  (pairs-sum (cdr pairs-list)))

;compares if two cards have the same face and suit
(define (compare-card pairs-list combo)
  (if (and (same-face? (face (caar pairs-list)) (face (car combo))) (same-suit? (suit (caar pairs-list)) (suit (car combo)))) #t #f))

;
(define (kings-sum kings-list prelim-sum count combo)
  (cond [(null? kings-list) 0]
        [(= (length kings-list) 1) (- count prelim-sum)]
        [else (**make kings**)]))

;deals with multiple kings
(define (multi-kings count prelim-sum kings-list combo)
  (insert-king ((- (- count prelim-sum)) (- (length kings-list) 1)) combo (car kings-list)))

;add values to the king cards and add them into the combo
(define (insert-king value combo card)
  (remove (card) (combo) (**comparison proc**))
  (mkwild (card value)))


; Testing your first AI
(play-game user-interface project-ai-1)

; Testing your second AI
; (play-game user-interface project-ai-2)

; Make them Play each other
; (play-game project-ai-1 project-ai-2)
