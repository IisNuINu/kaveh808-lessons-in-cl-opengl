;;(defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/" (user-homedir-pathname)))
;;(load (merge-pathnames "lesson02.lisp"  *d*))
(eval-when (:compile-toplevel :load-toplevel :execute)
   (if (eq (uiop:operating-system) :win)
       (progn
          (defparameter *d* (merge-pathnames "WORK/lisp/learn/pkg/opengl/"
                                             "D:/"))
          )
       (progn
          (defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/"
                                             (user-homedir-pathname)))))
   (load (merge-pathnames "lesson02.lisp"  *d*)))


;; utils =============================================================

;; linear interpolation (линейная интерполяция) 0.0<f<1.0 [lo, hi] 
(defun lerp (f lo hi)
  (+ lo (* f (- hi lo))))

;;; point ============================================================
;; умножить координаты точек друг на друга
(defmethod p* ((p1 point) (p2 point))
  (p! (* (x p1) (x p2))
      (* (y p1) (y p2))))
;; умножить координаты точки на число
(defmethod p* ((p1 point) (s number))
  (p! (* (x p1) s)
      (* (y p1) s)))

;;магнитуда (длина) точки
(defmethod p-mag (p)
  (sqrt (+ (* (x p) (x p))
	   (* (y p) (y p)))))
;; расстояние между точками
(defmethod p-dist (p1 p2)
  (let ((dx (- (x p2) (x p1)))
	(dy (- (y p2) (y p1))))
    (sqrt (+ (* dx dx)
	     (* dy dy)))))

;;;; transform  ======================================================
(defclass transform ()
  ((translate :accessor translate
	      :initarg :translate
	      :initform (p! 0.0 0.0))
   (rotate    :accessor rotate
	      :initarg :rotate
	      :initform 0.0)
   (scale     :accessor scale
	      :initarg  :scale
	      :initform (p! 1.0 1.0))))

;;мы должны быть уверены что rotate является single-float
(defmethod (setf rotate) ((self transform) val)
  (setf (slot-value self 'rotate) (coerce val 'single-float)))

(defmethod translate-by ((self transform) (p point))
   (setf (translate self) (p+ (translate self) p)))

(defmethod rotate-by ((self transform) (r number))
   (setf (rotate self) (+ (rotate self) r)))

(defmethod scale-by ((self transform) (p point))
   (setf (scale self) (p* (scale self) p)))

(defmethod scale-by ((self transform) (s number))
   (setf (scale self) (p* (scale self) s)))

(defmethod reset-transform ((self transform))
   (setf (translate self) (p! 0.0 0.0))
   (setf (rotate    self) 0.0)
   (setf (scale     self) (p! 1.0 1.0)))

#||
(defmethod print-object ((self transform) stream)
   (print-unreadable-object (self stream :type t :identity nil)
      (format stream ":TRANSLATE ~a, :ROTATE ~a, :SCALE ~a"
              (translate self) (rotate self) (scale self))))
||#
(defmethod print-object ((self transform) stream)
   (print-unreadable-object (self stream :type t :identity nil)
      (format stream ":TRANSLATE [~a,~a], :ROTATE ~a, :SCALE [~a,~a]"
              (x  (translate self)) (y  (translate self))(rotate self)
              (x  (scale self)) (y  (scale self)))))

;; shape enhancement =============================================================

#||
;;посмотрим предыдущее определение класса фигур shape
(defparameter *sh* (make-instance 'polygon-shape))
(inspect *sh*)
||#

;;расширяем класс фигур, трансформацией фигуры.
(defclass shape ()
  ((transform :accessor transform
              :initarg :transform
              :initform (make-instance 'transform))))

;;(inspect *sh*)
;; utility method for transforming shapes
(defmethod translate-by ((self shape) (p point))
   (translate-by (transform self) p)
   self)

(defmethod rotate-by    ((self shape) (r number))
   (rotate-by    (transform self) r)
   self)

(defmethod scale-by     ((self shape) (p point))
   (scale-by     (transform self) p)
   self)

(defmethod scale-by     ((self shape) (s number))
   (scale-by      (transform self) s)
   self)

(defmethod reset-transform ((self shape))
   (reset-transform (transform self))
   self)

;;определим комбинацию методов :before и :after для метода draw объекта shape
(defmethod draw :before ((self shape))
   (let ((xform (transform self)))
      (gl:push-matrix)
      (gl:translate (x (translate xform))
                    (y (translate xform))
                    0.0)
      (gl:rotate    (rotate xform) 0.0 0.0 1.0)
      (gl:scale     (x (scale xform))
                    (y (scale xform))
                    1.0)))

(defmethod draw :after ((self shape))
   (gl:pop-matrix))

;;макрос для выполнения функции над всеми фигурами сцены
(defmacro for-scene-shapes (func)
   `(mapcar ,func (shapes *scene*)))


#||
(defparameter *square-1* (make-square-shape 1.0))
(run-db)
(with-win
   (draw *scene*))
(with-clear-and-redraw
   (add-shape *scene* *square-1*))
;;переместим фигуру
(with-redraw
   (translate-by *square-1* (p! 0.05 0.01)))
(with-redraw
   (rotate-by *square-1* -1.0))
(with-redraw
   (scale-by *square-1* (p! 0.9 1.2)))

(with-redraw
   (reset-transform *square-1*))
||#

#||
комбинация вызова методов
SHAPE DRAW :BEFORE
  POLYGON-SHAPE DRAW
SHAPE DRAW :AFTER

а если определить методы before и after
 то будет так:
POLYGON-SHAPE DRAW :BEFORE
   SHAPE DRAW :BEFORE
       POLYGON-SHAPE DRAW
   SHAPE DRAW :AFTER
POLYGON-SHAPE DRAW :AFTER

||#

#||
(with-clear-and-redraw
   (dotimes (i 10)
      (let* ((factor (/ i 9.0))
             (hex    (make-hexagon-shape 1.0))
             (scale (lerp factor 0.1 1.5)))
         (format t "i: ~a, factor: ~a, scale[0.1-1.5]: ~a~%" i factor scale)
         (scale-by   hex scale)
         (rotate-by  hex (lerp factor 0 90))
         (add-shape  *scene* hex))))

;;создадим строку из фигур.
(with-clear-and-redraw
   (dotimes (i 10)
      (let* ((factor (/ i 9.0))
             (hex    (make-hexagon-shape 0.2)))
         (translate-by  hex (p! (lerp factor -0.9 0.9) 0))
         (add-shape  *scene* hex))))

;случайное перемещение по y
(with-redraw
   (for-scene-shapes
    (lambda (s) (translate-by  s (p! 0.0 (rand1 0.1)))))
   nil)
(inspect *scene*) 
;;случайные повороты фигур
(with-redraw
   (for-scene-shapes
    (lambda (s) (rotate-by  s (rand1 10.0))))
   nil)
(with-redraw
   (for-scene-shapes
    (lambda (s) (scale-by  s (rand2 0.8 1.2))))
   nil)

(with-redraw
   (for-scene-shapes #'reset-transform))

(with-clear-and-redraw)

||#





