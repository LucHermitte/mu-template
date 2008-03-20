"===========================================================================
" $Id$
" File:		mu-template.vim		{{{1
" Maintainer:	Luc Hermitte <MAIL:hermitte {at} free {dot} fr>
" 		<URL:http://hermitte.free.fr/vim/>
" Last Update:  $Date$
" Version:	2.0.2
"
" Initial Author:		Gergely Kontra <kgergely@mcl.hu>
" Last Official Version:	0.11
"
" Description:	Micro vim template file loader
" Installation:	{{{2
" 	Drop it into your plugin directory.
"	If you have some bracketing macros predefined, install this plugin in
"	<{runtimepath}/after/plugin/>
"	Needs: searchInRuntime.vim, bracketing.base.vim (i_CTRL-R_TAB),
"	lh-vim-lib, Vim7+
"
" Usage:	{{{2
" 	When a new file is created, a template file is loaded ; the name of
" 	the template beeing of the form {runtimepath}/template/&ft.template,
" 	&ft being the filetype of the new file.
"
" 	We can also volontarily invoke a template construction with 
" 		:MuTemplate id
" 	that will loads {runtimepath}/template/id.template ; cf. for instance
" 	cpp-class.template.
"
"	Template file has some magic characters:
"	- Strings surrounded by ¡ are expanded by vim
"	  Eg: ¡strftime('%c')¡ will be expanded to the current time (the time,
"	  when the template is read), so 2002.02.20. 14:49:23 on my system
"	  NOW.
"	  Eg: ¡expr==1?"text1":text2¡ will be expanded as "text1" or "text2"
"	  regarding 'expr' values 1 or not.
"	- Lines starting with "VimL:" are interpreted by vim
"	  Eg: VimL: let s:fn=expand("%") will affect s:fn with the name of the
"	  file currently created.
"	- Strings between «» signs are fill-out places, or marks, if you are
"	  familiar with some bracketing or jumping macros
"
"	See the documentation for more explanations.
"
" History: {{{2
" 	v0.1	Initial release
"	v0.11	- 'runtimepath' is searched for template files,
"		Luc Hermitte <hermitte at free.fr>'s improvements
"		- plugin => non reinclusion
"		- A little installation comment
"		- change 'exe "norm \<c-j>"' to 'norm !jump!' + startinsert
"		- add '¿vimExpr¿' to define areas of VimL, ideal to compute
"		  variables
"
"	v0.1bis&ter not included in 0.11, 
"	(*) default value for g:author as it is used in some templates
"	    -> $USERNAME (windows specific ?)
"	(*) extend '¡.\{-}¡' and s:Exec() in order to clear empty lines after
"	    the interpretation of '¡.\{-}¡'
"           cf. template.vim and say 'No' to see the difference.  0.20
"	(*) Command (:MuTemplate) in order to insert templates on request, and
"	    at the current cursor position.
"	    Eg: :MuTemplate cpp-class
"	(*) s:Template() changed in consequence
"
"	v0.20bis
"	(*) correct search(...,'W') to search(...,&ws?'w':'W') 
"	    ie.: the 'wrapscan' option is used.
"	(*) search policy of the template files improved :
"	    1- search in $VIMTEMPLATES if defined 
"	    2- true search in 'runtimepath' with :SearchInRuntime if
"	       <searchInRUntime.vim> installed.
"	    3- search of the first $$/template/ directory found to define
"	       $VIMTEMPLATES
"	(*) use &fdm to ease the edition of this file
"
"	v0.22
"	(*) Add a global boolean (0/1) option:
"	    g:mt_jump_to_first_markers that specifies whether we want to jump
"	    automatically to the first marker inserted.
"
"	v0.23
"	(*) New global boolean ([0]/1) option:
"	    g:mt_IDontWantTemplatesAutomaticallyInserted that forbids
"	    mu-template to automatically insert templates when opening new
"	    files.
"	    Must be set once before mu-template.vim is sourced -> .vimrc
"
"	v0.24
"	(*) No empty line inserted along with ':r'
"	(*) Cursor correctly positioned if there is no marker to jump to.
"	(*) MuTemplate accepts paths. e.g.: :MuTemplate xslt/xsl-if
"	(*) Reindentation of the text inserted permitted when the template
"	    file contains ¿ let s:reindent = 1 ¿
"	(*) New mappings: i_CTRL-R_TAB and i_CTRL-R_SPACE. They insert the
"	    template file matching {ft}/template.{cWORD}.
"	    In case there are several matches, the choice is given to the user
"	    through a menu.
"	    For instance, try:
"	    - in a C++ file:  
"		clas^R\t
"	    - in a XSLT file:
"		xsl:i^R\t!jump!xsl:t^R\t
"
"	v0.25
"	(*) i_CTRL-R_TAB   <=> {cWORD}
"	    i_CTRL-R_SPACE <=> {cword}
"	(*) Simplification: search(...,&ws?'w':'W') <=> search(...)
"	(*) Limit cases (when there are no available template for a given
"	    filetype and current word) no more errors
"
"	v0.26
"	(*) Plugin not run if required files are missing
"	(*) Better way to join lines that must be
"	(*) New option: "[bg]:mt_how_to_join"
"
"	v0.27
"	(*) Handling of $VIMTEMPLATES improved!
"	(*) The parsing of the templates is more accurate
"	(*) New statement: "^VimL:...$" that is equivalent to "^¿...¿$"
"	(*) Default implementation for DateStamp
"	(*) The function interpreted between ¡...¡ can echo messages and still
"	    remain silent.
"	(*) Little problem with ":MuTemplate <arg>" fixed.
"
"	v0.28
"	(*) some dead code cleaned
"	
"	v0.29
"	(*) quick fixes for file encodings
"
"	v0.30
"	(*) big changes regarding the funky characters used as delimiters
"	    "¿...¿" abandonned to "VimL:..."
"	    "¡...¡" abandonned to ... WILL BE DONE IN v0.32
"	(*) little bug with Vim 6.1.362 -> s/firstline/first_line/
"
"	v0.30 bis
"	(*) no more problems when expanding a multi-lines text (like
"	    g:Author="foo\nbarr")
"	(*) New function s:Include() that be be used from template files, 
"	    cf.: template.c, template.c-imp and template.c-header
"	    As a result, a single template-file (associated to a specific
"	    filetype) can load different other template-files.
"	(*) some code cleaning has been done
"
"	v0.31
"	(*) Add menus
"
"	v0.32
"	(*) Add a menu item for the help
"	(*) g:mt_IDontWantTemplatesAutomaticallyInserted can be changed at any
"	    time.
"	(*) Doesn't mess up with syntax/2html.vim anymore!
"
"	v0.33
"	(*) New function available to the templates: Author(); change into your
"	    template-files the occurrences of:
"	    - "g:author" to "Author()"
"	    - "g:author_short" to "Author(1)"
"
"	v0.34
"	(*) s:Include accept a second and optional argument: where to look for
"	    the template-file. ex.:
"           VimL: call s:Include('stream-signature', 'cpp/internals')
"           It can be used from global and ft-templates. 
"
"	v0.35
"	(*) New function: s:path_from_root()
"	(*) New options: g:mt_IDontWantTemplatesAutomaticallyInserted_4_{&ft}
"
"	v0.36
"	(*) Interpreted variables can expand to several lines
"	(*) Merging of empty lines, (and lines of empty comments) on CTRL-R_TAB
"
"	v1.0.0
"	(*) SVN + new versionning
"	(*) Bug fix in rebuild menu
"	(*) Marker/placeholders can be set with <++>, instead of
"	    ¡Marker_Txt()¡. This is customizable with |s:marker_open| and
"	    |s:marker_close|.
"	(*) Support latin1 and UTF-8 encodings
"	(*) ft inheritance (e.g. 'if'-template is the same for C and C++)
"	(*) Don't jump to a marker outside the inserted area.
"	    After rejoining lines, the cursor is placed just after the text
"	    that has been expanded -- if there are no marker to jump to
"	(*) Partially successful auto completion for :MuTemplate
"	(*) Workaround a change in Vim 7.0 behaviour
"	(*) &wildignore is ignored
"	(*) Extra '/' or '\' at end of $VIMTEMPLATES are trimmed.
"	(*) Bug fix regarding s:cpo_save which disappeared
"
"	v2.0.0
"	(*) Kernel change: Load and convert everything into memory first
"	(*) Big Change: Template names policy changed
"	(*) Menu: toggle the value of some options.
"	(*) New helper function: s:Line() that returns the current line number
"	(*) Less dependant on :SearchInVar
"	(*) Bug fix: Problem when modeline activates folding and we try to jump
"	    to the first marker.
" 	(*) Bug fix: the first thing in the first line must not be a marker
" 	v2.0.1
" 	(*) Bug fix: Work around the regression on the encoding issue
" 	    introduced with the new kernel in v2.0.0
" 	    -> new variable: s:fileencoding for template-files that have
" 	    characters in non ASCII encodings
" 	v2.0.2
" 	(*) Defect #6: g:mt_templates_dirs is not defined when menus are not active
" 	    NB: g:mt_templates_dirs becomes s:_mt_templates_dirs
"
" BUGS:	{{{2
"	Globals should be prefixed. Eg.: g:author .
" 	Do something when there is an error in a VimL: command
"
" TODO:	{{{2
" 	- Re-executing commands. (Can be useful for Last Modified fields).
"	- Change <cword> to alternatives because of 'xsl:i| toto'.
"	- Check it doesn't mess with search history, or registers.
"	- Documentation: finish. ;
"	- Menu: enable/disable submenus according the current &filetype.
"	  +--> buffermenu.vim
"	- Menu: display the list of options
"	- |:undojoin| for interactive template (see cpp/for-iterator)
"	- Popup menu like the one used by omnicomplete
"	- syntax highlight for templates
"	- Hint for latin2/etc encoding issues: have a s:IncludeConv() that
"	  takes the encoding of the file to load as a parameter. Or play with
"	  iconv() in |MuT-expression|s.
"	- Change the names of internal variables to something like s:__{variable} 
"	- Find some way to push/pop values into variables for the scope of a
"	  call to s:Include. Will be useful with s:fileencoding, s:marker_open,
"	  ...
"
"}}}1
"========================================================================
if exists("g:mu_template") && !exists('g:force_reload_mu_template')
  finish 
