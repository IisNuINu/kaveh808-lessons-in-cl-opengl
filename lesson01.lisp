

(eval-when (:compile-toplevel :load-toplevel :execute)
   (if (eq (uiop:operating-system) :win)
       (progn
          (defparameter *d* (merge-pathnames "WORK/lisp/learn/pkg/opengl/"
                                             "D:/"))
          )
       (progn
          (defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/"
                                             (user-homedir-pathname)))))
   (load (merge-pathnames "draw-board01.lisp"  *d*)))

;;(trace load)
;;(trace read)
;;(trace probe-file)
;;(trace)
;;(untrace read)
;;(trace open)


#|
(run-db)
(with-win
  (gl:color 1 1 1)
  (gl:with-primitive :polygon
    (gl:vertex 0.05 0.05) 0
    (gl:vertex 0.95 0.05 0)
    (gl:vertex 0.95 0.95 0)
    (gl:vertex 0.05 0.95 0)))

|#
;;Сцена хранит список фигур(shape)
;;! работает!

;;(inspect *win*)

;;;;;; shape ====================================================================================
(defclass shape ()
  ())

(defmethod draw ((self shape))
  ;;subclass responsibility
  (format t "drawing abstract shape"))

;;если класс scene унаследовать от абстрактного shape то его можно было бы использовать как обычную shape
;;и помещать в другие scene, фактически это обычнй контейнер фигур.
;;;;;; scene  ====================================================================================
(defclass scene ()
  ((shapes :accessor shapes
	   :initarg  :shapes
	   :initform '())))

(defmethod add-shape ((self scene) (s shape))
  (push s (shapes self))
   s)

(defmethod clear-shapes ((self scene))
  (setf (shapes self) '()))

(defmethod draw ((self scene))
  (dolist (s (shapes self))
    (draw s)))

;; run graphics =====================================================================================

;; run function
(defparameter *scene* (make-instance 'scene))

;;остальные функции нам не нужны
;; вместо run у нас есть run-db(т.е run draw-board)


;; utils =====================================================================================

;; random float between a and b
(setf *random-state* (make-random-state t))
(defun rand2 ( a b)
  (if (= a b)
      a
      (let ((lo (min a b))
	    (hi (max a b)))
	(+ lo (random (coerce (- hi lo) 'float))))))

;; random float between -a and a
(defun rand1 (a)
  (rand2 (- a) a))

;;concatenate strings
(defun strcat (&rest strings)
  (apply #'concatenate 'string strings))

;;concatenate symbols
(defun symcat (&rest syms)
  (intern (apply #'concatenate 'string (mapcar #'symbol-name syms))))

;;(symcat 'alfa 'betta 'thetta);ALFABETTATHETTA

;; points =============================================================================================

;;; class for representing 2D points
(defclass point ()
  ((x :accessor x :initarg :x :initform 0.0)
   (y :accessor y :initarg :y :initform 0.0)))

;;setf with coerce
(defmethod (setf x) (val (self point))
  (setf (slot-value self 'x) (coerce val 'single-float)))

(defmethod (setf y) (val (self point))
  (setf (slot-value self 'y) (coerce val 'single-float)))

(defun p! (x y)
  (make-instance 'point :x (coerce x 'single-float)
			:y (coerce y 'single-float)))

(defmethod p+  ((p1 point) (p2 point))
  (p! (+ (x p1) (x p2))
      (+ (y p1) (y p2))))

#|
(defparameter p (p! 2 4))
p ;#<POINT {99BDA719}>
(type-of p) ;POINT
(class-of p);#<STANDARD-CLASS COMMON-LISP-USER::POINT>
(describe p);
#<POINT {99BDA719}>
  [standard-object]
Slots with :INSTANCE allocation:
  X                              = 2.0
  Y                              = 4.0
|#

(defmethod print-object ((self point) stream)
  (print-unreadable-object (self stream :type t)
    (format stream "[~a, ~a]" (x self) (y self))))
;;p #<POINT [2.0, 4.0]>

;; polygonal shape class ======================================================================
;; this shape defined by a list points
(defclass polygon-shape (shape)
  ((is-closed-shape?  :accessor is-closed-shape?
		      :initarg  :is-closed-shape?
		      :initform t)
   (points            :accessor points
		      :initarg  :points
		      :initform '())))

(defmethod add-point ((self polygon-shape) (p point))
  (push p (points self)))

(defmethod draw ((self polygon-shape))
  (gl:color 1.0 1.0 1.0)
  (gl:line-width 3.0)
  (if (is-closed-shape? self)
      (gl:begin :line-loop)
      (gl:begin :line-strip))
  (dolist (p (points self))
    (gl:vertex (x p) (y p) 0.0))
  (gl:end))

;;; square

(defun make-square-shape (length)
  (let ((v (/ length 2.0)))
    (make-instance 'polygon-shape
		   :points (list (p! v    v)
				 (p! v  (- v))
				 (p! (- v) (- v))
				 (p! (- v) v)))))

#|
*scene*
(defparameter *sq* (make-square-shape 1.0))
(run-db)
(add-shape *scene* *sq*)
(with-win
  (draw *scene*))
(with-win ;;нерисовать ничего пустая лямбда функция, хотя лучше установить её в nil
  )

;;не закрытый полигон, нет одного ребра
(setf (is-closed-shape? *sq*) nil)
(with-win
  (draw *scene*)) ;;блестяще!

(print (mapcar (lambda (x) (* x 2))
               '(1 2 3 4 5)))

(print (mapcar #'oddp
               '(1 2 3 4 5)))

|#

;; randomize shape points
(defmethod randomize-points ((self polygon-shape) (delta point))
  (setf (points self)
	(mapcar (lambda (p)
		  (let ((offset (p! (rand1 (x delta)) (rand1 (y delta)))))
		    (p+ p offset)))
		(points self))))

#|
(randomize-points *sq* (p! 0.1 0.1))
(with-win
  (draw *scene*))
;; очистить сцену
(clear-shapes *scene*)
(dolist (size '(.25 .5 .75 1.0))
   (add-shape *scene* (make-square-shape size)))
(with-win
  (draw *scene*))

;; рандомизировать позици точек фигур сцены
(dolist (shape (shapes *scene*))
   (randomize-points shape (p! 0.05 0.05)))
(with-win        ;;установить отображение сцены
  (draw *scene*))
(update *win*) ;;обновить отображение
(with-win ;;отменить отображение сцены
  )

|#

(defmacro with-redraw (&body body)
  `(prog1
       (progn ,@body)
     (update *win*)))

#|
(run-db)
(with-win
  (draw *scene*))
(with-redraw
    (clear-shapes *scene*))

(with-redraw
  (dolist (size '(.25 .5 .75 1.0))
     (add-shape *scene* (make-square-shape size))))

|#



