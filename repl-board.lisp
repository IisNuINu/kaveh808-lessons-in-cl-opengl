;;(require 'bordeaux-threads)
(asdf:load-system :cffi)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (format t "load cffi~%")
  (asdf:load-system :cffi)
  ;;(require :)
  (if (eq (uiop:operating-system) :win)
      (progn
        (setf  cffi:*foreign-library-directories*
               (list (parse-namestring "D:/dll/"))))
      ))
;;(find-package "cl-cffi")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (format t "load cl-glut~%")
  (require :cl-glut))

(defparameter *win* nil)
;

(defclass repl-board (glut:window)
  ((df :initform nil)
   ;(arg :initform nil)
   (update :initform nil))
  
  (:default-initargs
   :pos-x 50 :pos-y 50 :width 600 :height 600
   :mode '(:single :rgb) :title "repl-board"))

(defmethod glut:display-window :before ((w repl-board))
  ;; Select clearing color.
  (gl:clear-color 0 0 0 0)
  ;; Initialize viewing values.
  (gl:matrix-mode :projection)
  (gl:load-identity)
  (gl:ortho -1 1 -1 1 -1 1))

(defmethod glut:display ((w repl-board))
  (gl:clear :color-buffer)
  (let ((df   (slot-value w 'df))) 
      (when (functionp df)
          (apply df nil)))   ;;(apply df arg)
  ;; Start processing buffered OpenGL routines.
  (gl:flush))


(defmethod glut:idle ((w repl-board))
  (when (slot-value w 'update)
    ;;(format t "in idle ~%")
    (setf (slot-value w 'update) nil)
    (glut:post-redisplay)))

(defmethod glut:visibility ((w repl-board) state)
  (case state
    (:visible (glut:enable-event w :idle))
    (t (glut:disable-event w :idle))))


(defmethod update ((w repl-board))
  (setf (slot-value  w 'update) t)
  )

(defun rb ()
  (setf *win* (make-instance 'repl-board))
  (glut:display-window *win*))


(defmacro with-win (&body body)
  `(progn
     (setf (slot-value *win* 'df)
	   (lambda ()
             ,@body))
     (update *win*)))


;;(rb)

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

(when nil
(with-win
  (gl:color 1 1 1)
  (gl:with-primitive :polygon
    (gl:vertex 0.05 0.05 0)
    (gl:vertex 0.95 0.05 0)
    (gl:vertex 0.95 0.95 0)
    (gl:vertex 0.05 0.95 0)))

;;(glut:post-redisplay)


sb-thread:*current-thread*;#<SB-THREAD:THREAD "worker" RUNNING {23C89679}>
(sb-thread:list-all-threads)
(inspect *win*) 
;; (bordeaux-threads:make-thread
;;  (lambda ()
;;      (glut:display-window *win*))
;;  :name "glut")
)

;;(inspect (cadr (sb-thread:list-all-threads)))
;;(load (merge-pathnames "repl-board.lisp" "d:/WORK/lisp/learn/pkg/opengl/"))
;(defparameter *d* (merge-pathnames "WORK/lisp/learn/pkg/opengl/"(user-homedir-pathname)))
;(load (merge-pathnames "repl-board.lisp"  *d*))
