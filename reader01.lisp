
(require :cl-opengl)
(require :cl-glu)

(defparameter *list-gl-commands*
	       '((glEnable       gl:Enable)
		 (glDisable      gl:Disable)
		 (glLineWidth    gl:line-width)
		 (glBegin        gl:Begin)
		 (glEnd          gl:End)
		 (glColor3f      gl:Color)
		 (glVertex3f     gl:Vertex)
		 (glLightfv      gl:Light)
		 (glMaterialfv   gl:Material)
		 (glLightModeli  gl:light-model)
		 (glClearColor   gl:clear-color)
		 (glClear        gl:Clear)
		 (glCullFace     gl:cull-face)
		 (glMatrixMode   gl:matrix-mode)
		 (glLoadIdentity gl:load-identity)
		 (gluPerspective glu:perspective)
		 (gluLookAt      glu:look-at)
		 (glTranslatef   gl:Translate)
		 (glRotatef      gl:Rotate)
		 (glFlush        gl:Flush)
		 (glPushMatrix   gl:push-matrix)
		 (glScalef       gl:Scale)
		 (glPopMatrix    gl:pop-matrix)
		 (glPointSize    gl:point-size)
		 (glShadeModel   gl:shade-model)
		 (glPolygonMode  gl:polygon-mode)
		 (glColorMaterial gl:color-material)
		 ))

(defparameter *gl-commands*
  (let ((ht (make-hash-table :size 100 :test 'eq)))
    (dolist (cmd *list-gl-commands*)
      (setf (gethash (first cmd) ht) (second cmd)))
    ht)) 

(set-dispatch-macro-character #\# #\_
			      #'(lambda (stream char1 char2)
				  (declare (ignore char1 char2))
				  (let* ((in-cmd (read stream t nil t))
					 (cmd (gethash in-cmd *gl-commands* nil)))
				    (if cmd
					cmd
					(error "Don't translate opengl command ~a" in-cmd)))))


;;(#_glPointSize 9.0)

(macroexpand-1 '(#_glPointSize 9.0)) ;(CL-OPENGL-BINDINGS:POINT-SIZE 9.0)

(defparameter *list-gl-flags*
  '((GL_LINES                      :LINES)
    (GL_POSITION                   :POSITION)
    (GL_AMBIENT                    :AMBIENT)
    (GL_DIFFUSE                    :DIFFUSE)
    (GL_SPECULAR                   :SPECULAR)
    (GL_SHININESS                  :SHININESS)
    (GL_FRONT_AND_BACK             :FRONT-and-back)
    (GL_CULL_FACE                  :CULL-FACE)
    (GL_LIGHT_MODEL_TWO_SIDE       :LIGHT-model-two-side)
    (GL_FALSE                      :FALSE)
    (GL_TRUE                       :TRUE)
    (GL_LIGHTING                   :LIGHTING)
    (GL_COLOR_BUFFER_BIT           :COLOR-buffer-bit)
    (GL_DEPTH_BUFFER_BIT           :DEPTH-BUFFER-bit)
    (GL_DEPTH_TEST                 :DEPTH-TEST)
    (GL_BACK                       :BACK)
    (GL_PROJECTION                 :PROJECTION)
    (GL_MODELVIEW                  :MODELVIEW)
    (GL_LINE_LOOP                  :LINE-LOOP)
    (GL_LINE_STRIP                 :LINE-STRIP)
    (GL_POINTS                     :POINTS)
    (GL_SMOOTH                     :SMOOTH)
    (GL_FLAT                       :FLAT)
    (GL_FILL                       :FILL)
    (GL_POLYGON                    :POLYGON)
    (GL_LINE                       :LINE)
    ))

(defparameter *gl-flags*
  (let ((ht (make-hash-table :size 100 :test 'eq)))
    (dolist (cmd *list-gl-flags*)
      (setf (gethash (first cmd) ht) (second cmd)))
    ht)) 

(set-dispatch-macro-character #\# #\$
			      #'(lambda (stream char1 char2)
				  (declare (ignore char1 char2))
				  (let* ((in-flg (read stream t nil t))
					 (flg (gethash in-flg *gl-flags* nil)))
				    (if flg
					flg
					(error "Don't translate opengl flag ~a" in-flg)))))

