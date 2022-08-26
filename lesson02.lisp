
(eval-when (:compile-toplevel :load-toplevel :execute)
   (if (eq (uiop:operating-system) :win)
       (progn
          (defparameter *d* (merge-pathnames "WORK/lisp/learn/pkg/opengl/"
                                             "D:/"))
          )
       (progn
          (defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/"
                                             (user-homedir-pathname)))))
   (load (merge-pathnames "lesson01.lisp"  *d*)))

;;что бы работал данный урок надо загрузить сначала lesson01.lisp

(defmacro with-clear-and-redraw (&body body)
  `(progn
     (clear-shapes *scene*)
     (prog1
	 (progn ,@body)
       (update *win*))))

;;построение окружности из фигуры полигона
(defun make-circle-shape (diameter &optional (num-points 64))
  (let ((radius (/ diameter 2.0))
	(angle-delta  (/ (* 2 pi) num-points))
	(shape        (make-instance 'polygon-shape)))
    (dotimes (i num-points)
      (let ((angle (* i angle-delta)))
	(add-point shape (p! (* (sin angle) radius)
			     (* (cos angle) radius)))))
    shape))


#||
(run-db)
(with-clear-and-redraw
   (add-shape *scene* (make-circle-shape 1.0  64))
   (add-shape *scene* (make-circle-shape 0.75 32))
   (add-shape *scene* (make-circle-shape 0.5  16))
   (add-shape *scene* (make-circle-shape 0.25 8)))
(inspect *scene*)
(with-win  ;;отображает сцену
  (draw *scene*))
(with-win) ;;прекращает отображать сцену.

(with-redraw
   (dolist (shape (shapes *scene*))
       (randomize-points shape (p! 0.05 0.05))))
||#

;;можно использовать функцию make-circle-shape для построения функций
;; создающих регулярные многоугольники

(defmacro def-polygon-shape (name num)
  `(defun ,(symcat 'make- name '-shape) (size)
     (make-circle-shape size ,num)))

(def-polygon-shape eql-tri 3)  ;make-eql-tri-shape
(def-polygon-shape diamond 4)  ;make-diamond-shape
(def-polygon-shape pentagon 5)  ;make-pentagon-shape
(def-polygon-shape hexagon  6)  ;make-hexagon-shape
(def-polygon-shape heptagon 7)  ;make-heptagon-shape
(def-polygon-shape octagon  8)  ;make-octagon-shape

#||
(with-clear-and-redraw
  (add-shape *scene* (make-eql-tri-shape  1.0))
  (add-shape *scene* (make-diamond-shape  1.0))
  (add-shape *scene* (make-pentagon-shape 1.0))
  (add-shape *scene* (make-hexagon-shape  1.0))
  (add-shape *scene* (make-heptagon-shape 1.0))
  (add-shape *scene* (make-octagon-shape  1.0))
  )

(with-clear-and-redraw
  (add-shape *scene* (make-eql-tri-shape  0.4))
  (add-shape *scene* (make-diamond-shape  0.6))
  (add-shape *scene* (make-pentagon-shape 0.8))
  (add-shape *scene* (make-hexagon-shape  1.0))
  (add-shape *scene* (make-heptagon-shape 1.2))
  (add-shape *scene* (make-octagon-shape  1.4))
  )

;;добавим рандомизацию всех точек фигур
(with-redraw
  (dolist (shape (shapes *scene*))
     (randomize-points shape (p! 0.025 0.025))))
||#

#||
(defun make-sine-curve-shape (&optional (num-segments 64))
  (let ((angle-delta (/ (* 2 pi) num-segments))
	(shape (make-instance 'polygon-shape :is-closed-shape? nil)))
    (dotimes (i (1+ num-segments))
      (let ((angle (* i angle-delta)))
	(add-point shape (p! (/ angle (* 2 pi)) (sin angle)))))
    shape))
||#

#||
(with-clear-and-redraw
  (add-shape *scene* (make-sine-curve-shape)))
(with-clear-and-redraw
  (add-shape *scene* (make-sine-curve-shape 16)))
(with-clear-and-redraw
  )

||#

(defmacro def-trig-curve-shape (func-name func)
  `(defun ,(symcat 'make- func-name '-curve-shape) (&optional (num-points 64))
     (let ((angle-delta (/ (* 2 pi) (- num-points 1)))
	   (shape (make-instance 'polygon-shape :is-closed-shape? nil)))
       (dotimes (i  num-points)
	 (let ((angle (* i angle-delta)))
	   (add-point shape (p! (/ angle (* 2 pi)) (,func angle)))))
       shape)))

;;создадим функции создающие фигуру синуса и косинуса
(def-trig-curve-shape sine sin)   ;MAKE-SINE-CURVE-SHAPE
(def-trig-curve-shape cosine cos) ;MAKE-COSINE-CURVE-SHAPE

#||
(with-clear-and-redraw
  )
(with-clear-and-redraw
  (add-shape *scene* (make-sine-curve-shape)))

(with-clear-and-redraw
   (add-shape *scene* (make-cosine-curve-shape)))
||#

;; спираль
;; реализуем спираль на базе функции рисования круга
;;посмотрим на эту функцию и создадим функцию спирали

#||
(defun make-circle-shape (diameter &optional (num-points 64))
  (let ((radius (/ diameter 2.0))
	(angle-delta  (/ (* 2 pi) num-points))
	(shape        (make-instance 'polygon-shape)))
    (dotimes (i num-points)
      (let ((angle (* i angle-delta)))
	(add-point shape (p! (* (sin angle) radius)
			     (* (cos angle) radius)))))
    shape))
||#

(defun make-spiral-shape (diameter &optional (num-points 64) (num-loops 1.0))
  (let ((radius-delta (/ (/ diameter 2.0) (1- num-points)))
	(angle-delta  (/ (* 2 pi) num-points))
	(shape        (make-instance 'polygon-shape :is-closed-shape? nil)))
    (dotimes (i num-points)
      (let ((radius (* i radius-delta))
	    (angle  (* i angle-delta num-loops)))
	(add-point shape (p! (* (sin angle) radius)
			     (* (cos angle) radius)))))
    shape))

#|| рисуем разные спирали
(with-clear-and-redraw
  (add-shape *scene* (make-spiral-shape 1.5)))
(with-clear-and-redraw
  (add-shape *scene* (make-spiral-shape 1.5 256 2)))
(with-clear-and-redraw
  (add-shape *scene* (make-spiral-shape 1.5 256 4)))

(with-redraw
  (dolist (shape (shapes *scene*))
    (randomize-points shape (p! 0.01 0.01))))

||#





