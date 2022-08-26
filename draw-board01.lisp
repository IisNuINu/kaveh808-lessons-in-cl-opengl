;;(require 'bordeaux-threads)
;;(asdf:load-system :cffi)

;;(eval-when (:compile-toplevel :load-toplevel :execute)

;(eval-when (:execute)
   ;;(format t "load cffi~%")
   ;;(asdf:load-system :cffi)

(eval-when (:compile-toplevel :load-toplevel :execute)
   (require :cffi)
   (format t "In compile time load cffi: ~a~%" (find-package :cffi)))

(eval-when (:compile-toplevel :load-toplevel :execute)
   (if (eq (uiop:operating-system) :win)
       (progn
          (setf  cffi:*foreign-library-directories*
                 (list (parse-namestring "D:/dll/"))))
       ))
(find-package   "CFFI")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (format t "load cl-glut~%")
  (require :cl-glut))
;;(find-package "CL-GLUT")

(defparameter *win* nil)
;

(defclass draw-board (glut:window)
  ((df :initform nil)
   ;(arg :initform nil)
   (update :initform nil))
  
  (:default-initargs
   :pos-x 50 :pos-y 50 :width 600 :height 600
   :mode '(:single :rgb) :title "draw-board"))

(defmethod glut:display-window :before ((w draw-board))
  ;; Select clearing color.
  (gl:clear-color 0 0 0 0)
  ;; Initialize viewing values.
  (gl:matrix-mode :projection)
  (gl:load-identity)
  (gl:ortho -1 1 -1 1 -1 1))

(defmethod glut:display ((w draw-board))
  (gl:clear :color-buffer)
  (let ((df   (slot-value w 'df)))
      (format t "call display ~a~%" w)
      (when (functionp df)
          (apply df nil)))   ;;(apply df arg)
  ;; Start processing buffered OpenGL routines.
  (gl:flush))


(defmethod glut:idle ((w draw-board))
  (when (slot-value w 'update)
    ;;(format t "in idle ~%")
    (setf (slot-value w 'update) nil)
    (glut:post-redisplay)))

(defmethod glut:visibility ((w draw-board) state)
  (case state
    (:visible (glut:enable-event w :idle))
    (t (glut:disable-event w :idle))))


(defmethod update ((w draw-board))
  (setf (slot-value  w 'update) t)
  )

(defun run-db ()
  (setf *win* (make-instance 'draw-board))
  (glut:display-window *win*))


(defmacro with-win (&body body)
  `(progn
      (when *win*
         (setf (slot-value *win* 'df)
               (lambda ()
                  ,@body))
         (update *win*))))


;;(run-db)

;;(setf t1 (make-instance 'hello-window))
;;
;;(setf (slot-value t1 'df) 5)
;(slot-value t1 'df)
;(setf *gl-draw* 5)

;;(inspect *win*)
;; (setf (slot-value *win* 'df)
;;       (lambda ()
;;           (format t "Hello World!~A")))

;;(apply (slot-value *win* 'df) '(1))
;;(apply (slot-value *win* 'df) '(1))
;;(setf *win* (make-instance 'hello-window))

;; (with-win
;;     ;;(declare (ignore arg))
;;     (format t "Hello Word!~%"))

;; (macroexpand-1 '(with-win
;; 		 (format t "Hello Word!~%")))

;;(inspect *win*)
;;(slot-value *win* 'df)
;;(slot-value *win* 'update)

#|
(run-db)
(with-win
  (gl:color 1 1 1)
  (gl:with-primitive :polygon
    (gl:vertex 0.05 0.05 0)
    (gl:vertex 0.95 0.05 0)
    (gl:vertex 0.95 0.95 0)
    (gl:vertex 0.05 0.95 0)))

(with-win)
(setf *wiw* nil)
(gc)
;;(glut:post-redisplay)


sb-thread:*current-thread*;#<SB-THREAD:THREAD "worker" RUNNING {23C89679}>
(sb-thread:list-all-threads)
(inspect *win*) 
 (bordeaux-threads:make-thread
  (lambda ()
      (glut:display-window *win*))
  :name "glut")

|#

;;(inspect (cadr (sb-thread:list-all-threads)))
;;(load (merge-pathnames "draw-board01.lisp" "d:/WORK/lisp/learn/pkg/opengl/"))
;;(compile-file (merge-pathnames "draw-board01.lisp" "d:/WORK/lisp/learn/pkg/opengl/"))
;(defparameter *d* (merge-pathnames "WORK/lisp/learn/pkg/opengl/" (user-homedir-pathname)))
;(load (merge-pathnames "draw-board01.lisp"  *d*))
