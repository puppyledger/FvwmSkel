
" START PDT 

" PDT Default VIM preferences. These work fairly 
" well with perltidy, but you may do with them as 
" you please. Note that there are many features 
" that VIM has for color coding etc. The author 
" of Perl PDT finds that the mayhem these cause 
" when you are one day forced to use a non-fancy 
" vi to be not worth the hassle of getting used 
" to them. YMMV. 

" no bells

:set noeb
:set noflash
:set t_vb=0

" autoindent, tabs are 3 characters, 
" cut and paste tabs not spaces. 

:set autoindent
:set smartindent
:set ts=3
:set tabstop=3
:set softtabstop=3
:set smarttab
:set shiftwidth=3
:set shiftround
:set paste
:set number
:set clipboard=unnamedplus

"  :set go+=a
" :set mouse+=a

:function! PTAB() 
	:%s/^            /\t\t\t\t/
	:%s/^         /\t\t\t/
	:%s/^      /\t\t/
	:%s/^   /\t/
:endfunction 

" we use our own backup system, so vi's is redundant

:set noswapfile
:set nobackup

" non-system globals

:let local_paragraph_width=79
:hi MatchParen cterm=underline ctermbg=none ctermfg=none 

" AUTOCOMPLETE, see the TODO in project Autocomplete. it lays a roadmap. 

"  AutoCompl Plugin
" :source ~/.fvwm/vim/acp.vim

" Python Save Python: writes the file makes a backup of the current version, runs it, provides break window, 
" then copies it to production

" SAVEPY runs the current program and blips the output for 1 sec to verify good code. 
" RUNPY  runs the current program and leaves the results up

:command -nargs=0 W :call SAVEPY()
:command -nargs=0 R :call RUNPY()
" :command -nargs=0 R :call BANG()

:function SAVEPY(...) 
	:w 
	:let $WORKINGFILE = expand('%:t') 
   	:silent :!savepy $WORKINGFILE
	:redraw! 
:endfunction

:function RUNPY(...) 
	:w 
	:let $WORKINGFILE = expand('%:t') 
   	:silent :!runpy $WORKINGFILE
	:redraw! 
:endfunction

"
" Python UNO Method Primitives: 
"
" usage:  :U (setget) [arg1 arg2 arg3]
"
" there are many code generators that can build method primitives of different 
" types. Some just help make layout faster. Others are more intelligent.  
" You can experiment, copy and modify as necessary
"

:command -nargs=1 U :call PDT_U(<f-args>)

:function PDT_U(...) 
   :let oldshell = $SHELL
   :let $RTFN = system("rtfn")
   :let templatecmd = "uno_" . a:1
   :let &shell=templatecmd
   :sh
   :execute '-1read ' . expand($RTFN)
   :let &shell = oldshell
   :let $DELRTFN = system("rm $RTFN")
   :let $RTFN=""
:endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 
" Perl Object Primitives: 
"
" usage:  :P (o|t|r|q|x)
"
" o Object Class: This object class is either autolithic self 
" registering, or pluralistic (record/widget style) non-self- 
" registering.  
"
" t Template Class: This is a self loading template object that 
" uses HTML::Template syntax in its respective DATA filehandle. 
"
" r Root Class: Root classes allow for common method inhertance 
" for a block of Pdt::O classes, but return a Factory class when 
" constructed directly. Use in combo with Factories makes API  
" layout faster. 
"
" q Query Class: These classes are optimized for use with the 
" DBI 
"
" x eXport Class: Sometimes you just want to share some functions.
" This is a package to do that. 
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

:command -nargs=1 P :call PDT_P(<f-args>)

:function PDT_P(...) 
	:let oldshell = $SHELL
	:let $RTFN = system("rtfn")
	:let mkrtfn = system("touch $RTFN")
	:let $LASTEDITFILE = expand("%:p")
	:let templatecmd = "urxvt -e primitive_" . a:1
  	:let &shell=templatecmd
  	:sh 
  	:execute '-1read ' . expand($RTFN)
  	:let &shell = oldshell 
	:let $DELRTFN = system("rm $RTFN")
	:let $RTFN=""
:endfunction 

"
" Method Primitives: 
"
" usage:  :M (setget|query|here|format|group|stacksuper) [arg1 arg2 arg3]
"
" bulk method generators. Perl has several specialized structures such as 
" here documents, and formats, as well as things like DBI prepare statements 
" etc. These are often built in bulk, so we have templates that can do that. 
"

