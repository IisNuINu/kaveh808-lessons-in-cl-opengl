;;  Groups
;;(defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/" (user-homedir-pathname)))
;;(load (merge-pathnames "lesson04.lisp"  *d*))
(eval-when (:compile-toplevel :load-toplevel :execute)
   (if (eq (uiop:operating-system) :win)
       (progn
          (defparameter *d* (merge-pathnames "WORK/lisp/learn/pkg/opengl/"
                                             "D:/")))
       (progn
          (defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/"
                                             (user-homedir-pathname)))))
   (load (merge-pathnames "lesson04.lisp"  *d*)))


;;   =============================================================

#||
(defparameter *var* 4.0)
(type-of *var*) ;SINGLE-FLOAT
(setf *var* "Hello!")
(type-of *var*) ;(SIMPLE-ARRAY CHARACTER (6))
||#

;; utsils ===========================================================
(defun print-spaces (num)
   (dotimes (i num)
      (princ " ")))

;; groups ===========================================================

;;класс для управления иерархией фигур
(defclass group (shape)
  ((children :accessor children
             :initarg :children
             :initform '())))

(defmethod add-child ((self group) (s shape))
   (push s (children self))
   s)

(defmethod draw ((self group))
   (mapc #'draw (children self)))

(defun make-group (&rest shapes)
   (make-instance 'group :children shapes))

;;for diagnostic< we can print out scene hierarchy
(defmethod print-hierarchy ((self scene) &optional (indent 0))
   (print-spaces indent)
   (format t "~a~%" self)
   (dolist (shape (shapes self))
      (print-hierarchy shape (+ indent 2))))

(defmethod print-hierarchy ((self shape) &optional (indent 0))
   (print-spaces indent)
   (format t "~a~%" self))

;; use :after method
(defmethod print-hierarchy :after ((self group) &optional (indent 0))
   (dolist (child (children self))
      (print-hierarchy child (+ indent 2))))

;;; show polygon-shape number of points
(defmethod print-object ((self polygon-shape) stream)
   (print-unreadable-object (self stream :type t :identity t)
      (format stream "[~a]" (length (points self)))))


#||
;;создадим группу и распечатаем иерархию
(progn
   (defparameter *hexagon*  (make-hexagon-shape 0.4))
   (defparameter *square*   (make-square-shape  0.4))
   (defparameter *triangle* (make-eql-tri-shape 0.4)))

(progn
   (defparameter *group-1* (make-group *square* *triangle*))
   (print-hierarchy *group-1*))

(progn
   (defparameter *group-2* (make-group *group-1* *hexagon*))
   (print-hierarchy *group-2*))

(with-clear-and-redraw
   (add-shape *scene* *group-2*))
||#

;;добавим в класс фигур возможность показвать оси show-axis?
(defclass shape ()
  ((transform :accessor transform
              :initarg :transform
              :initform (make-instance 'transform))
   (show-axis? :accessor show-axis?
               :initarg :show-axis?
               :initform nil)))

(defmethod draw-axis ((self shape))
   (gl:line-width 3.0)
   (gl:begin :lines)
   ;;x axis red
   (gl:color 0.8 0.2 0.2)
   (gl:vertex 0.0 0.0 0.0)
   (gl:vertex 0.25 0.0 0.0)
   ;;y axis
   (gl:color 0.2 0.8 0.2)
   (gl:vertex 0.0 0.0 0.0)
   (gl:vertex 0.0 0.25 0.0)
   (gl:end))

;;draw axis and pop matrix after drawing
(defmethod draw :after ((self shape))
   (when (show-axis? self)
      (draw-axis self))
   (gl:pop-matrix))

#||
;; в шестом уроке он переопределяется и меняетс сигнатура, и старая сигнатура
;; мешает определить метод в 6 уроке, поэтому здесь закоментировал!
;; проходим по иерархии и выполняем функцию, аргументом которой является тек. фигура
(defmethod do-hierarhy ((self shape) func)
   (funcall func self))

(defmethod do-hierarhy :after ((self group) func)
   (dolist (child (children self))
      (do-hierarhy child func)))
||#

#||
;;в классе произошли изменения появилась возможность отображать оси, используем её
(with-redraw
   (do-hierarhy *group-2*
      (lambda (s) (setf (show-axis? s) t))))
;; подвигаем фигуры
(with-redraw
   (translate-by *triangle* (p! 0.0 0.05)))
(with-redraw
   (rotate-by *triangle* 10.0))
(with-redraw
   (translate-by *square* (p! 0.0 -0.05)))
(with-redraw
   (rotate-by *group-1* -10.0))

(with-redraw
   (rotate-by *group-2* 10.0))

(with-redraw
   (translate-by *hexagon* (p! 0.05 0.0)))

(with-redraw
   (scale-by *group-2* 0.9))

(with-redraw
   (translate-by *group-1* (p! 0.05 0.0)))

(with-redraw
   (translate-by *group-2* (p! -0.05 0.0)))
||#


#||
;;добавляемая в группу фигура наследует все преобразования группы
(progn
   (defparameter *pentagon* (make-pentagon-shape 0.3))
   (with-redraw
      (add-child *group-1* *pentagon*)))
;;экземпляр фигуры можно добавить в две иерархии
(with-redraw
   (add-child *group-2* *pentagon*)
   (print-hierarchy *group-2*))

;;теперь применим преобразования к самой фигуре добавленной в 2 группы
(with-redraw
   (translate-by *pentagon* (p! 0.0 -0.1)))

(with-redraw
   (rotate-by *pentagon* 10.0))
||#

#||
;;;;make robot arm
(progn
   (defparameter *waist-shape*     (make-circle-shape 0.3))
   (defparameter *torso-shape*     (make-pentagon-shape 1.0))
   (defparameter *shoulder-shape*  (make-circle-shape 1.0 16))
   (defparameter *upper-arm-shape* (make-square-shape 1.0))
   (defparameter *elbow-shape*     (make-circle-shape 1.0 16))
   (defparameter *lower-arm-shape* (make-square-shape 1.0))
   (defparameter *wrist-shape*     (make-circle-shape 1.0 16))
   (defparameter *hand-shape*      (make-square-shape 1.0))
   
   (defparameter *wrist* (make-group *wrist-shape* *hand-shape*))
   (defparameter *elbow* (make-group *elbow-shape* *lower-arm-shape* *wrist*))
   (defparameter *shoulder* (make-group *shoulder-shape* *upper-arm-shape* *elbow*))
   (defparameter *torso* (make-group *shoulder-shape* *upper-arm-shape* *elbow*))
   (defparameter *waist* (make-group *waist-shape* *torso-shape* *shoulder*)))

(print-hierarchy *waist*)

(with-clear-and-redraw)
(update *win*)


(with-clear-and-redraw
   (add-shape *scene* *waist*)

   (translate-to *waist* (p! -0.6 -0.4))
   (translate-to *shoulder* (p! 0.4 0.8))
   (scale-to     *shoulder* 0.3)
   (translate-to *elbow* (p! 1.8 0.0))
   (scale-to     *elbow* 0.5)
   (translate-to *wrist* (p! 3.0 0.0))
   (scale-to     *wrist* 0.6)

   (translate-to *torso-shape* (p! 0.0 0.4))
   (translate-to *upper-arm-shape* (p! 1.0 0.0))
   (scale-to     *upper-arm-shape* (p! 1.05 0.5))
   (translate-to *lower-arm-shape* (p! 1.6  0.0))
   (scale-to     *lower-arm-shape* (p! 2.1  0.5))
   (translate-to *hand-shape*      (p! 1.2  0.0)))

||#

#||
(defmethod print-object ((self polygon-shape) stream)
   (let ((tr (transform self)))
      (print-unreadable-object (self stream :type t :identity t)
         (format stream "n:[~a], t:[~a], r:[~a], s:[~a]"
                 (length (points self))
                 (translate  tr)
                 (rotate    tr)
                 (scale     tr)))))
||#

(defmethod print-object :after ((self shape) stream)
   (let ((tr (transform self)))
      (format stream "~a"  tr)))

#||
(with-redraw
  (do-hierarhy *waist* (lambda (s) (setf (show-axis? s) t))))
(with-redraw
  (rotate-by *shoulder* -10)) ;;поворачивается плечо
(with-redraw
  (rotate-by *elbow* 10))     ;;поворачивается локоть
(with-redraw
  (rotate-by *wrist* 10))     ;;поворачивается кисть
(with-redraw
  (rotate-by *waist* -10))    ;;наклоняется весь робот по оси колеса

(defun reset-pose ()
  (rotate-to *waist* 0)
  (rotate-to *shoulder* 0)
  (rotate-to *elbow*    0)
  (rotate-to *wrist*    0))
(with-redraw
  (reset-pose)) ;;вернулись в исходное положение

(defun flex ()
  (rotate-by *waist* -1)
  (rotate-by *shoulder* -5)
  (rotate-by *elbow*    15)
  (rotate-by *wrist*    10))

(with-redraw
  (flex))

(defun flex2 (&optional (dir t))
  (let ((lst-obj (list *waist* *shoulder* *elbow* *wrist*))
	(lst-r   '(-1 -5 15 10)))
    (mapc (lambda (o r)
	    ;;(format t "o:~a, r:~a~%" o r)
	    (rotate-by o r)) 
	  lst-obj
	  (if dir
	      lst-r
	      (mapcar (lambda (c) (- c))
		      lst-r)))))
(defun flex2 (&optional (dir t))
  (let ((lst-obj (list *waist* *shoulder* *elbow* *wrist*))
	(lst-r   '(-1 -5 15 10)))
    (mapc #'rotate-by 
	  lst-obj
	  (if dir
	      lst-r
	      (mapcar (lambda (c) (- c))
		      lst-r)))))


(with-redraw
  (flex2))
(with-redraw
  (flex2 nil))

(mapc (lambda (a) (format t "a:~a, b:~%" a))  '(1 2 3 4))
(mapc (lambda (a b) (format t "a:~a, b:~a~%" a b))  '(1 2 3 4) '(a b c d))

||#


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
(with-redraw
   (dolist (s (shapes *scene*))
      (rotate-by s (rand1 45))))
||#


