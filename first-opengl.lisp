;;(asdf:load-system :cffi)
(require 'bordeaux-threads)

(eval-when (:compile-toplevel :load-toplevel :execute)
    (require :cffi)
    (if (eq (uiop:operating-system) :win)
        (progn
            (setf  cffi:*foreign-library-directories*
                   (list (parse-namestring "D:/dll/"))))
        ))
(find-package "cl-cffi")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (format t "load cl-glut~%")
  (require :cl-glut))

(defparameter *win* nil)
;

(defclass hello-window (glut:window)
  ((df :initform nil)
   ;(arg :initform nil)
   (update :initform nil))
  
  (:default-initargs
   :pos-x 100 :pos-y 100 :width 250 :height 250
   :mode '(:single :rgb) :title "hello.lisp"))

(defmethod glut:display-window :before ((w hello-window))
  ;; Select clearing color.
  (gl:clear-color 0 0 0 0)
  ;; Initialize viewing values.
  (gl:matrix-mode :projection)
  (gl:load-identity)
  (gl:ortho 0 1 0 1 -1 1))

(defmethod glut:display ((w hello-window))
  (gl:clear :color-buffer)
  ;; Draw white polygon (rectangle) with corners at
  ;; (0.25, 0.25, 0.0) and (0.75, 0.75, 0.0).
  (let ((df   (slot-value w 'df))
        ) ;;(arg  (slot-value w 'arg))
      (when (functionp df)
          (apply df nil)))   ;;(apply df arg)
  ;; Start processing buffered OpenGL routines.
  (gl:flush))


(defmethod glut:idle ((w hello-window))
  (when (slot-value w 'update)
    (format t "in idle ~%")
    (setf (slot-value w 'update) nil)
    (glut:post-redisplay)))

(defmethod glut:visibility ((w hello-window) state)
  (case state
    (:visible (glut:enable-event w :idle))
    (t (glut:disable-event w :idle))))

;; (cffi:defcallback idle :void ()
;;   (format t "in idle ~%")
;;   (when (slot-value *win* 'update)
;;     (setf (slot-value *win* 'update) nil)
;;     (glut:post-redisplay)))

;; (cffi:defcallback visible :void ((visibility glut:visibility-state))
;;   (format t "in visible ~A~%" visibility)
;;   (if (eq visibility :visible)
;;       (glut:idle-func (cffi:callback idle))
;;       (glut:idle-func (cffi:null-pointer))))

(defmethod update ((w hello-window))
  (setf (slot-value  w 'update) t)
  )



(defun rb-hello ()
  ;;(glut:visibility-func (cffi:callback visible))
  (setf *win* (make-instance 'hello-window))
  ;;(glut:enable-event *win* :idle)
  (glut:display-window *win*))

(rb-hello)

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

(defmacro with-win (&body body)
  `(progn
     (setf (slot-value *win* 'df)
	   (lambda ()
             ,@body))
     (update *win*)))


;;(setf *win* (make-instance 'hello-window))

(with-win
    ;;(declare (ignore arg))
    (format t "Hello Word!~%"))

(macroexpand-1 '(with-win
		 (format t "Hello Word!~%")))

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
;;(load (merge-pathnames "first-opengl.lisp" "d:/WORK/lisp/learn/pkg/opengl/"))
;;(load "d:/WORK/lisp/learn/pkg/opengl/")
