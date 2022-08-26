;;(defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/" (user-homedir-pathname)))
;;(load (merge-pathnames "lesson03.lisp"  *d*))
(eval-when (:compile-toplevel :load-toplevel :execute)
   (if (eq (uiop:operating-system) :win)
       (progn
          (defparameter *d* (merge-pathnames "WORK/lisp/learn/pkg/opengl/"
                                             "D:/")))
       (progn
          (defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/"
                                             (user-homedir-pathname)))))
   (load (merge-pathnames "lesson03.lisp"  *d*)))


;; absolute transform operation  =============================================================
(defmethod translate-to ((self transform) (p point))
   (setf (translate self) p))

(defmethod rotate-to ((self transform) (r number))
   (setf (rotate self) r))

(defmethod scale-to ((self transform) (s number))
   (setf (scale self) (p! s s)))

(defmethod scale-to ((self transform) (p point))
   (setf (scale self) p))

;; utility method for transforming shapes
(defmethod translate-to ((self shape) (p point))
   (translate-to (transform self) p)
   self)

(defmethod rotate-to ((self shape) (r number))
   (rotate-to (transform self) r)
   self)

(defmethod scale-to ((self shape) (s number))
   (scale-to (transform self) s)
   self)

(defmethod scale-to ((self shape) (p point))
   (scale-to (transform self) p)
   self)

;;; marker-shape ================================================================
(defclass marker-shape (shape)
  ((size :accessor size
         :initarg :size
         :initform 0.1)))

(defmethod draw ((self marker-shape))
   (gl:color 1.0 0.0 0.0)
   (gl:line-width 3.0)
   (gl:begin :lines)
   (let ((s (/ (size self) 2.0)))
      (gl:vertex 0.0   s     0.0)
      (gl:vertex 0.0   (- s) 0.0)
      (gl:vertex s     0.0   0.0)
      (gl:vertex (- s) 0.0   0.0))
   (gl:end))

#||
(defparameter *square-1* (make-square-shape 1.0))
(run-db)
(with-win
   (draw *scene*))