:command -nargs=1 M :call PDT_M(<f-args>)

:function PDT_M(...) 
   :let oldshell = $SHELL
   :let $RTFN = system("rtfn")
	:let mkrtfn = system("touch $RTFN")
	:let $LASTEDITFILE = expand("%:p")
	:let templatecmd = "urxvt -e method_" . a:1
   :let &shell=templatecmd
   :sh
   :execute '-1read ' . expand($RTFN)
   :let &shell = oldshell
   :let $DELRTFN = system("rm $RTFN")
   :let $RTFN=""
:endfunction

"
" Factory Primitives:
"
" usage:  :F (a|p)
"
" Factory primitives for autolith, and plurolith type objects. It is 
" expected that in most cases an API will cluster all or mostly either 
" autolith or plurolith type classes. Factories read the package 
" statements from all files in the target directory, and write an 
" accessor class for all of those objects. Factories ignore any package 
" that has the word EXPORTONLY in a comment in the package line. 
" This automatically prunes type "x" primitives, but the word EXPORTONLY  
" can be added to the package line of any other class to prevent 
" inclusion. Factories are generally named <rootclass>::Factory 
" and if used downstream from a :P r primitive template, they will 
" be handed back instead of your root API class when it is 
" constructed. 
"
"

" :source ~/.vimpdtrc

:command -nargs=1 F :call PDT_F(<f-args>)

:function PDT_F(...)
	:let oldshell = $SHELL
	:let $RTFN = system("rtfn")
	:let mkrtfn = system("touch $RTFN")
	:let $LASTEDITFILE = expand("%:p")
	:let templatecmd = "urxvt -e factory_" . a:1
   :let &shell=templatecmd
   :sh
   :execute '-1read ' . expand($RTFN)
   :let &shell = oldshell
	:let $DELRTFN = system("rm $RTFN")
	:let $RTFN=""
:endfunction

"
" User Templates: 
"
" usage:  :T <packagename> 
"
" The base program for the Pdt IDE is called "pdt"
" and it is a templating program. Most of the primitive,  
" factory, and method generators above use "pdt" as 
" the means of providing a question dialog. You can 
" run template objects and include their output 
" directly by simply stating their class. Typically 
" if you find this useful, it is trivial to convert 
" any such call to one of the primitives above by 
" just wrapping the call to the pdt program with a 
" bash or perl script, and naming it appropriately. 
"

:command -nargs=1 T :call PDT_T(<f-args>)

:function PDT_T(...)
   :let oldshell = $SHELL
   :let $RTFN = system("rtfn")
	:let mkrtfn = system("touch $RTFN")
	:let $LASTEDITFILE = expand("%:p")
   :let templatecmd = "pdt " . a:1
   :let &shell=templatecmd
   :sh
   :execute '-1read ' . expand($RTFN)
   :let &shell = oldshell
   :let $DELRTFN = system("rm $RTFN")
   :let $RTFN=""
:endfunction

"
" PDT Callback Generators:
"
" usage:  :C (cbmap|cbpub|cbcmd|cbprepare) 
"
" Callback read the current program you are 
" writing, and generate code reference tables 
" for all of the respective functions. They 
" conform to different rules depending on 
" intent. For exampple cbmap ignores 
" leading "_"  while cbprepare ONLY gathers 
" methods with a leading "_". This allows 
" runtime seperation and batching of function 
" calls. 
"

:command -nargs=1 C :call PDT_C(<f-args>)

:function PDT_C(...)
   :let oldshell = $SHELL
   :let $RTFN = system("rtfn")
	:let mkrftn = system("touch $RTFN")
	:let $LASTEDITFILE = expand("%:p")
   :let templatecmd = a:1 
   :let &shell=templatecmd
   :sh 
   :execute '-1read ' . expand($RTFN)
   :let &shell = oldshell
"	:let $DELRTFN = system("rm $RTFN")
   :let $RTFN=""
:endfunction

 
" Encoding Primitives:
"
" Sometimes files need to be imported into the source in an encoded 
" format. These method primitives specialize in storing encoded data. 
"
" usage:  :E (<encoding> <filename>) 
"
" available encoding types: base64 
"

:command -nargs=1 E :call PDT_E(<f-args>)

