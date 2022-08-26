# kaveh808-lessons-in-cl-opengl
Common Lisp lessons from keveh808 adapted for the cl-opengl library. They work on Linux and Windows

All lesson videos you can find: https://www.youtube.com/channel/UCHNK9EcrAwP7djlwQN4C_tg/videos

All lesson files are working, but they are not intended to be run as
separate lisp programs. All these programs are designed for research
programming and interaction with opengl from repl. The most convenient interaction
comes from emacs using slim (I haven't tried sly).
To work properly and download programs, you need to replace
the file download paths with the paths you use.
All the older lesson numbers load the previous ones along the chain.
Therefore, when loading, some functions and classes
performed in lessons are redefined.
The draw-board01.lisp file uses the path setting of the downloaded libraries
to download the freeglut file in windows. I put this library in a directory
D:/dll /, after which the cffi library can load it from there.


All examples are in commented blocks. All commands, including from.
the commented-out blocks are passed to the repl.

In deviation from the lessons of kaveh808, the launch takes place in two stages:
(run-db) creates a glut window in which the display function
is initially empty and waits for the definition of the lambda function associated with the variable df.
This variable is bound by a macro (with-win), which is still.
calls the window redraw function.
One of the problems was that the glut (glut:post-redisplay) function, when
called from repl, did not redraw the screen (this happens because
its call comes from another thread, launched by slime repl, for each
commands. Therefore, all redrawing takes place through setting the update flag,
which is checked in the idle function.
All work with draw-board consists in overriding the lambda functions of rendering
the opengl screen in the macro (with-win)
a typical set of commands for working with a draw-board consists of a sequence
of commands.

<pre>
(run-db)
(with-win
  (gl:color 1 1 1)
  (gl:with-primitive :polygon
    (gl:vertex 0.05 0.05 0)
    (gl:vertex 0.95 0.05 0)
    (gl:vertex 0.95 0.95 0)
    (gl:vertex 0.05 0.95 0)))
</pre>

Thus, we can execute arbitrary code in the draw-board window, which may
contain opengl commands.

However, the lessons of keveh808 are to teach a person to work not just with
opengl, and working with common lisp classes. Therefore, all graphical interaction
occurs through the structure of the classes scene, shape, renderer, point and others.
Therefore, the lambda function set in the with-win macro is the same in all lessons.
and the same:

<pre>
(with-win
  (draw *scene*))
</pre>

This is the second step to configure interaction with the draw-board window.
It begins to be used from lesson 01, where the basic classes are defined, for.
works with graphics.

In principle, they can be combined into one run function

<pre>
(define run ()
   (run-db)
   (with-win
       (draw *scene*)))
</pre>

but it's anyone who wants.

Further, all interaction takes place using macros:
<pre>
(with-redraw
    (clear-shapes *scene*))
(with-clear-and-redraw
   (add-shape *scene* (make-circle-shape 1.0  64))
   (add-shape *scene* (make-circle-shape 0.75 32))
   (add-shape *scene* (make-circle-shape 0.5  16))
   (add-shape *scene* (make-circle-shape 0.25 8)))
</pre>

which won't work if you don't execute the two commands I mentioned above:
(<pre>
run-db)
(with-win
   (draw *scene*))
</pre>

do not forget about this, because in the lesson files these commands are in the comments
and can be found anywhere.

<pre>
drawboard01.lisp is the first downloadable file for all lessons defined in it
                 the functions create a window in which all the
                 opengl commands
first-opengl.lisp trial opengl application where I worked out the possibility
                  building an opengl whiteboard for drawing, executing commands
                  opengl
lesson01.lisp	       Points & Shapes  
lesson02.lisp          Generating Shapes
lesson03.lisp          Transforms
lesson04.lisp          Transforming Shapes
lesson05.lisp          Groups shapes
lesson06.lisp          Modeling with use groups
lesson07.lisp          Colors
lesson08.lisp          Colors
lesson09.lisp          Renderers Part 1
lesson10.lisp          Renderers Part 2
lesson11.lisp          Animation
lesson12.lisp          Animation

load-examples.lisp file for downloading examples from cl-opengl binding, it has
                   an example of running a command that will allow you to find out 
                   all the possibilities opengl of your graphics card.
repl-board.lisp    file where I worked out the possibilities of interacting with the window.
                   glut launched via repl and issuing commands to it from
                   lisp perl
</pre>



Russian comments:

Все файлы уроков являются рабочими, но они не предназначены для запуска в виде
отдельных программ лисп. Все эти программы предназначены, для исследовательского
программирования и взаимодействия с opengl из repl. Максимально удобное взаимодействие
происходит из emacs с помощью slim(sly я не пробовал).
Для правильной работы и загрузки программ вам надо заменить пути загрузки
файлов, на используемые вами пути.
Все старшие номера уроков загружают предыдущие  по цепочке.
Поэтому при загрузке происходит переопределения некоторых функций и классов
выполняемые в уроках.
В файле draw-board01.lisp используется установка пути загружаемых библиотек
для загрузки файла freeglut в windows. Я поместил эту библиотеку в директорию
D:/dll/, после чего библиотека cffi может её грузить от туда.


Все примеры находятся в закомментированных блоках. Все комманды, в том числе и из 
закомментированных блоков, передаются в repl.

В отклонении от уроков kaveh808 запуск происходит в два этапа:
(run-db) создает glut окно, в котором функция display изначально явлется
пустой и ждет определения лямбда функции связываемой с переменной df.
Эту переменную связвает макрос (with-win), который при этом еще 
вызвает функцию перерисовки окна.
Одна из проблем заключалась в том, что функция glut (glut:post-redisplay) при
вызове из repl не выполняла перерисовку экрана(это происходит потому что
её вызов происходит из другого потока, запускаемого slime repl, для каждой 
комманды. Поэтому вся перерисовка происходит через установку флага update,
проверяемого в функии idle.
Вся работа с draw-board состоит в переопределении лямбда функций отрисовки
экрана opengl в макросе (with-win)
типичный набор комманд для работы с draw-board состоит из последовательности
комманд.

<pre>
(run-db)
(with-win
  (gl:color 1 1 1)
  (gl:with-primitive :polygon
    (gl:vertex 0.05 0.05 0)
    (gl:vertex 0.95 0.05 0)
    (gl:vertex 0.95 0.95 0)
    (gl:vertex 0.05 0.95 0)))
</pre>

Таким образом мы можем выполнять в окне draw-board произвольный код, который может
содержать команды opengl.

Однако уроки keveh808 состоят в том чтобы обучить человека работе не просто с
opengl, а работе с классами common lisp. Поэтому все графическое взаимодействие
происходит через структуру классов scene, shapе, renderer, point и других.
Поэтому лямбда функция устанавливаемая в макросе with-win, во всех уроках одна 
и таже:
<pre>
(with-win
  (draw *scene*))
</pre>
  
Это и есть второй шаг, для настройки взаимодействия с окном draw-board.
Она начинает использоваться с урока 01, где и определяются базовые классы, для 
работы с графикой.

В принципе их можно объединить в одну фукнцию run
<pre>
(define run ()
   (run-db)
   (with-win
       (draw *scene*)))
</pre>
но это кто как хочет.

Далее все взаимодействие происходит с помощью макросов:
<pre>
(with-redraw
    (clear-shapes *scene*))
(with-clear-and-redraw
   (add-shape *scene* (make-circle-shape 1.0  64))
   (add-shape *scene* (make-circle-shape 0.75 32))
   (add-shape *scene* (make-circle-shape 0.5  16))
   (add-shape *scene* (make-circle-shape 0.25 8)))
</pre>

которые не будут работать если вы не выполните две указанные выше мной комманды:
<pre>
(run-db)
(with-win
   (draw *scene*))
</pre>

не забывайте об этом, потому что в файлах уроков эти комманды стоят в комментариях
и могут находитсья где угодно.

<pre>
draw-board01.lisp      первый загружаемый файл для всех уроков, определяемые в нем
                       функции создают окно, в котором происходит отрисовка всех
                       команд opengl
first-opengl.lisp      пробное приложение opengl где я отрабатывал возможность
                       построения opengl доски для рисования, выполнения команд
                       opengl
lesson01.lisp	       Points & Shapes  
lesson02.lisp          Generating Shapes
lesson03.lisp          Transforms
lesson04.lisp          Transforming Shapes
lesson05.lisp          Groups shapes
lesson06.lisp          Modeling with use groups
lesson07.lisp          Colors
lesson08.lisp          Colors
lesson09.lisp          Renderers Part 1
lesson10.lisp          Renderers Part 2
lesson11.lisp          Animation
lesson12.lisp          Animation

load-examples.lisp     файл загрузки примеров из биндинга cl-opengl, в нем есть
                       пример запуска команды, которая позволит узнать все возможности
                       opengl вашей видеокарты.
repl-board.lisp        файл где я отрабатывал возможности взаимодействия с окном 
                       glut запущеным через repl и выдаечей в него команд из 
                       lisp repl
</pre>


