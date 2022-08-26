;;  Groups
;;(defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/" (user-homedir-pathname)))
;;(load (merge-pathnames "lesson05.lisp"  *d*))
(eval-when (:compile-toplevel :load-toplevel :execute)
   (if (eq (uiop:operating-system) :win)
       (progn
          (defparameter *d* (merge-pathnames "WORK/lisp/learn/pkg/opengl/"
                                             "D:/")))
       (progn
          (defparameter *d* (merge-pathnames "work/lisp/learn/pkg/opengl/"
                                             (user-homedir-pathname)))))
   (load (merge-pathnames "lesson05.lisp"  *d*)))

;; моделирование с использованием групп ==========================================================

;;создает группу - строку фигур
;;здесь используется трюк, для каждой фигуры shape создается группа
;;и она уже перемещается(translate) а фигура остается неизменной
;; это может быть полезно создания групп очень сложных фигур.
(defun make-row-group (n spacing shape)
   (let ((row '()))
      (dotimes (i n)
         (push (make-instance
                'group :children (list shape)
                       :transform (make-instance 'transform
                                                 :translate (p* spacing
                                                                (p! i i))))
               row))
      (make-instance 'group :children row)))

;;version with loop macro
#||
(defun make-row-group (n spacing shape)
   (make-instance
    'group
    :children
    (loop for i to n
          collect (make-instance
                   'group :children (list shape)
                          :transform (make-instance 'transform
                                                    :translate (p* spacing
                                                                   (p! i i)))))))
|#


#||
;;мы используем make-row-group для создания строки группы объектов
(progn
   (defparameter *row-group* nil)
   (with-clear-and-redraw
      (setf *row-group* (make-row-group 10 (p! 0.2 0.0)
                                        (make-circle-shape 0.2 16)))
      (translate-by *row-group* (p! -0.9 0.0))
      (add-shape *scene* *row-group*)))
;; тут все параметры сложно увязаны, кругов 10, каждый диаметром 0.2, всю группу
;;перемещаем в точку -0.9, значит крайний круг будет касаться точки -1.0, и все 10
;;кругов точно уместятся в диапазон от -1 до 1.
(print-hierarchy *scene*)
||#

;;мы можем создать группу строк содеращую группы строк, создав сетку
#||
(progn
   (defparameter *grid-group* nil)
   (with-clear-and-redraw
      (setf *grid-group* (make-row-group 10 (p! 0.0 0.2) *row-group*))
      (translate-by *grid-group* (p! 0.0 -0.9))
      (add-shape *scene* *grid-group*)))
(print-hierarchy *scene*)
||#

;;обобщим данный подход для создания групп определенной фигуры в заданных точках
(defun scatter-group (shape-fn points)
   (make-instance
    'group
    :children
    (mapcar (lambda (p)
               (translate-to (funcall shape-fn) p))
            points)))

;;проверим на трех точках
#||
(with-clear-and-redraw
   (add-shape *scene*
              (scatter-group (lambda () (make-hexagon-shape 1.0))
                             (list (p! -.5 -.433)
                                   (p!  .5 -.433)
                                   (p!  0   .433)))))
;;и все таки здесь мы создали 3 разных гексагона, а если бы мы хотели использовать
;;а для трех видов надо было бы так:
(with-clear-and-redraw)
(with-clear-and-redraw
   (let ((shape (make-hexagon-shape 1.0)))
      (add-shape *scene*
                 (scatter-group (lambda () (make-instance 'group
                                                          :children (list shape) ))
                                (list (p! -.5 -.433)
                                      (p!  .5 -.433)
                                      (p!  0   .433))))))
(print-hierarchy *scene*)
(with-clear-and-redraw
   (let* ((shape (make-hexagon-shape 1.0))
          (triangle (make-eql-tri-shape 1.0)))
      (scale-by triangle 1.1)
      (format t "triangle: ~a~%" triangle)
      (add-shape *scene*
                 (scatter-group (lambda () (make-instance 'group
                                                          :children (list shape) ))
                                (points triangle)))))
(print-hierarchy *scene*)
;;забыл совсем: трансляцией и маштабированием мы не меняем точек фигуры!
;;мы просто добавляем преобразование для opengl
(defparameter ps1 (points (make-eql-tri-shape (* 2 0.433))))
;;scale points
(let ((sp (p! 1.1 1.1)))
   (mapcar (lambda (p) (p* p sp)) ps1))
;;translate points
(let ((sp (p! 0.0 -.17)))
   (mapcar (lambda (p) (p+ p sp)) ps1))
(/ 0.5 0.37) ;1.3513514
(/ 0.433 0.2165) ;2.0
;;какое то не регулярное преобразование.
||#

;;make recursive group
(defun make-hex-tri-group (levels)
   (scale-to (scatter-group (lambda ()
                               (if (= 0 levels)
                                   (make-hexagon-shape 1.0)
                                   (make-hex-tri-group (- levels 1))))
                            (list (p! -.5 -.433)
                                  (p!  .5 -.433)
                                  (p!   0  .433)))
             0.5))

#||
(with-clear-and-redraw
   (add-shape *scene*
              (scale-to (make-hex-tri-group 0)
                        1.0)))
(with-clear-and-redraw
   (add-shape *scene*
              (scale-to (make-hex-tri-group 1)
                        1.0)))
(with-clear-and-redraw
   (add-shape *scene*
              (scale-to (make-hex-tri-group 2)
                        1.0)))
(with-clear-and-redraw
   (add-shape *scene*
              (scale-to (make-hex-tri-group 4)
                        1.0)))
||#

(defun make-square-x-group (levels)
   (scale-to (scatter-group (lambda ()
                               (if (= 0 levels)
                                   (make-square-shape 1.5)
                                   (make-square-x-group (- levels 1))))
                            (list (p! -1.0 -1.0)
                                  (p!  1.0  1.0)
                                  (p!  1.0 -1.0)
                                  (p! -1.0  1.0)
                                  (p! -2.0 -2.0)
                                  (p!  2.0  2.0)
                                  (p!  2.0 -2.0)
                                  (p! -2.0  2.0)))
             0.25))

#||
(with-clear-and-redraw
   (add-shape *scene*
              (scale-to (make-square-x-group 0)
                        0.33)))
(with-clear-and-redraw
   (add-shape *scene*
              (scale-to (make-square-x-group 1)
                        0.33)))
(with-clear-and-redraw
   (add-shape *scene*
              (scale-to (make-square-x-group 2)
                        0.33)))
||#

;;обобщим функцию рекурсивно создающую группу
(defun make-recursive-group (levels base-shape-fn points scaling)
   (scale-to (scatter-group (lambda ()
                               (if (= 0 levels)
                                   (funcall base-shape-fn)
                                   (make-recursive-group
                                    (- levels 1) base-shape-fn
                                    points scaling)))
                            points)
             scaling))

#||
(with-clear-and-redraw
   (add-shape *scene* (make-recursive-group 0
                                            (lambda () (make-square-shape 0.8))
                                            (points (make-hexagon-shape 4.0))
                                            0.333)))
(with-clear-and-redraw
   (add-shape *scene* (make-recursive-group 2
                                            (lambda () (make-square-shape 0.8))
                                            (points (make-hexagon-shape 4.0))
                                            0.333)))
(with-clear-and-redraw
   (add-shape *scene* (make-recursive-group 0
                                            (lambda () (make-spiral-shape 0.5 16))
                                            (points (make-spiral-shape 5.0 32 1))
                                            0.3)))
(with-clear-and-redraw
   (add-shape *scene* (make-recursive-group 1
                                            (lambda () (make-spiral-shape 0.5 16))
                                            (points (make-spiral-shape 5.0 16 1))
                                            0.3)))

(with-clear-and-redraw
   (add-shape *scene* (make-recursive-group 0
                                            (lambda () (make-hexagon-shape 1.0))
                                            (points (make-hexagon-shape 2.0))
                                            0.5)))
(with-clear-and-redraw
   (add-shape *scene* (make-recursive-group 2
                                            (lambda () (make-hexagon-shape .9))
                                            (points (make-hexagon-shape 2.0))
                                            0.5)))

(with-clear-and-redraw
   (add-shape *scene* (make-recursive-group 0
                                            (lambda () (make-pentagon-shape .9))
                                            (points (make-pentagon-shape 2.0))
                                            0.4)))
(with-clear-and-redraw
   (add-shape *scene* (make-recursive-group 2
                                            (lambda () (make-pentagon-shape .9))
                                            (points (make-pentagon-shape 2.0))
                                            0.4)))
(with-clear-and-redraw
   (add-shape *scene* (make-recursive-group 1
                                            (lambda () (make-circle-shape 0.9 18))
                                            (points (make-circle-shape 6.0 16))
                                            0.25)))
||#

;;реализация обходчика дерева с добавлением  аргумента предиката.
;;выполняющего какую то проверку фигуры
(defmethod do-hierarhy ((self shape) func &key (test nil))
   (when (or (null test) (funcall test self))
      (funcall func self))
   self)

(defmethod do-hierarhy :after ((self group) func &key (test nil))
   (dolist (child (children self))
      (do-hierarhy child func :test test))
   self)

#||
*group-2*
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

;;маштабируем только треугольники в группе.
(with-redraw
   (do-hierarhy *group-2*
      (lambda (s) (scale-by s 1.2))
      :test (lambda (s) (and (typep s 'polygon-shape)
                             (= 3 (length (points s)))))))
||#

(defmethod is-leaf? ((self shape))
   t)
(defmethod is-leaf? ((self group))
   nil)

(defun randomize-size (shape lo hi)
   (let* ((scale (rand2 lo hi)))
      (scale-by (transform shape) scale)))

#||
(with-clear-and-redraw
   (add-shape *scene* (scale-to (make-hex-tri-group 1) 1.0)))
(with-clear-and-redraw
   (add-shape *scene* (scale-to (make-hex-tri-group 2) 1.0)))
;;применим рандомизацию к листьям в иерархии(т.е к фигурам а не группам)
(with-redraw
   (do-hierarhy (first (shapes *scene*))
      (lambda (shape) (randomize-size shape 0.5 1.5))
      :test #'is-leaf?))
||#
#||
(with-clear-and-redraw
   (add-shape *scene* (scale-to (make-hex-tri-group 2) 1.0)))
;;применим рандомизацию ко всем узлам в иерархии
(with-redraw
   (do-hierarhy (first (shapes *scene*))
      (lambda (shape) (randomize-size shape 0.8 1.2))))
||#

;;jittering (случайное смещение) значения трансформации фигуры
(defmethod jitter-translate ((self shape) (jitter point))
   (translate-by (transform self)
                 (p! (rand1 (x jitter)) (rand1 (y jitter))))
   self)
(defmethod jitter-rotate ((self shape) (jitter number))
   (rotate-by (transform self) (rand1 jitter))
   self)
(defmethod jitter-scale ((self shape) (jitter number))
   (scale-by (transform self) (+ 1.0 (rand1 jitter)))
   self)


(defun make-recursive-group-2 (levels base-shape-fn points
                               scaling translate rotate size)
   (let ((group (scatter-group
                 (lambda ()
                    (if (= 0 levels)
                        (funcall base-shape-fn)
                        (make-recursive-group-2
                         (- levels 1) base-shape-fn points
                         scaling translate rotate size)))
                 points)))
      (jitter-translate group translate)
      (jitter-rotate    group rotate)
      (jitter-scale     group size)
      (scale-by         group scaling)))


(defun make-wobbly-cross (levels)
   (make-recursive-group-2
    levels
    (lambda () (make-square-shape 0.8))
    (list (p!  0.0  0.0)
          (p! -1.0  0.0)
          (p!  1.0  0.0)
          (p!  0.0 -1.0)
          (p!  0.0  1.0)
          (p! -2.0  0.0)
          (p!  2.0  0.0)
          (p!  0.0 -2.0)
          (p!  0.0  2.0))
    0.25
    (p! 0.0 0.0)
    10.0
    0.5))

(defun randomize-leaf-sizes (group lo hi)
   (do-hierarhy group (lambda (shape) (randomize-size shape lo hi))
      :test #'is-leaf?))
(defun randomize-node-sizes (group lo hi)
   (do-hierarhy group (lambda (shape) (randomize-size shape lo hi))))

#||
(progn
   (defparameter *cross* (scale-to (make-wobbly-cross 2) .33))
   (with-clear-and-redraw
      (add-shape *scene* *cross*)))
(with-redraw
   (randomize-leaf-sizes *cross* 0.5 1.5))
(with-redraw
   (randomize-node-sizes *cross* 0.8 1.2))

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


