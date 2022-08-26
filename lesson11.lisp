;; Animation
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
   (load (merge-pathnames "lesson10.lisp"  *d*)))

;; point ======================================================================

(defmethod p-rand1 ((p point))
  (p! (rand1 (x p)) (rand1 (y p))))

(defmethod p-rand1 ((val number))
  (p! (rand1 val) (rand1 val)))


;; animator ==================================================================

(defclass animator ()
  ((init-fn      :accessor init-fn
	         :initarg :init-fn
	         :initform nil)
   (update-fn    :accessor update-fn
		 :initarg :update-fn
		 :initform nil)
   (is-initialized? :accessor is-initialized?
		    :initarg :is-initialized?
		    :initform nil)
   (shape         :accessor shape
		  :initarg :shape
		  :initform nil)))

(defmethod init-animator ((anim animator))
  (when (init-fn anim)
    (funcall (init-fn anim) anim)))

(defmethod init-animator :after ((anim animator))
  (setf (is-initialized? anim) t))

(defmethod update-animator :before ((anim animator))
  (when (not (is-initialized? anim))
    (init-animator anim)))

(defmethod update-animator ((anim animator))
  (when (update-fn anim)
    (funcall (update-fn anim) anim)))

;;; scene ==========================================================================================

;;;; add current-frame to scene
(defclass scene ()
  ((shapes   :accessor shapes
             :initarg :shapes
             :initform '())
   (bg-color :accessor bg-color
             :initarg :bg-color
             :initform (c! 0 0 0 0))
   (renderer :accessor renderer
             :initarg :renderer
             :initform nil)
   (animators :accessor animators
	      :initarg :animators
	      :initform '())
   (current-frame :accessor current-frame
		  :initarg :current-frame
		  :initform 0)))

(defmethod set-animator ((scene scene) (anim animator))
  (setf (animators scene) (list anim))
  anim)

(defmethod add-animator ((scene scene) (anim animator))
  (push anim (animators scene))
  anim)

(defmethod clear-animators ((scene scene))
  (setf (animators scene) '())
  scene)

(defmethod init-scene ((self scene))
  (setf (current-frame self) 0)
  (mapc #'init-animator (animators self)))

(defmethod update-scene ((self scene))
  (incf (current-frame self))
  ;;(format t "form update-scene cur-frame: ~a~&" (current-frame self))
  (mapc #'update-animator (animators self)))

;;;;device  ===========================================================================================
;;по щелчку мыши осуществляем итерацию анимации
(defmethod glut:mouse ((w draw-board) button state x y)
  (declare (ignore x y ))
  (when *scene*
    (when (and (eq button :left-button) (eq state :down))
      (update-scene *scene*)
      (glut:post-redisplay))))

(defmethod glut:keyboard ((w draw-board) key x y)
  (declare (ignore x y))
  (case key
    (#\a     (when *scene*
	       (init-scene *scene*)
	       (glut:post-redisplay)))
    (#\space (when *scene*
	       (update-scene *scene*)
	       (glut:post-redisplay)))))



;; test view refresh
#||
(progn
  (defparameter *shape* (make-hexagons))
  (with-clear-and-redraw
    (add-shape *scene* *shape*)
    (setf (bg-color *scene*) (c! 1 1 1))
    (set-shape-color *shape* (c! 0 0 0) :part :outline)
    (set-shape-color *shape* (c! .8 .8 .8 .5) :part :fill)))

;; hold down space to animatescene - squiggly-renderer
;; анимация без аниматора! анимируем только за счет изменяющегося рендера
(with-redraw
  (setf (renderer *scene*) (make-instance 'squiggly-renderer :iterations 4 :displacement 0.02)))

(with-redraw
  (setf (renderer *scene*) nil))
||#


;;функции запуска и работы с draw-board
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
(defparameter *shape*
  (with-clear-and-redraw
    (setf (bg-color *scene*) (c! 0 0 1))
    (add-shape *scene* (make-square-shape 1.0))))

;; set rotation animator
(set-animator *scene*
	      (make-instance 'animator
			     :shape *shape*
			     :update-fn (lambda (anim)
					  ;;(format t "from update ~%")
					  (rotate-by (shape anim) -5))))
(inspect (animators *scene*) )
(inspect (car (animators *scene*)))
(update-fn (car (animators *scene*)))
(with-redraw
  (update-scene *scene*))

;;set jitter points
(set-animator *scene*
	      (make-instance 'animator
			     :shape *shape*
			     :update-fn (lambda (anim)
					  ;;(format t "from update ~%")
					  (randomize-points (shape anim) (p! 0.05 0.05)))))

;;; add rotation animator -layer animations
(add-animator *scene*
	      (make-instance 'animator
			     :shape *shape*
			     :update-fn (lambda (anim)
					  (rotate-by (shape anim) 5))))

(clear-animators *scene*)

(defparameter *shape*
  (with-clear-and-redraw
    (setf (bg-color *scene*) (c! 0 0 0))
    (add-shape *scene* (make-square-shape 1.0))))

(set-animator *scene*
	      (make-instance 'animator
			     :shape *shape*
			     :init-fn   (lambda (anim) (rotate-to (shape anim) 0))
			     :update-fn (lambda (anim)
					  (rotate-by (shape anim) 5))))

||#



;; animate shapes in group
#||
(defparameter *shape*
  (with-clear-and-redraw
    (add-shape *scene*
	       (scatter-group (lambda () (make-square-shape 0.1))
			      (grid-points 5 5 (p! -0.4 -0.4) (p! 0.4 0.4))))))

(set-animator *scene*
	      (make-instance 'animator
			     :shape *shape*
			     :init-fn   (lambda (anim) (do-hierarhy (shape anim)
							 (lambda (s) (rotate-to s 0))
							 :test #'is-leaf?))
			     :update-fn (lambda (anim) (do-hierarhy (shape anim)
							 (lambda (s) (rotate-by s 5))
							 :test #'is-leaf?))))


(with-redraw
  (randomize-leaf-sizes *shape* 0.8 2.0))

(set-animator *scene*
	      (make-instance 'animator
			     :shape *shape*
			     :update-fn (lambda (anim) (do-hierarhy (shape anim)
							 (lambda (s) (translate-by s (p-rand1 0.05)))
							 :test #'is-leaf?))))

(add-animator *scene*
	      (make-instance 'animator
			     :shape *shape*
			     :init-fn   (lambda (anim) (do-hierarhy (shape anim)
							 (lambda (s) (rotate-to s 0))
							 :test #'is-leaf?))
			     :update-fn (lambda (anim) (do-hierarhy (shape anim)
							 (lambda (s) (rotate-by s 5))
							 :test #'is-leaf?))))

||#

#||
(defparameter *shape*
  (with-clear-and-redraw
    (add-shape *scene* (make-hexagons))))
(progn
  (clear-animators *scene*)
  (do-hierarhy *shape*
    (lambda (s)
      (let ((angle (rand2 0 5)))
	(add-animator *scene*
		      (make-instance 'animator
				     :shape s
				     :update-fn (lambda (anim)
						  (rotate-by (shape anim) angle))))))
    :test #'is-leaf?))

||#