:function PDT_E(...)
   :let oldshell = $SHELL
   :let $RTFN = system("rtfn")
	:let mkrtfn = system("touch $RTFN")
   :let templatecmd = "encode_" . a:1
   :let &shell=templatecmd
   :sh
   :execute '-1read ' . expand($RTFN)
   :let &shell = oldshell
   :let $DELRTFN = system("rm $RTFN")
   :let $RTFN=""
:endfunction

"
" Browsing Tools:
"
" usage:  :B (class|field|method|related) [arg1 arg2 arg3]
"
" browsing tools provide for browsing various class types. 
"

:command -nargs=1 B :call PDT_B(<f-args>)

:function PDT_B(...)
   :let oldshell = $SHELL
   :let $RTFN = system("rtfn")
	:let mkrtfn = system("touch $RTFN")
   :let templatecmd = "browse_" . a:1
   :let &shell=templatecmd
   :sh
   :execute '-1read ' . expand($RTFN)
   :let &shell = oldshell
   :let $DELRTFN = system("rm $RTFN")
   :let $RTFN=""
:endfunction

"
" PDT Help Information:
"
" usage: H (list, ... ) 
"

:command -nargs=1 H :call PDT_H(<f-args>)

:function PDT_H(...)
   :let oldshell = $SHELL
   :let $RTFN = system("rtfn")
	:let mkrtn = system("touch $RTFN")
   :let templatecmd = "pdthelp " . a:1
   :let &shell=templatecmd
   :sh 
   :execute '-1read ' . expand($RTFN)
   :let &shell = oldshell
   :let $DELRTFN = system("rm $RTFN")
   :let $RTFN=""
:endfunction


"
" Pdt Class Browser 
"

:command -nargs=1 LIB :call PDT_LIB(<f-args>)

:function PDT_LIB(...)
   :let oldshell = $SHELL
   :let templatecmd = "lslib " . a:1
   :let &shell=templatecmd
   :sh
   :let &shell = oldshell
:endfunction

"
" Pdt Function Browser
"

:command -nargs=1 FUNC :call PDT_FUNC(<f-args>)

:function PDT_FUNC(...)
   :let oldshell = $SHELL
   :let templatecmd = "lsfunc " . a:1
   :let &shell=templatecmd
   :sh
   :let &shell = oldshell
:endfunction

"
" EXPERIMENTAL 
"

" vi something unreadable3, and then write it with sudo 
" to write the file as root

:command -nargs=0 SUDOW :call CMD_SUDOW(<f-args>)

:function CMD_SUDOW()
	:w !sudo tee %
:endfunction

" PYPUB publishes the working python file to the libreoffice
" macro code directory 

:command PYPUB :call PY_PYPUB()

:function PY_PYPUB() 
	:w
	:let thisfqfn =expand('%:p')
	:put thisfqfn
	:!vipypub thisfqfn 
:endfunction

function! s:get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

" get the selected text, and dump it to a tool that will do some 
" nice indent handling. 

:command DOPDTINDENT :call PDT_INDENT()

:function! PDT_INDENT()
   :let [line_start, column_start] = getpos("'<")[1:2]
   :let [line_end, column_end] = getpos("'>")[1:2]
   :let oldshell = $SHELL
   :let $RTFN = system("rtfn")
	:echo $RTFN
	:sleep 2
   :let templatecmd = "pdtindent " . line_start . "," . line_end . "," local_paragraph_width . "," . tabstop
   :let &shell=templatecmd
   :sh
   :execute '-1read ' . expand($RTFN)
   :let &shell = oldshell
   :let $DELRTFN = system("rm $RTFN")
   :let $RTFN=""
:endfunction

" some recommended reading: 
" http://stackoverflow.com/questions/2001190/adding-a-command-to-vim
" http://stackoverflow.com/questions/2001190/adding-a-command-to-vim 
" http://www.ibm.com/developerworks/linux/library/l-vim-script-2/index.html
" http://learnvimscriptthehardway.stevelosh.com/chapters/19.html
" http://stackoverflow.com/questions/5736580/setting-vim-options-with-variables
"

" END PDT   

" START PYTHON

:command LOPY :call PY_LOPY()

:function! PY_LOPY()
	:let oldshell = $SHELL
	:let $RTFN = system("rtfn")
	:w $RTFN
	:let templatecmd = "lopy " . $RTFN 
	:let &shell=templatecmd
	:sh
	:let &shell = oldshell
	:let $DELRTFN = system("rm $RTFN")
	:let $RTFN=""
:endfunction
