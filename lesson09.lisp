;; Renderers Part 1
;;(defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/" (user-homedir-pathname)))
;;(load (merge-pathnames "lesson08.lisp"  *d*))
(eval-when (:compile-toplevel :load-toplevel :execute)
   (if (eq (uiop:operating-system) :win)
       (progn
          (defparameter *d* (merge-pathnames "WORK/lisp/learn/pkg/opengl/"
                                             "D:/")))
       (progn
          (defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/"
                                             (user-homedir-pathname)))))
   (load (merge-pathnames "lesson08.lisp"  *d*)))


#||
CL - расширяемость, т.е последовательности, хеши, отображения, итераторы
||#

;;;;; utils ============================================================

(defmethod p- ((p1 point) (p2 point))
  (p! (- (x p1) (x p2))
      (- (y p1) (y p2))))

(defun p-jitter (p amount)
  (p+ p (p! (rand1 amount) (rand1 amount))))

(defun p-midpoint (p1 p2)
  (p* (p+ p1 p2) 0.5))

(defun p-center (points)
  (let* ((m   (length points))
	 (denom (/ 1.0 m)))
    (p* (reduce #'p+ points) denom)))


;;;; renderer ============================================================

;; abstract superclass
(defclass renderer ()
  ())

;; используется для множественной диспетчеризации
;; ничего не делаем просто выдаем сообщение что рендерер не настроен
(defmethod draw-with-renderer ((shape shape) (rend renderer))
  (warn "Reanderer ~a does not support shape ~a~%" rend shape))

(defmethod draw-with-renderer :before ((shape shape) (rend renderer))
  (let ((xform (transform shape)))
    (gl:push-matrix)
    (gl:translate (x (translate xform))
                  (y (translate xform))
                  0.0)
    (gl:rotate    (rotate xform) 0.0 0.0 1.0)
    (gl:scale     (x (scale xform))
                  (y (scale xform))
                  1.0)))

                                            
(defmethod draw-with-renderer :after ((self shape) (rend renderer))
   (gl:pop-matrix))

(defmethod draw-with-renderer ((group group) (rend renderer))
  (dolist (child (children group))
    (draw-with-renderer child rend)))


;;;; scene ================================================================

;; add renderer to scene
(defclass scene ()
  ((shapes   :accessor shapes
             :initarg :shapes
             :initform '())
   (bg-color :accessor bg-color
             :initarg :bg-color
             :initform (c! 0 0 0 0))
   (renderer :accessor renderer
	     :initarg :renderer
	     :initform nil)))

(defmethod draw-with-renderer ((scene scene) (rend renderer))
  (dolist (s (shapes scene))
    (draw-with-renderer s rend)))

;;redefine draw method
(defmethod draw ((self scene))
  (if (renderer self)
      (draw-with-renderer self (renderer self))
      (mapc #'draw (shapes self ))))

;;; renderer utils ==========================================================

;;; break drawing into parts

(defun draw-polygon-fill (points color)
  (gl:color (c-red color) (c-green color) (c-blue color) (c-alpha color))
  (gl:begin :polygon)
  (dolist (p points)
    (gl:vertex (x p) (y p) 0.0))
  (gl:end))

(defun draw-polygon-outline (points color &optional (line-width 3.0))
  (gl:color (c-red color) (c-green color) (c-blue color) (c-alpha color))
  (gl:line-width line-width)
  (gl:begin :line-loop)
  (dolist (p points)
    (gl:vertex (x p) (y p) 0.0))
  (gl:end))

;;;;; drafting renderer =====================================================

(defclass drafting-renderer (renderer)
  ((overshoot :accessor overshoot
	      :initarg :overshoot
	      :initform 0.2)
   (line-width :accessor line-width
	       :initarg :line-width
	       :initform 3.0)
   (stipple    :accessor stipple
	       :initarg  :stipple
	       :initform nil))) ; :dotted :dashed

(defun draw-polygon-outline-segments (points color &key (line-width 3.0) (stipple nil))
  (gl:color (c-red color) (c-green color) (c-blue color) (c-alpha color))
  (gl:line-width line-width)
  (when stipple
    (gl:enable :line-stipple)
    (cond ((eql :dotted stipple) (gl:line-stipple 1 #x00ff))
	  ((eql :dashed stipple) (gl:line-stipple 4 #x00ff))))
  (gl:begin :lines)
  (dolist (p points)
    (gl:vertex (x p) (y p) 0.0))
  (gl:end)
  (when stipple
    (gl:disable :line-stipple)))

(defun extend-polygon-sides (overshoot points)
  (let ((new-points '()))
    (loop for (p1 p2) on (append points (list (first points))) by #'cdr while p2
	  do (progn
	       (let ((dir (p* (p- p2 p1) overshoot)))
		 (push (p- p1 dir) new-points)
		 (push (p+ p2 dir) new-points))))
    new-points))

(defmethod draw-with-renderer ((shape polygon-shape) (rend drafting-renderer))
  (draw-polygon-fill (points shape) (fill-color (appearance shape)))
  (draw-polygon-outline-segments (extend-polygon-sides (overshoot rend) (points shape))
				 (outline-color (appearance shape))
				 :line-width (line-width rend)
				 :stipple (stipple rend)))


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


;; test drafting renderer
#||
(progn
  (defparameter *shape* (make-square-shape 1.0))
  (with-clear-and-redraw
    (add-shape *scene* *shape*)
    (setf (bg-color *scene*) (c! 0.5 0.5 0.5))
    (set-shape-color *shape* (c! 1 1 0) :part :outline)
    (set-shape-color *shape* (c! .2 .2 .8) :part :fill)))

(with-redraw
  (setf (renderer *scene*) (make-instance 'drafting-renderer :overshoot 0.1)))

(with-redraw
  (setf (overshoot (renderer *scene*)) 0.2))
(with-redraw
  (setf (line-width (renderer *scene*)) 7.0))
(with-redraw
  (setf (stipple (renderer *scene*)) :dotted))
(with-redraw
  (setf (stipple (renderer *scene*)) :dashed))
(with-redraw
  (setf (stipple (renderer *scene*)) nil))
(with-redraw
  (setf (renderer *scene*) nil))
||#


#||
(progn
  (defparameter *shape* (make-random-squares 20))
  (with-clear-and-redraw
    (add-shape *scene* *shape*)
    (setf (bg-color *scene*) (c! 1 1 1))
    (set-shape-color *shape* (c! 0 0 0) :part :outline)
    (set-shape-color *shape* (c! .0 .0 .0 .5) :part :fill)))

;;REDO above test

||#

;;волнистый рендеринг
(defclass squiggly-renderer (renderer)
  ((iterations   :accessor iterations
                 :initarg :iterations
                 :initform 2)
   (displacement :accessor displacement
                 :initarg :displacement
                 :initform 0.1)))

;;лучшая работа для не выпуклых(non-convex) многоугольников, но не для всех.
(defun draw-polygon-fill-tri-fan (points color)
   (gl:color (c-red color) (c-green color) (c-blue color) (c-alpha color))
   (gl:begin :triangle-fan)
   (let ((center (p-center points)))
      (gl:vertex (x center) (y center) 0.0))
   (dolist (p points)
      (gl:vertex (x p) (y p) 0.0))
   (let ((p0 (first points)))
      (gl:vertex (x p0) (y p0) 0.0))
   (gl:end))

(defmethod do-squiggle (iterations displacement points)
   (if (= 0 iterations)
       points
       (let ((new-points '()))
          (loop for (p1 p2) on (append points (list (first points))) by #'cdr
                while p2
                do (progn
                      (push p1 new-points)
                      (push (p-jitter (p-midpoint p1 p2) displacement) new-points)))
          (do-squiggle (- iterations 1) (/ displacement 2) new-points))))

#||
;;что это за цикл?
(let ((points '(1 2 3 4 5 6)))
   (let ((new-points '()))
      (loop for (p1 p2) on (append points (list (first points))) by #'cdr
            while p2
            do (progn
                  (push p1 new-points)
                  (push (list 'middle p1  p2) new-points)))
      new-points))
;;((MIDDLE 6 1) 6 (MIDDLE 5 6) 5 (MIDDLE 4 5) 4 (MIDDLE 3 4) 3 (MIDDLE 2 3) 2
;; (MIDDLE 1 2) 1)
||#


(defmethod draw-with-renderer ((shape polygon-shape) (rend squiggly-renderer))
   (let ((points (do-squiggle (iterations rend) (displacement rend) (points shape))))
      (draw-polygon-fill-tri-fan points (fill-color (appearance shape)))
      (draw-polygon-outline      points (outline-color (appearance shape)))))

#||
;;test squiggly-renderer
(progn
   (defparameter *shape* (make-square-shape 1.0))
   (with-clear-and-redraw
      (add-shape *scene* *shape*)
      (setf (bg-color *scene*) (c! 0.5 0.5 0.5))
      (set-shape-color *shape* (c! 1 1 0) :part :outline)
      (set-shape-color *shape* (c! .2 .2 .8) :part :fill)))
(with-redraw
   (set-shape-color *shape* (c! .2 .2 .8) :part :fill))
(with-redraw
   (setf (renderer *scene*) (make-instance 'squiggly-renderer :iterations 1
                                           :displacement 0.1)))
(with-redraw
   (setf (iterations (renderer *scene*)) 2))
(with-redraw
   (setf (iterations (renderer *scene*)) 3))
(with-redraw
   (setf (iterations (renderer *scene*)) 4))
(with-redraw
   (setf (displacement (renderer *scene*)) 0.05))
(with-redraw
   (setf (renderer *scene*) nil))
||#

#||
(progn
   (defparameter *shape* (make-hexagons))
   (with-clear-and-redraw
      (add-shape *scene* *shape*)
      (setf (bg-color *scene*) (c! 1 1 1))
      (set-shape-color *shape* (c! 0 0 0) :part :outline)
      (set-shape-color *shape* (c! .0 .0 .0 .5) :part :fill)))
(with-redraw
   (set-shape-color *shape* (c! .4 .4 .4 0.5) :part :fill))

(with-redraw
   (setf (renderer *scene*) (make-instance 'squiggly-renderer :iterations 3
                                           :displacement 0.02)))
(with-redraw
   (setf (iterations (renderer *scene*)) 4)
   (setf (displacement (renderer *scene*)) 0.05))
(with-redraw
   (setf (renderer *scene*) nil))
||#
