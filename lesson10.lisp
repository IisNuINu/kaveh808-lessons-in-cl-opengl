;; Renderers Part 2
;;(defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/" (user-homedir-pathname)))
;;(load (merge-pathnames "lesson10.lisp"  *d*))
(eval-when (:compile-toplevel :load-toplevel :execute)
   (if (eq (uiop:operating-system) :win)
       (progn
          (defparameter *d* (merge-pathnames "WORK/lisp/learn/pkg/opengl/"
                                             "D:/")))
       (progn
          (defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/"
                                             (user-homedir-pathname)))))
   (load (merge-pathnames "lesson09.lisp"  *d*)))


#||
rapid iteration Алан Кей быстрая разаработка приближений.
||#

(defun angle-2d (p1 p2)
   (let* ((theta1 (atan (y p1) (x p1)))
          (theta2 (atan (y p2) (x p2)))
          (dtheta (- theta2 theta1)))
      (loop while (> dtheta pi)
            do (setf dtheta (- dtheta (* 2 pi))))
      (loop while (< dtheta (- pi))
            do (setf dtheta (+ dtheta (* 2 pi))))
      dtheta))

(defun point-in-polygon? (p points)
   (let ((angle 0.0))
      (loop for (p1 p2) on (append points (list (first points))) by #'cdr while p2
                    do (incf angle (angle-2d (p- p1 p) (p- p2 p))))
            (> (abs angle) pi)))

(defun p-copy (p)
   (p! (x p) (y p)))

(defun points-bounds (points)
   (let ((bounds-lo (p-copy (first points)))
         (bounds-hi (p-copy (first points))))
      (dolist (p points)
         (when (> (x p) (x bounds-hi)) (setf (x bounds-hi) (x p)))
         (when (> (y p) (y bounds-hi)) (setf (y bounds-hi) (y p)))
         (when (< (x p) (x bounds-lo)) (setf (x bounds-lo) (x p)))
         (when (< (y p) (y bounds-lo)) (setf (y bounds-lo) (y p)))
         )
      (values bounds-lo bounds-hi)))

;;; pointerly renderer ===================================================
(defclass pointerly-renderer (renderer)
  ((brush-jitter :accessor brush-jitter
                 :initarg :brush-jitter
                 :initform 0.05)
   (brush-density :accessor brush-density
                  :initarg :brush-density
                  :initform 1.0)
   (brush-size    :accessor brush-size
                  :initarg :brush-size
                  :initform 0.1)
   (brush-smooothness :accessor brush-smooothness
                      :initarg :brush-smooothness
                      :initform 16)
   (brush-color-variation :accessor brush-color-variation
                          :initarg :brush-color-variation
                          :initform (c! 0.2 0.2 0.2))))

(defmethod make-brush-grid ((rend pointerly-renderer) bounds-lo bounds-hi)
   (let ((points '())
         (nx (1+ (floor (* (/ (- (x bounds-hi) (x bounds-lo))
                              (brush-size rend))
                           (brush-density rend)))))
         (ny (1+ (floor (* (/ (- (y bounds-hi) (y bounds-lo))
                              (brush-size rend))
                           (brush-density rend))))))
      (dotimes (i nx)
         (let* ((fx (/ i (- nx 1.0)))
                (x (lerp fx (x bounds-lo) (x bounds-hi))))
            (dotimes (j ny)
               (let* ((fy (/ j (- ny 1.0)))
                      (y (lerp fy (y bounds-lo) (y bounds-hi))))
                  (push (p-jitter (p! x y) (brush-jitter rend))
                        points)))))
      points))

(defmethod draw-with-renderer ((shape polygon-shape) (rend pointerly-renderer))
   (multiple-value-bind (bounds-lo bounds-hi)
       (points-bounds (points shape))
      (let ((brush (make-circle-shape (brush-size rend)
                                      (brush-smooothness rend)))
            (grid  (make-brush-grid rend bounds-lo bounds-hi)))
         (set-shape-color brush 0.0 :part :outline :component :alpha)
         (dolist (p grid)
            (let ((brush-color (c-jitter
                                (fill-color (appearance shape))
                                (brush-color-variation rend))))
               (set-shape-color brush brush-color :part :fill))
            (when (point-in-polygon? p (points shape))
               (draw (translate-to brush p))))))
   (draw-polygon-outline (points shape) (outline-color (appearance shape))))


#||
(run-db)
(with-win
   (draw *scene*))
*win*
(with-clear-and-redraw)

(with-redraw
   (dolist (s (shapes *scene*))
      (rotate-by s (rand1 45))))
||#



#||
;;test pointerly-renderer
(progn
   (defparameter *shape* (make-pentagon-shape 1.0))
   (with-clear-and-redraw
      (add-shape *scene* *shape*)
      (setf (bg-color *scene*) (c! 0.5 0.5 0.5))
      (set-shape-color *shape* (c! 1 1 0) :part :outline)
      (set-shape-color *shape* (c! .2 .2 .8) :pat :fill)
      ))

(with-redraw
   (setf (renderer *scene*)
         (make-instance 'pointerly-renderer
                        :brush-density 1.0 :brush-jitter 0.0
                        :brush-color-variation (c! 0 0 0 0))))
(setf *win* nil)
(with-redraw
   (setf (brush-size (renderer *scene*)) 0.05))

(with-redraw
   (setf (brush-color-variation (renderer *scene*)) (c! 0.1 0.1 0.1 0.0)))

(with-redraw
   (setf (brush-jitter (renderer *scene*)) 0.01))

(with-redraw
   (setf (brush-density (renderer *scene*)) 2.0)
   (setf (brush-smooothness (renderer *scene*)) 8))

(with-redraw
   (set-shape-color *shape* 0.0 :part :outline :component :alpha))

(with-redraw
   (setf (renderer *scene*) nil))
||#


;;;test with hexagons

#||
(progn
   (defparameter *shape* (make-hexagons 6))
   (with-clear-and-redraw
      (add-shape *scene* *shape*)
      (randomize-colors *shape*)
      (set-shape-color  *shape* 0.0 :part :outline :component :alpha)))



||#


#||
(progn
   (defparameter *shape* (scale-to (make-wobbly-cross 1) (p! .33 .33)) )
   (with-clear-and-redraw
      (add-shape *scene* *shape*)
      (randomize-colors *shape*)
      (set-shape-color  *shape* 0.0 :part :outline :component :alpha)))



||#