endif
let g:mu_template = 1
let s:cpo_save=&cpo
set cpo&vim
" scriptencoding latin1

" Debugging purpose
command! -nargs=1 MUEcho :echo s:<args> 

"========================================================================
" Low level functions {{{1
function! s:ErrorMsg(text)                  " {{{3
  call lh#common#ErrorMsg(a:text)
endfunction
function! s:CheckDeps(Symbol, File, path) " {{{3
  return lh#common#CheckDeps(a:Symbol, a:File, a:path, 'mu-template')
endfunction
" }}}1
"========================================================================
" Dependancies {{{1
if   
      \    !s:CheckDeps(':SearchInVar',    'searchInRuntime.vim', 'plugin/')
      \ || !s:CheckDeps('*GetCurrentWord', 'words_tools.vim',     'plugin/')
  let &cpo=s:cpo_save
  finish
endif
" }}}1
"========================================================================
" Default definitions and options {{{1
function! s:Option(name, default)                        " {{{2
  if     exists('b:mt_'.a:name) | return b:mt_{a:name}
  elseif exists('g:mt_'.a:name) | return g:mt_{a:name}
  else                          | return a:default
  endif
endfunction

" Define directories to search for templates               {{{2
function! s:TemplateDirs()
  " NB: template_dirs is computed every time as it can be changed between two
  " uses of mu-template.
  let template_dirs = substitute(&runtimepath, ',\|$', '/template\0', 'g')
  if exists('$VIMTEMPLATES') 
    " $VIMTEMPLATES is used if defined
    " This must be a list of directories separated by ';' or ','
    " Note: $VIMTEMPLATES has precedence over 'runtimepath'
    let result = $VIMTEMPLATES . ',' . template_dirs
  else
    let result = template_dirs
  endif
  let result = substitute(result, '\([/\\]\)\1', '\1', 'g')
  let result = substitute(result, '[/\\]\(,\|$\)', '\1', 'g')
  return result