(with-clear-and-redraw
   (add-shape *scene* *square-1*)
   (add-shape *scene* (make-instance 'marker-shape)))
(shapes *scene*)
*win*
(with-clear-and-redraw)

(with-clear-and-redraw
   (add-shape *scene* (make-instance 'marker-shape)))
;;переместим фигуру
(with-redraw
   (for-scene-shapes
    #'(lambda (s)
         (translate-by s (p! 0.05 0.01))
         (rotate-by    s 15.0)
         (scale-by     s 1.5))))
(with-clear-and-redraw
   (dotimes (i 100)
      (add-shape *scene*
                 (translate-to (make-instance 'marker-shape :size (rand2 0.05 0.2))
                               (p! (rand1 0.8) (rand1 0.8))))))

(with-redraw
   (dolist (s (shapes *scene*))
      (rotate-by s (rand1 45))))
||#

;; россыпи фигур =========================================
;;make shapes at list points
(defun make-shape-at-points (shape-fn points)
   (dolist (p points)
      (let ((s (funcall shape-fn)))
         (translate-to s p)
         (add-shape *scene* s))))

#||
;;на основе точек созданной фигуры circle создаем список фигур hexagon
(with-clear-and-redraw
   (make-shape-at-points (lambda () (make-hexagon-shape 0.2))
                         (points (make-circle-shape 1.5 32))))
;и все их можно повернуть
(with-redraw
   (dolist (s (shapes *scene*))
      (rotate-by s 15.0)))
||#

;;scattering shapes ==============================================================
;;make shapes at list of points
(defun make-shapes-at-points (shape-fn points)
   (dolist (p points)
      (let ((s (funcall shape-fn)))
         (translate-to s p)
         (add-shape *scene* s))))

#||
(run-db)
(with-win
   (draw *scene*))
(with-clear-and-redraw
   (make-shapes-at-points (lambda () (make-hexagon-shape 0.2))
                          (points (make-circle-shape 1.5 16))))

;;shapes on a circle
(with-clear-and-redraw
   (make-shapes-at-points (lambda () (make-hexagon-shape 0.2))
                          (points (make-circle-shape 1.5 5))))

;;shapes on a sine curve
(with-clear-and-redraw
   (make-shapes-at-points (lambda () (make-eql-tri-shape 0.2))
                          (let ((delta-p (p! -0.5 0.0)))
                             (mapcar (lambda (p) (p+ p delta-p))
                                     (points (make-sine-curve-shape 32))))))

||#

;;rewrite make-shapes-at-points as scatter-shapes
#|
(defun scatter-shapes (shape-fn points)
   (mapc (lambda (p)
            (add-shape *scene* (translate-to (funcall shape-fn) p)))
         points))
|#
;;shapes a spiral
#||
(with-clear-and-redraw
   (scatter-shapes (lambda () (make-hexagon-shape 0.1))
                   (points    (make-spiral-shape 1.5 128 4))))

||#

#||
(type-of #'p*) ;STANDARD-GENERIC-FUNCTION
(class-of #'p*) ;#<SB-MOP:FUNCALLABLE-STANDARD-CLASS COMMON-LISP:STANDARD-GENERIC-FUNCTION>
(describe #'p*) ;#<STANDARD-GENERIC-FUNCTION COMMON-LISP-USER::P* (2)>
[generic-function]
Lambda-list: (P1 P2)
Argument precedence order: (P1 P2)
Derived type: (FUNCTION (&REST T) *)
Method-combination: STANDARD
Methods:
  (P* (POINT NUMBER))
  (P* (POINT POINT))

Slots with :INSTANCE allocation:
  SOURCE                         = NIL
  PLIST                          = NIL
  %DOCUMENTATION                 = NIL
  INITIAL-METHODS                = NIL
  ENCAPSULATIONS                 = NIL
  NAME                           = P*
  METHODS                        = (#<STANDARD-METHOD COMMON-LISP-USER::P* (POINT NUMBER) {24F70869}>..
  METHOD-CLASS                   = #<STANDARD-CLASS COMMON-LISP:STANDARD-METHOD>
  %METHOD-COMBINATION            = #<SB-PCL::STANDARD-METHOD-COMBINATION STANDARD () {224B87F1}>
  DECLARATIONS                   = NIL
  ARG-INFO                       = #S(SB-PCL::ARG-INFO..
  DFUN-STATE                     = (#<CLOSURE (LAMBDA (&REST SB-PCL::ARGS)..
  %LOCK                          = #<SB-THREAD:MUTEX "GF lock" (free)>

(inspect #'p*) ; практически тоже самое что и describe

||#

;;обычная функция scatter-shapes
;(type-of #'scatter-shapes) ;FUNCTION
;;определение позволяющее переопределять scatter-shapes как обобщенную функцию
(defgeneric scatter-shapes (shape-fn locations))
;;(type-of #'scatter-shapes);STANDARD-GENERIC-FUNCTION
;;(inspect #'scatter-shapes);

;;with list arg
;; (defmethod scatter-shapes (shape-fn (points list))
;;    (mapc (lambda (p)
;;             (add-shape *scene* (translate-to (funcall shape-fn) p)))
;;          points))
(defmethod scatter-shapes (shape-fn (points list))
   (mapc (lambda (p)
            (translate-to (add-shape *scene* (funcall shape-fn)) p))
         points))

#|
(with-clear-and-redraw
   (scatter-shapes (lambda () (make-hexagon-shape 0.1))
                   (points    (make-spiral-shape 1.5 64 3))))
(with-clear-and-redraw
   (scatter-shapes (lambda () (make-diamond-shape 0.2))
                   (list  (p! -.5 -.5) (p! .5 -.5) (p! 0 .5))))


|#

;;with shape arg
(defmethod scatter-shapes (shape-fn (shape polygon-shape))
   (mapc (lambda (p)
            (translate-to (add-shape *scene* (funcall shape-fn)) p))
         (points shape)))

#|
(with-clear-and-redraw
   (scatter-shapes (lambda () (make-diamond-shape 0.2))
                   (make-circle-shape 1.5 32)))

|#

;;with function arg
(defmethod scatter-shapes (shape-fn (points-fn function))
   (mapc (lambda (p)
            (translate-to (add-shape *scene* (funcall shape-fn)) p))
         (funcall points-fn)))

#||
(with-clear-and-redraw
   (scatter-shapes (lambda () (make-diamond-shape 0.2))
                   (lambda ()
                      (let ((points '()))
                         (dotimes (i 20)
                            (push (p! (rand1 1.0) (rand1 1.0))
                                  points))
                         points))))

||#

(defun grid-points (nx ny bounds-lo bounds-hi)
   (let ((points '()))
      (dotimes (i nx)
         (let* ((fx (/ i (- nx 1.0)))
                (x  (lerp fx (x bounds-lo) (x bounds-hi))))
            (dotimes (j ny)
               (let* ((fy (/ j (- ny 1.0)))
                      (y (lerp fy (y bounds-lo) (y bounds-hi))))
                  (push (p! x y) points)))))
      points))

#||
;;make grid points
(grid-points 3 2 (p! -1.0 -0.5) (p! 1.0 0.5))

;; make makers at grid points
(with-clear-and-redraw
   (scatter-shapes (lambda () (make-instance 'marker-shape))
                   (grid-points 6 4 (p! -0.8 -0.4) (p! 0.8 0.4))))

(with-clear-and-redraw
   (scatter-shapes (lambda () (make-square-shape 0.1))
                   (grid-points 14 7
                                (p! -0.8 -0.4) (p! 0.8 0.4))))
;;randomize shape points
(with-redraw
   (for-scene-shapes
    (lambda (s) (randomize-points s (p! 0.01 0.01)))))

;;grid of random polygons
(with-clear-and-redraw
   (scatter-shapes (lambda () (make-circle-shape 0.2 (floor (rand2 3 16))))
                   (grid-points 8 8 (p! -0.8 -0.8) (p! 0.8 0.8))))
(inspect *win*)

(update *win*) ;;принудительно обновим окно, почемуто иногда не срабатывает
(slot-value *win* 'update)
||#

#||
;;random points with bounds
(defun random-points (n bounds-lo bounds-hi)
   (let ((points '()))
      (dotimes (i n)
         (push (p! (rand2 (x bounds-lo) (x bounds-hi))
                   (rand2 (y bounds-lo) (y bounds-hi)))
               points))
      points))
||#

;;rewritten with loop macro
(defun random-points (n bounds-lo bounds-hi)
   (loop for i from 1 to n
         collect (p! (rand2 (x bounds-lo) (x bounds-hi))
                     (rand2 (y bounds-lo) (y bounds-hi)))))


#||
;;make marker at points
(with-clear-and-redraw
   (scatter-shapes (lambda () (make-instance 'marker-shape))
                   (random-points 100 (p! -0.8 -0.8) (p! 0.8 0.8))))

;;shapes scaled by distance from origin
(with-clear-and-redraw
   (scatter-shapes (lambda () (make-instance 'marker-shape))
                   (random-points 100 (p! -0.8 -0.8) (p! 0.8 0.8))))

;;фигуры маштабированные по дистанции от края
(with-clear-and-redraw
   (scatter-shapes (lambda () (make-eql-tri-shape 0.4))
                   (random-points 300 (p! -0.9 -0.9) (p! 0.9 0.9)))

   (for-scene-shapes
    (lambda (s)
       (let ((scale (- 1.0 (p-mag (translate (transform s))))))
          (scale-to s scale)))))

(with-redraw
   (add-shape *scene*
              (make-circle-shape 2.0)))

||#



