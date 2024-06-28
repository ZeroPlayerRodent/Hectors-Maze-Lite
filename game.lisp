(require :uiop)
(require :asdf)
(require "clx")
(load "sprites.lisp")

(defclass enemy ()
  (
    (x :initarg :x :initform 0 :accessor x)
    (y :initarg :y :initform 0 :accessor y)
    (wait :initarg :wait :initform 100 :accessor wait)
    (top :initarg :top :initform 20 :accessor top)
  )
)

(defmacro the-enemy ()
  '(elt enemies i)
)

(defvar tickrate 16)
(defvar last-tick 0)
(defvar tick-times 0)

(defvar load-time 0)

(defvar start-screen 1)

(defvar init-width 30)
(defvar init-height 30)

(defun reset-game ()

(setq spells 3)
(setq spell-display (slice (write-to-string spells)))

(setq died 0)
(setq score 0)

(setq width init-width)
(setq height init-height)

(setq enemies (list
(make-instance 'enemy :x 1 :y 1 :wait 100)
))

(setq foo (list (make-list width :initial-element 1)))
(setf foo (append foo (list (make-list width :initial-element 0)) ))

(setf (elt (elt foo 1) 0) 1)
(setf (elt (elt foo 1) (- width 1)) 1)

(setq bar '(1))

(dotimes (y (- height 2))
  (dotimes (x (- width 2))
    (if (= (random 4 (make-random-state t)) 0)
      (setf bar (append bar (list 1)))
      (progn
        (setf bar (append bar (list 0)))
        (when (and (= (random 25 (make-random-state t)) 0) (= (elt (elt foo y) x) 0))
          (setf enemies (append enemies (list (make-instance 'enemy :x x :y y :wait 100))))
        )
      )
    )
  )
  (setf bar (append bar (list 1)))
  (setf foo (append foo (list bar)))
  (setf bar (list 1))
)

(setf foo (append foo (list (make-list width :initial-element 0)) ))
(setf foo (append foo (list (make-list width :initial-element 1)) ))

(setf (elt (elt foo height) 0) 1)
(setf (elt (elt foo height) (- width 1)) 1)

(let ((x (+ (random (- (length (elt foo 0)) 2) (make-random-state t)) 1))(y (- (length foo) 2)))
  (loop
    (setf (elt (elt foo y) x) 0)
    (when (and (> x 2)(< x (- width 2)))
    (if (= (random 2 (make-random-state t)) 0)
      (if (= (random 2 (make-random-state t)) 0)
        (progn (setf x (+ x 1)) (setf (elt (elt foo y) x) 0))
        (progn (setf x (- x 1)) (setf (elt (elt foo y) x) 0))
      )
    )
    )
    (setf y (- y 1))
    (when (= y 1)(return))
  )
)

(setq player-x (truncate (/(length (elt foo 0)) 2)))
(setq player-y (- (length foo) 2))
(setq offset-x player-x)
(setq offset-y player-y)

(setq ghost-x (truncate (/ width 2)))
(setq ghost-y (truncate (/ height 2)))
(setq ghost-wait 50)
(setq ghost-top 50)
(setq ghost-inc 100)
(setq ghost-inc-top 100)
)

(defun tick ()
  (let ((i 0))
  (loop
  (setf (wait (the-enemy)) (- (wait (the-enemy)) 1))
  (when (= (wait (the-enemy)) 0)
    (let ((dir (random 4 (make-random-state t))))
      (when (= dir 0)(setf (y (the-enemy)) (- (y (the-enemy)) 1))
      (when (= (elt (elt foo (y (the-enemy))) (x (the-enemy))) 1) (setf (y (the-enemy)) (+ (y (the-enemy)) 1))))
      
      (when (= dir 1)(setf (x (the-enemy)) (- (x (the-enemy)) 1))
      (when (= (elt (elt foo (y (the-enemy))) (x (the-enemy))) 1) (setf (x (the-enemy)) (+ (x (the-enemy)) 1))))
      
      (when (= dir 2)(setf (y (the-enemy)) (+ (y (the-enemy)) 1))
      (when (= (elt (elt foo (y (the-enemy))) (x (the-enemy))) 1) (setf (y (the-enemy)) (- (y (the-enemy)) 1))))
      
      (when (= dir 3)(setf (x (the-enemy)) (+ (x (the-enemy)) 1))
      (when (= (elt (elt foo (y (the-enemy))) (x (the-enemy))) 1) (setf (x (the-enemy)) (- (x (the-enemy)) 1))))
    )
    (setf (wait (the-enemy)) (+(random (top (the-enemy)) (make-random-state t))20))
  )
  (when (and (= (x (the-enemy)) player-x)(= (y (the-enemy)) player-y))(setf died 1))

  (setf i (+ i 1))
  (when (>= i (length enemies))(return))
  )
  
  (setf ghost-wait (- ghost-wait 1))
  (setf ghost-inc (- ghost-inc 1))
  (when (= ghost-inc 0)
    (setf ghost-top (- ghost-top 1))
    (setf ghost-inc ghost-inc-top)
    (when (<= ghost-top 10)(setf ghost-top 10))
  )
  (when (= ghost-wait 0)
    (when (= died 0)(setf score (+ score 1)))
    (when (> ghost-x player-x) (setf ghost-x (- ghost-x 1)))
    (when (< ghost-x player-x) (setf ghost-x (+ ghost-x 1)))
    (when (> ghost-y player-y) (setf ghost-y (- ghost-y 1)))
    (when (< ghost-y player-y) (setf ghost-y (+ ghost-y 1)))
    (setf ghost-wait ghost-top)
  )
  (when (and (= ghost-x player-x)(= ghost-y player-y))(setf died 1))
  )
  (setf last-tick (+ last-tick tickrate))
)

(defmacro make-color (color)
  `(xlib:create-gcontext :drawable root-window :foreground ,color)
)

(defun stun-hector ()
  (when (> spells 0)
    (setf ghost-wait 500)
    (setf spells (- spells 1))
  )
)

(defun start (&optional (host ""))
  (let* ((display (xlib:open-display host))
	 (screen (first (xlib:display-roots display)))
	 (root-window (xlib:screen-root screen))
	 (black (make-color 0))
         (green (make-color 2120736))
         (yellow (make-color 16579688))
         (red (make-color 8656896))
         (gray (make-color 4210752))
         (white (make-color 16777215))
         (blue (make-color 5266624))
	 (my-window (xlib:create-window
		     :parent root-window
		     :x 0
		     :y 0
		     :width 640
		     :height 640
		     :background 0
		     :event-mask (xlib:make-event-mask :exposure
						       :button-press
                                                       :key-press
                                                       :key-release))))
(reset-game)
(setf load-time (get-internal-real-time))
(xlib:map-window my-window)

(loop

  (xlib:clear-area my-window :x 0 :y 0 :width 640 :height 640)

  (setf offset-y (-(* player-y 32)(* 32 10)))
  (setf offset-x (-(* player-x 32)(* 32 10)))

  (let ((i 0))
    (loop
      (let ((a 0))
        (loop
          (when (= (elt (elt foo i) a) 1)
            (when (and (and (>= (- (* a 32) offset-x) 0)(<= (- (* a 32) offset-x) 608))
                       (and (>= (- (* i 32) offset-y) 0)(<= (- (* i 32) offset-y) 608)))
              (xlib:draw-rectangle my-window gray (- (* a 32) offset-x) (- (* i 32) offset-y) 32 32 t)
            )
          )
          (setf a (+ a 1))
          (when (>= a (length (elt foo i)))(return))
        )
      )
      (setf i (+ i 1))
      (when (>= i (length foo))(return))
    )
  )

  (draw-sprite (- (* player-x 32) offset-x) (- (* player-y 32) offset-y) 3 blue ghoul)
    
  (when (and (and (>= (- (* ghost-x 32) offset-x) 0)(<= (- (* ghost-x 32) offset-x) 608))
             (and (>= (- (* ghost-y 32) offset-y) 0)(<= (- (* ghost-y 32) offset-y) 608)))
    (draw-sprite (- (* ghost-x 32) offset-x) (- (* ghost-y 32) offset-y) 3 green eyeball)
  )
  
  (let ((i 0))
  (loop
  (when (and (and (>= (- (* (x (the-enemy)) 32) offset-x) 0)(<= (- (* (x (the-enemy)) 32) offset-x) 640))
             (and (>= (- (* (y (the-enemy)) 32) offset-y) 0)(<= (- (* (y (the-enemy)) 32) offset-y) 640)))
    (draw-sprite (- (* (x (the-enemy)) 32) offset-x) (- (* (y (the-enemy)) 32) offset-y) 3 white skeleton)
  )
  (setf i (+ i 1))
  (when (>= i (length enemies))(return))
  )
  )
  
  (write-number 10 10 5 (slice (write-to-string score)) yellow)
  (write-number 10 45 5 spell-display yellow)

  (setf tick-times (floor (/ (- (- (get-internal-real-time) load-time) last-tick) tickrate)))
  
  (dotimes (int tick-times)
    (tick)
  )
  
  (xlib:display-finish-output display)
  
  (xlib:event-case (display :timeout 0.001)
    (:key-press (code)
      (when (equal code 25)
        (setf player-y (- player-y 1))
        (when (= (elt (elt foo player-y) player-x) 1)(setf player-y (+ player-y 1)))
      )
      (when (equal code 38)
        (setf player-x (- player-x 1))
        (when (= (elt (elt foo player-y) player-x) 1)(setf player-x (+ player-x 1)))
      )
      (when (equal code 39)
        (setf player-y (+ player-y 1))
        (when (= (elt (elt foo player-y) player-x) 1)(setf player-y (- player-y 1)))
      )
      (when (equal code 40)
        (setf player-x (+ player-x 1))
        (when (= (elt (elt foo player-y) player-x) 1)(setf player-x (- player-x 1)))
      )
      (when (equal code 45)
        (stun-hector)
        (setf spell-display (slice (write-to-string spells)))
      )
      t
    )
  )
  (when (= died 1)(return))
)
(xlib:destroy-window my-window)
(xlib:close-display display)
(terpri)
(format t (concatenate 'string "YOUR SCORE: " (write-to-string score)))
(terpri)
(finish-output)
)
)

(defun main ()
  (when (uiop:command-line-arguments)
    (when (equal "small" (elt (uiop:command-line-arguments) 0))
      (setf init-width 15)
      (setf init-height 15)
    )
    (when (equal "medium" (elt (uiop:command-line-arguments) 0))
      (setf init-width 30)
      (setf init-height 30)
    )
    (when (equal "large" (elt (uiop:command-line-arguments) 0))
      (setf init-width 60)
      (setf init-height 60)
    )
  )
  (format t "Loading...")
  (terpri)
  (terpri)
  (finish-output)
  (start)
)