endfunction

" g:author : recurrent special variable                    {{{2
function! Author(...)
  let short = (a:0>0 && a:1==1) ? '_short' : ''
  if     exists('b:author'.short) | return b:author{short}
  elseif exists('g:author'.short) | return g:author{short}
  elseif exists('$USERNAME')      | return $USERNAME	" win32
  elseif exists('$USER')          | return $USER	" unix
  else                            | return ''
  endif
endfunction

" Default implementation  for DateStamp()                  {{{2
if !exists('*DateStamp')
  function! DateStamp(...)
    if a:0 > 0
      return strftime(a:1)
    else
      return strftime('%c')
    endif
  endfunction
endif

" Tools functions                                          {{{2
" let s:value_start = '%%%('
" let s:value_end   = ')'
let s:value_start = '¡'
let s:value_end   = '¡'
function! s:Value(text)            " {{{3
  " :call Dfunc("s:Value(".a:text.')')
  " :call Dret("s:Value ".s:value_start . a:text . s:value_end)
  return '\%('.s:value_start . a:text . s:value_end.'\)'
endfunction

function! s:Command(text)          " {{{3
  return 'VimL:' . a:text
endfunction

function! s:Comment(text)          " {{{3
  return s:Command('" '.a:text)
endfunction

" function! s:Include()              {{{3
function! s:Include(template, ...)
  let pos = s:content.crt
  " let correction = s:NeedToJoin > 0
  let correction = 0
  let dir = fnamemodify(a:template, ':h')
  if dir != "" | let dir .= '/' | endif
  if a:0>0
    let dir .= a:1 . '/'
  endif
  "NAMES WERE: if 0 == s:LoadTemplate(pos-correction, dir.'template.'.a:template)
  "NAMES WERE:   call lh#common#WarningMsg("muTemplate: No template file matching <".dir.'template.'.a:template.">")
  if 0 == s:LoadTemplate(pos-correction, dir.a:template.'.template')
    call lh#common#WarningMsg("muTemplate: No template file matching <".dir.a:template.'.template'.">\r".'dir='.dir.'|'.a:template.'|'.string(a:000))
  endif
endfunction

function! s:path_from_root(path)   " {{{3
  let path = a:path
  if exists('b:sources_root')
    let s = strlen(b:sources_root)
    if b:sources_root[s-1] !~ '/\|\\'
      let b:sources_root = b:sources_root 
	    \ . ((!exists('shellslash')||&shellslash)?'/':'\')
      let s = s + 1
    endif
    let p = stridx(path, b:sources_root)
    if 0 == p
      let path = strpart(path, s)
    endif
  endif
  return path
endfunction

" function s:Line()                  {{{3
" Returns current line
function! s:Line()
  return s:content.crt + s:content.start
endfunction

" {[bg]:mt_jump_to_first_markers}                          {{{2
" Boolean: specifies weither we want to jump to the first marker in the file.

" How to join with next line : {[bg]:mt_how_to_join}       {{{2
"   Used only with i_CTRL-R_TAB
"   == 0 : "{pattern}^r\t foo" -> "{the template}\nfoo"
"   == 1 : "{pattern}^r\t foo" -> "{the template} foo"
"   == 2 : "{pattern}^r\t foo" -> "{the template}«» foo"

" Filetypes inheritance                                    {{{2
if !exists('g:mt_inherited_ft_for_cpp')
  let g:mt_inherited_ft_for_cpp    = 'c'
endif
if !exists('g:mt_inherited_ft_for_csharp')
  let g:mt_inherited_ft_for_csharp = 'c'
endif
if !exists('g:mt_inherited_ft_for_java')
  let g:mt_inherited_ft_for_java   = 'c'
endif

" }}}1
"========================================================================
" Core Functions {{{1
let s:content = { 'lines' : [], 'crt' : 0, 'start' : 0}

function! s:LoadTemplate(pos, templatepath)                      " {{{2
  " echomsg "s:LoadTemplate(".a:pos.", '".a:templatepath."')"
  try
    let s:wildignore = &wildignore
    let &wildignore  = ""

    let matching_filenames = lh#path#GlobAsList(s:_mt_templates_dirs, a:templatepath)
    if len(matching_filenames) == 0
      return 0 " NB: the finally block is still executed
      " call lh#common#WarningMsg("muTemplate: No template file matching <".a:templatepath.">")
    else
      if &verbose >= 1
	echo "Loading <".matching_filenames[0].">"
      endif
      let lines = readfile(matching_filenames[0])
      call extend(s:content.lines, lines, a:pos)
      " echomsg string(s:content)
    endif
  finally
    let &wildignore = s:wildignore
  endtry
  return len(s:content.lines)
endfunction

" s:InterpretValue() will interpret a sequence between ¡.\{-}¡ {{{2
" ... and return the computed value.
" To possibly expand a sequence into an empty string, use the 
" 'bool_expr ?  act1 : act2' VimL operator ; cf vim.template for examples of
" use.
function! s:InterpretValue(what)
  try
    exe 'let s:r = ' . a:what
    " NB: cannot use a local variable, hence the "s:xxxx"
    return s:r
  catch /.*/
    call lh#common#WarningMsg("muTemplate: Cannot interpret `".a:what."': ".v:exception)
    return a:what
  endtry
endfunction

" s:InterpretCommand() will interpret a sequence "VimL:.*"     {{{2
" ... and return nothing
" Back-Door to trojans !!!
function! s:InterpretCommand(what)
  try
    exe a:what
  catch /.*/
    call lh#common#WarningMsg("muTemplate: Cannot execute `".a:what."': ".v:exception)
    throw "muTemplate: Cannot execute `".a:what."': ".v:exception
  endtry
endfunction

function! s:InterpretValues(line)
  let res = ''
  let tail = a:line
  let re =  '\(.\{-}\)'.s:Value('\(.\{-}\)').'\(.*\)'
  let may_merge = 0
  while strlen(tail)!=0
    let split = matchlist(tail, re)
    if len(split) <2 || strlen(split[0]) == 0
      " nothing found
      let res .= tail
      let tail = ''
      " let may_merge = 0
    else
      let value = s:InterpretValue(split[2])
      let res .= split[1] . value 
      let tail = split[3]
      let may_merge = 1
    endif
  endwhile
  " echomsg "may_merge=".may_merge."  ---  ".res
  return { 'line' : res, 'may_merge' : may_merge }
endfunction

function! s:NoRegex(text)
  return escape(a:text, '\.*/')
endfunction

function! s:Marker(regex)
  return s:NoRegex(s:marker_open) . a:regex . s:NoRegex(s:marker_close)
endfunction

function! s:InterpretLines(first_line)              " {{{2
  " Constants
  let markerCharacters = Marker_Txt('')

  let s:content.crt = 0
  " let pat_command = '\c^'.s:Command('.*')
  let pat_command = '\c^'.s:Command('')
  while s:content.crt < len(s:content.lines)
    " echomsg s:content.crt . ' < ' . len(s:content.lines) . ' ----> ' . s:content.lines[s:content.crt] 
    let the_line = s:content.lines[s:content.crt] 
    if the_line =~ pat_command
      call remove(s:content.lines, s:content.crt) " implicit next, must be done before any s:Include
      call s:InterpretCommand( matchstr(the_line, '\c'.s:Command('').'\zs.*'))
    elseif the_line !~ '^\s*$'
      " NB 1- We must know the expression characters before any interpretation.
      "    2- :r inserts an empty line before the template loaded
      "    => We do not interpret empty lines
      "    => s:value_start and s:value_end must always be specified!

      if s:Marker('') != markerCharacters
	" Replaces plain marker characters into current marker characters.
	let the_line = substitute(the_line, s:Marker('\(.\{-}\)'), Marker_Txt('\1'), 'g')
      endif

      " Replaces expressions by their interpreted value
      let line = s:InterpretValues(the_line)
      let the_line = line.line
      if the_line =~ '^\s*$' && line.may_merge
	" The line becomes empty after the evaluation of the expression => strip it
	call remove(s:content.lines, s:content.crt) " implicit next
      else
	" Put back the interpreted lines in the content buffer
	if match(the_line, "[\n\r]")
	  " Split the line into several lines if it contains "\n" or "\r"
	  " characters
	  let lines = split(the_line, "[\r\n]")
	  call remove(s:content.lines, s:content.crt)
	  call extend(s:content.lines, lines, s:content.crt)
	  let s:content.crt += len(lines) " next
	else
	  " Nominal case: only one line
	  let s:content.lines[s:content.crt] = the_line
	  let s:content.crt += 1 " next
	endif
      endif
    else
      let s:content.crt += 1 " next
    endif
  endwhile
endfunction

function! s:Reencode()
  call map(s:content.lines, 'lh#encoding#Iconv(v:val, '.string(s:fileencoding).', &enc)')
endfunction

" s:IsKindOfEmptyLine(lineNo)                                  {{{2
" @return true on empty lines or on lines containing an empty comment
function! s:IsKindOfEmptyLine(lineNo)
  let line = getline(a:lineNo)
  if     line =~ '^\s*$' 
    return 1
  elseif version >= 700
    let comments = split(&comments, ',')
    let i = 0
    while i != len(comments)
      if     comments[i] =~ '^m\|^[nbf]\=-\=\d*:'
	" Never consider start or end of three-piece comment as empty comment
	let comment = escape(matchstr(comments[i], '^.\{-}:\zs.*'), '\*')
	" call confirm('##'.comment.'##', '&Ok', 1)
	if line =~ '^\s*'.comment.(strlen(comment)?'\s*':'').'$'
	  return 1
	endif
      endif
      let i += 1
    endwhile
    return 0
  endif
endfunction

" s:TemplateAndJump() called by :MuTemplate and imapping       {{{2
function! s:TemplateAndJump(needToJoin, ...)
  " echomsg "s:TemplateAndJump"
  let res = (a:0>0)
	\ ? s:Template(a:needToJoin, a:1)
	\ : s:Template(a:needToJoin)
  if res && s:Option('jump_to_first_markers',1)
    call s:JumpToStart()
  endif
  return res
endfunction

" s:TemplateOnBufNewFile() triggered by BufNewFile event       {{{2
function! s:TemplateOnBufNewFile()
  let s:_mt_templates_dirs = s:TemplateDirs()
  " echomsg 's:TemplateOnBufNewFile'
  let res = s:Template(0)
  if res && s:Option('jump_to_first_markers',1)
    " Register For After Modeline Event
    command! -nargs=0 JumpToStart :call s:JumpToStart()
    call lh#event#RegisterForOneExecutionAt('BufWinEnter', ':JumpToStart', 'MuT_AfterModeline')
  endif
  " No more ':startinsert'. It seems useless and redundant with !jump!
  " startinsert
  return res
endfunction

" s:Template() is the main function                            {{{2
function! s:Template(NeedToJoin, ...)
  " echomsg 's:Template('.a:NeedToJoin.string(a:000).')'
  " 1- Determine the name of the template file expected {{{3
  let pos = line('.')
  let s:content.start = pos
  let s:content.lines = []
  let s:NeedToJoin = a:NeedToJoin
  if a:0 > 0 
    let dir = fnamemodify(a:1, ':h')
    if dir != "" | let dir .= '/' | endif
    let ft  = fnamemodify(a:1, ':t')
    " first option : the template file is specified ; cf. cpp.template-class
  else       
    let ft=strlen(&ft) ? &ft : 'unknown'
    let dir = ''
    " otherwise (default) : the template file is function of the current
    " filetype
  endif
  " 2- Load the associated template {{{3
  let foldenable=&foldenable
  silent! set nofoldenable
  try
    "NAMES WERE: call  s:LoadTemplate(0, dir.'template.'.ft)
    call  s:LoadTemplate(0, dir.ft.'.template')

    " Default values for placeholder characters (they can be overridden in each
    " template file). 
    let s:marker_open  = '<+'
    let s:marker_close = '+>'
    " Default fileencoding to override in template files
    let s:fileencoding = &enc

    " Note: last is the number of the last line inserted
    " 3- If successful, interpret it {{{3
    if len(s:content.lines) > 0 " {{{4
      " Interpret
      call s:InterpretLines(pos)
      " Reencode
      if s:fileencoding != &enc
	if has('multi_byte') 
	  call s:Reencode()
	else
	  call lh#common#WarningMsg('muTemplate: This vim executable cannot convert the text from "'.s:fileencoding.'" to &enc="'.&enc.'" as requested by the template-file')
	endif
      endif
      " Insert
      call append(pos, s:content.lines)
      let last=pos + len(s:content.lines)
      " echomsg 'last='.last

      " Goto the first line and delete it (because :r insert one useless line)
      if "" == getline(pos)
	silent exe pos."normal! dd0"
      else
	silent exe pos."normal! J!0"
      endif
      let last -= 1
      " Reindent
      if exists('s:reindent') && s:reindent
	silent exe (pos).','.(last).'normal! =='
	unlet s:reindent
      endif
      " Join with the line after the template that have been inserted
      if     a:NeedToJoin >= 2
	silent exe last."normal! A".Marker_Txt('')."\<esc>J!"
	let s:moveto = 'call cursor('.last.','.virtcol('.').')'
      elseif a:NeedToJoin >= 1
	"Here: problem when merging empty &comments
	if s:IsKindOfEmptyLine(last+1)
	  silent exe (last+1).'delete _'
	  let s:moveto = last.'normal! $'
	else
	  " exe last."normal! J!"
	  exe last
	  let s:moveto = 'call cursor('.last.','.virtcol('$').')'
	  silent exe last."normal! gqj"
	endif
      else " NeedToJoin == 0
	let s:moveto = 'call cursor('.pos.',1)'
      endif
      return 1
    else " {{{4
      return 0
    endif
  finally
    let &foldenable=foldenable
  endtry
  " }}}3
endfunction

" s:JumpToStart()                                              {{{2
function! s:JumpToStart()
  " echomsg 's:JumpToStart'
  " set foldopen+=insert,jump
  " Need to be sure there was a marker in the text inserted
  " let therewasamarker = 0
  " echomsg (pos).','.(last).'g/'.Marker_Txt('.\{-}')."/let therewasamarker=1"
  " silent! exe (pos).','.(last).'g/'.Marker_Txt('.\{-}')."/let therewasamarker=1"
  let marker_line = lh#list#Match(s:content.lines, Marker_Txt('.\{-}'))
  let therewasamarker = -1 != marker_line
  if therewasamarker
    " echomsg "jump from ".(marker_line+s:content.start)
    exe (marker_line+s:content.start)
    " normal! zO
    try
      let save_gscf = lh#option#Get('marker_select_current_fwd', 1)
      let g:marker_select_current_fwd = 1
      normal !jump!
    finally
      let g:marker_select_current_fwd = save_gscf
    endtry
  else
    :exe s:moveto
  endif
  silent! delcommand JumpToStart
endfunction

" s:InheritedFiletypes(filetype)                               {{{2
function! s:InheritedFiletypes(filetype)
  if exists('g:mt_inherited_ft_for_'.a:filetype)
    return g:mt_inherited_ft_for_{a:filetype}
  else
    return ''
  endif
endfunction

" s:GetTemplateFilesMatching(word, filetype)                   {{{2
function! s:GetTemplateFilesMatching(word, filetype)
  " Look for filetypes (C++ -> C, ...)
  let gpatterns=[]
  let ft = a:filetype
  while strlen(ft)
    "NAMES WERE: call add( gpatterns , ' template.'.ft.'-'.a:word )
    "NAMES WERE: call add( gpatterns , ft.'/template.'.a:word)
    call add( gpatterns , ' '.ft.'-'.a:word.'.template' )
    call add( gpatterns , ft.'/'.a:word.'.template')
    let ft = s:InheritedFiletypes(ft)
  endwhile

  " And search
  let s:_mt_templates_dirs = s:TemplateDirs()
  try
    let l:wildignore = &wildignore
    let &wildignore  = ""
    let files = lh#path#GlobAsList(s:_mt_templates_dirs, gpatterns)
    return files
  finally
    let &wildignore = l:wildignore
  endtry
endfunction

" s:ShortenTemplateFilesNames(list)                            {{{2
function! s:ShortenTemplateFilesNames(list)
  :let g:list =a:list
  " 1- Strip path part from s:_mt_templates_dirs
  call map(a:list, 'lh#path#StripStart(v:val, s:_mt_templates_dirs)')
  " 2- simplify filename to keep only the non "template" part
  "NAMES WERE: call map(a:list, 'substitute(v:val, "\\<template\.", "", "")')
  call map(a:list, 'substitute(v:val, "\.template\\>", "", "")')
  return a:list
endfunction

" s:GetShortListOfTFMatching(word,filetype)                    {{{2
function! s:GetShortListOfTFMatching(word, filetype)
  " 1- Build the list of template files matching the current word {{{3
  let files = s:GetTemplateFilesMatching(a:word, a:filetype)

  " 2- Shorten the template-file names                            {{{3
  let strings = s:ShortenTemplateFilesNames(files)
  return strings
endfunction

" s:SearchTemplates()                                          {{{2
function! s:SearchTemplates(word)
  " 1- Build the list of template files matching the current word {{{3
  let w = substitute(a:word, ':', '-', 'g').'*'
  " call confirm("w =  #".w."#", '&ok', 1)
  let files = s:GetShortListOfTFMatching(w, &ft)

  " 2- Select one template file only {{{3
  let strings = join(files, "\n")
  let nbChoices = len(files)
  " call confirm(nbChoices."\n".files, '&ok', 1)
  if (nbChoices == 0) 
    call lh#common#WarningMsg("muTemplate: No template file matching <".w."> for ".&ft." files")
    return ""
  elseif (nbChoices > 1)
    let choice = confirm("Which template do you wish to use ?", 
	  \ "&Abort\n".strings, 1)
    if choice <= 1 | return "" | endif
  else 
    let choice = 2
  endif

  " File <- n^th choice
  let file = files[choice - 2]
  " call confirm("choice=".choice."\nfile=".file, '&ok', 1)

  " 3- Template-file to insert ? {{{3
  if "" != file " 3.A- => YES there is one {{{4
  " 3.1- Remove the current word {{{5
    " Note: <esc> is needed to escape from "Visual insertion mode"
    " TODO: manage a blinking pb
    let l = strlen(a:word)	" No word to expand ; abort
    if     0 == l
    elseif 1 == l		" Select a one-character length word
      silent exe "normal! \<esc>vc\<esc>"
    else			" Select a 1_n-characters length word
      let ew = escape(a:word, '\.*[')
      call search(ew, 'b')
      silent exe "normal! \<esc>v/".ew."/e\<cr>c\<esc>"
      " exe "normal! \<esc>viWc\<esc>"
    endif
    " Insert a line break
    silent exe "normal! i\<cr>\<esc>\<up>$"
    
    " 3.2- Insert the template {{{5
    if &verbose >= 1
      call confirm("Using the template file: <".file.'>', '&ok', 1)
    endif
    " Todo: check what happens with g:mt_jump_to_first_markers off
    if !s:TemplateAndJump(s:Option('how_to_join',1),file)
      call s:ErrorMsg("Hum... problem to insert the template: <".file.'>') 
    endif
    " Note: <esc> is needed to escape from "Visual insertion mode"
    " Workaround a change in Vim 7.0 behaviour
    return "\<c-\>\<c-n>\<c-\>\<c-n>gv\<c-g>"
    " return "\<esc>\<right>"
  else          " 3.B- No template file available for the current word {{{4
    return ""
  endif " }}}3
endfunction

" i_CTRL-R stubbs                                              {{{2
if 0
" s:CTRL_R() {{{3
" |i_CTRL-R_TAB| : proposes a list of templates
" |i_CTRL-R_SPACE| : expand the current word
" |i_CTRL-R_F1| : displays a short help
function! s:CTRL_R()
  " let s:alts = '' | let s:cur = 0
  while 1
    let key=getchar()
    let complType=nr2char(key)
    if -1 != stridx(" \<tab>",complType) ||
	  \ (key =~ "\<F1>")
      if     complType == " "      | return s:SearchTemplates("<cword>")
      elseif complType == "\<tab>" | return s:SearchTemplates("<cWORD>")
      elseif key       == "\<F1>" 
	echohl StatusLineNC
	echo "\r-- mode ^R (/0-9a-z\"%#*+:.-=/<tab>/<F1>)"
	echohl None
	" else
      endif
    else
      return "\<c-r>".complType
    endif
  endwhile
endfunction

  inoremap <silent> <C-R>		<C-R>=<sid>CTRL_R()<cr>
else " {{{3
  "Note: expand('<cword>') is not correct when there are characters after the
  "current curpor position
  inoremap <silent> <Plug>MuT_ckword <C-R>=<sid>SearchTemplates(GetCurrentKeyword())<cr>
  inoremap <silent> <Plug>MuT_cWORD  <C-R>=<sid>SearchTemplates(GetCurrentWord())<cr>
  if !hasmapto('<Plug>MuT_ckword', 'i')
    imap <unique> <C-R><space>	<Plug>MuT_ckword
  endif
  if !hasmapto('<Plug>MuT_cWORD', 'i')
    imap <unique> <C-R><tab>	<Plug>MuT_cWORD
  endif
endif

" auto completion                                              {{{2
let s:commands = 'MuT\%[emplate]'
function! s:Complete(ArgLead, CmdLine, CursorPos)
  let cmd = matchstr(a:CmdLine, s:commands)
  let cmdpat = '^'.cmd

  let tmp = substitute(a:CmdLine, '\s*\S\+', 'Z', 'g')
  let pos = strlen(tmp)
  let lCmdLine = strlen(a:CmdLine)
  let fromLast = strlen(a:ArgLead) + a:CursorPos - lCmdLine 
  " The argument to expand, but cut where the cursor is
  let ArgLead = strpart(a:ArgLead, 0, fromLast )
  if 0
    call confirm( "a:AL = ". a:ArgLead."\nAl  = ".ArgLead
	  \ . "\nx=" . fromLast
	  \ . "\ncut = ".strpart(a:CmdLine, a:CursorPos)
	  \ . "\nCL = ". a:CmdLine."\nCP = ".a:CursorPos
	  \ . "\ntmp = ".tmp."\npos = ".pos
	  \, '&Ok', 1)
  endif

  if 'MuTemplate' != cmd | return '' | endif

  " let ArgLead = substitute(ArgLead, '.*/', '', '')
  " if stridx(ArgLead, '/') == -1
    " let ArgLead = 
  " endif«»
  let s:wildignore = &wildignore
  let &wildignore  = ""
  let ftlist = s:ShortenTemplateFilesNames(
        \ lh#path#GlobAsList(s:_mt_templates_dirs, ArgLead.'*.template'))
        "NAMES WERE: \ lh#path#GlobAsList(s:_mt_templates_dirs, 'template.'.ArgLead.'*'))
  let &wildignore = s:wildignore
  call extend(ftlist, s:GetShortListOfTFMatching(ArgLead.'*', &ft))
  let res = join(ftlist, "\n")
  return res
endfunction

" }}}1
"========================================================================
" Menus {{{1
" Options                                    {{{2
" Note: must be set before the plugin is loaded -> .vimrc
let s:menu_prio = exists('g:mt_menu_priority') 
      \ ? g:mt_menu_priority : 59
if s:menu_prio !~ '\.$' | let s:menu_prio = s:menu_prio . '.' | endif
let s:menu_name = exists('g:mt_menu_name')
      \ ? g:mt_menu_name     : '&Templates.'
if s:menu_name !~ '\.$' | let s:menu_name = s:menu_name . '.' | endif

" Fonction: s:AddMenu(m_prio,m_name,name)    {{{2
function! s:AddMenu(m_name, m_prio, nameslist)
  let m_name = a:m_name
  let m_name = substitute(m_name, '^\s*\(\S.\{-}\S\)\s*$', '\1', '')
  for name in a:nameslist
    let name = substitute(name, '/', '.\&', 'g')
    if ! ((name =~ '-') && (name !~ '\.&')) 
      exe 'amenu '.s:menu_prio.a:m_prio.' '
	    \ .escape(s:menu_name.m_name.name, '\ ')
	    \ .' :MuTemplate '.substitute(name,'\.&', '/', '').'<cr>'
      if &verbose >= 2
	echomsg 'amenu '.s:menu_prio.a:m_prio.' '
	      \ .escape(s:menu_name.m_name.name, '\ ')
	      \ .' :MuTemplate '.substitute(name,'\.&', '/', '').'<cr>'
      endif
    else
      if &verbose >= 1
	echomsg "muTemplate#s:AddMenu(): discard ".name
      endif
    endif
  endfor
endfunction

" Fonction: s:BuildMenu(doRebuild: boolean)  {{{2
function! s:BuildMenu(doRebuild)
  " 1- Clear previously existing menu {{{3
  if a:doRebuild
    silent! exe ":unmenu ".escape(s:menu_name, '\ ')
  endif

  " 2- Static menus                   {{{3
  exe 'amenu <silent> '.s:menu_prio.'200 '.escape(s:menu_name.'-1-', '\ '). ' <Nop>'
  exe 'amenu <silent> '.s:menu_prio.'400 '.escape(s:menu_name.'-2-', '\ '). ' <Nop>'
  exe 'amenu <silent> '.s:menu_prio.'500 '.
	\ escape(s:menu_name.'&Rebuild Menu', '\ ').
	\ ' :call <sid>BuildMenu(1)<CR>'
  exe 'amenu <silent> '.s:menu_prio.'700 '.
	\ escape(s:menu_name.'&Help', '\ ').
	\ ' :call <sid>Help()<CR>'

  " 3- Options                        {{{3
  let s:AutoInsertMenu = {
	\ "variable": "mt_IDontWantTemplatesAutomaticallyInserted",
	\ "idx_crt_value": 1,
	\ "texts": [ 'no', 'yes' ],
	\ "values": [ 1, 0],
	\ "menu": {
	\     "priority": s:menu_prio.'600',
	\     "name": s:menu_name.'&Options.&Automatic Expansion'}
	\}
  call lh#menu#DefToggleItem(s:AutoInsertMenu)

  " 4- New File                       {{{3
  try
    let s:wildignore = &wildignore
    let &wildignore  = ""
    let s:_mt_templates_dirs = s:TemplateDirs()
    let new_list = s:ShortenTemplateFilesNames(
          \ lh#path#GlobAsList(s:_mt_templates_dirs, '*.template'))
          "NAMES WERE: \ lh#path#GlobAsList(s:_mt_templates_dirs, 'template.*'))
    call s:AddMenu('&New.&', '100.10', new_list)

    " 5- contructs                    {{{3
    let ft_list = s:GetShortListOfTFMatching('*', '*')
    call s:AddMenu('&', '300.10', ft_list)

    let &wildignore = s:wildignore
  finally
    let &wildignore = s:wildignore
  endtry
endfunction

" Load Menu                                  {{{2
if has('gui_running') && has('menu')
  call s:BuildMenu(0)
endif
" Menus }}}1
" Help {{{1
" Function: s:Help()                         {{{2
function! s:Help()
  let errmsg_save = v:errmsg
  silent! help mu-template
  if v:errmsg != ""
    if exists(':SearchInRuntime')
      command! -nargs=1 HelpTags exe 'helptags '.fnamemodify('<args>', ':h')
      SearchInRuntime HelpTags doc/mu-template.txt
      delcommand HelpTags
      silent help mu-template
    else
      call s:ErrorMsg("Please install the help for mu-template")
    endif
  endif
  let v:errmsg = errmsg_save    
endfunction
" Help }}}1
"========================================================================
" [auto]commands {{{1
command! -nargs=? -complete=custom,<sid>Complete MuTemplate :call <sid>TemplateAndJump(0, <f-args>)

function! s:AutomaticInsertion()
  if !exists('g:mt_IDontWantTemplatesAutomaticallyInserted') ||
	\ !g:mt_IDontWantTemplatesAutomaticallyInserted
    return 1
  elseif strlen(&ft) && 
	\ (!exists('g:mt_IDontWantTemplatesAutomaticallyInserted_4_'.&ft) ||
	\ !g:mt_IDontWantTemplatesAutomaticallyInserted_4_{&ft})
    return 1
  else
    return 0
  endif
endfunction

augroup MuTemplate
  au!
  au BufNewFile * if s:AutomaticInsertion() | call <SID>TemplateOnBufNewFile() | endif
  "au BufWritePre * echon 'TODO'
  "au BufWritePre * normal ,last
augroup END
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"========================================================================
" vim60: set fdm=marker:
