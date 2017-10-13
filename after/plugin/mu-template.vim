"===========================================================================
" File:         after/plugin/mu-template.vim            {{{1
" Maintainer:   Luc Hermitte <MAIL:hermitte {at} free {dot} fr>
"		<URL:http://github.com/LucHermitte/mu-template>
" Last Update:  14th Oct 2017
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/mu-template/blob/master/License.md>
" Version:      4.3.0
let s:k_version = 430
"
" Initial Author:       Gergely Kontra <kgergely@mcl.hu>
" Forked at version:    0.11
"
" Description:  Micro vim template file expander
" Installation: {{{2
"       Drop it into your plugin directory.
"       If you have some bracketing macros predefined, install this plugin in
"       <{runtimepath}/after/plugin/>
"       Needs: bracketing.base.vim (i_CTRL-R_TAB), lh-vim-lib, Vim7+
"       Exploits: searchInRuntime, stakeholders
"
" Usage:        {{{2
"       When a new file is created, a template file is loaded ; the name of
"       the template beeing of the form {runtimepath}/template/&ft.template,
"       &ft being the filetype of the new file.
"
"       We can also volontarily invoke a template construction with
"               :MuTemplate id
"       that will loads {runtimepath}/template/id.template ; cf. for instance
"       cpp-class.template.
"
"       Template file has some magic characters:
"       - Strings surrounded by ¡ are expanded by vim
"         Eg: ¡strftime('%c')¡ will be expanded to the current time (the time,
"         when the template is read), so 2002.02.20. 14:49:23 on my system
"         NOW.
"         Eg: ¡expr==1?"text1":text2¡ will be expanded as "text1" or "text2"
"         regarding 'expr' values 1 or not.
"       - Lines starting with "VimL:" are interpreted by vim
"         Eg: VimL: let s:fn=expand("%") will affect s:fn with the name of the
"         file currently created.
"       - Strings between «» signs are fill-out places, or marks, if you are
"         familiar with some bracketing or jumping macros
"
"       See the documentation for more explanations.
"
" History: {{{2
"       v0.1    Initial release
"       v0.11   - 'runtimepath' is searched for template files,
"               Luc Hermitte <hermitte at free.fr>'s improvements
"               - plugin => non reinclusion
"               - A little installation comment
"               - change 'exe "norm \<c-j>"' to 'norm !jump!' + startinsert
"               - add '¿vimExpr¿' to define areas of VimL, ideal to compute
"                 variables
"
"       v0.1bis&ter not included in 0.11,
"       (*) default value for g:author as it is used in some templates
"           -> $USERNAME (windows specific ?)
"       (*) extend '¡.\{-}¡' and s:Exec() in order to clear empty lines after
"           the interpretation of '¡.\{-}¡'
"           cf. template.vim and say 'No' to see the difference.  0.20
"       (*) Command (:MuTemplate) in order to insert templates on request, and
"           at the current cursor position.
"           Eg: :MuTemplate cpp-class
"       (*) s:Template() changed in consequence
"
"       v0.20bis
"       (*) correct search(...,'W') to search(...,&ws?'w':'W')
"           ie.: the 'wrapscan' option is used.
"       (*) search policy of the template files improved :
"           1- search in $VIMTEMPLATES if defined
"           2- true search in 'runtimepath' with :SearchInRuntime if
"              <searchInRUntime.vim> installed.
"           3- search of the first $$/template/ directory found to define
"              $VIMTEMPLATES
"       (*) use &fdm to ease the edition of this file
"
"       v0.22
"       (*) Add a global boolean (0/1) option:
"           g:mt_jump_to_first_markers that specifies whether we want to jump
"           automatically to the first marker inserted.
"
"       v0.23
"       (*) New global boolean ([0]/1) option:
"           g:mt_IDontWantTemplatesAutomaticallyInserted that forbids
"           mu-template to automatically insert templates when opening new
"           files.
"           Must be set once before mu-template.vim is sourced -> .vimrc
"
"       v0.24
"       (*) No empty line inserted along with ':r'
"       (*) Cursor correctly positioned if there is no marker to jump to.
"       (*) MuTemplate accepts paths. e.g.: :MuTemplate xslt/xsl-if
"       (*) Reindentation of the text inserted permitted when the template
"           file contains ¿ let s:reindent = 1 ¿
"       (*) New mappings: i_CTRL-R_TAB and i_CTRL-R_SPACE. They insert the
"           template file matching {ft}/template.{cWORD}.
"           In case there are several matches, the choice is given to the user
"           through a menu.
"           For instance, try:
"           - in a C++ file:
"               clas^R\t
"           - in a XSLT file:
"               xsl:i^R\t!jump!xsl:t^R\t
"
"       v0.25
"       (*) i_CTRL-R_TAB   <=> {cWORD}
"           i_CTRL-R_SPACE <=> {cword}
"       (*) Simplification: search(...,&ws?'w':'W') <=> search(...)
"       (*) Limit cases (when there are no available template for a given
"           filetype and current word) no more errors
"
"       v0.26
"       (*) Plugin not run if required files are missing
"       (*) Better way to join lines that must be
"       (*) New option: "[bg]:mt_how_to_join"
"
"       v0.27
"       (*) Handling of $VIMTEMPLATES improved!
"       (*) The parsing of the templates is more accurate
"       (*) New statement: "^VimL:...$" that is equivalent to "^¿...¿$"
"       (*) Default implementation for DateStamp
"       (*) The function interpreted between ¡...¡ can echo messages and still
"           remain silent.
"       (*) Little problem with ":MuTemplate <arg>" fixed.
"
"       v0.28
"       (*) some dead code cleaned
"
"       v0.29
"       (*) quick fixes for file encodings
"
"       v0.30
"       (*) big changes regarding the funky characters used as delimiters
"           "¿...¿" abandoned to "VimL:..."
"           "¡...¡" abandoned to ... WILL BE DONE IN v0.32
"       (*) little bug with Vim 6.1.362 -> s/firstline/first_line/
"
"       v0.30 bis
"       (*) no more problems when expanding a multi-lines text (like
"           g:Author="foo\nbarr")
"       (*) New function s:Include() that be be used from template files,
"           cf.: template.c, template.c-imp and template.c-header
"           As a result, a single template-file (associated to a specific
"           filetype) can load different other template-files.
"       (*) some code cleaning has been done
"
"       v0.31
"       (*) Add menus
"
"       v0.32
"       (*) Add a menu item for the help
"       (*) g:mt_IDontWantTemplatesAutomaticallyInserted can be changed at any
"           time.
"       (*) Doesn't mess up with syntax/2html.vim anymore!
"
"       v0.33
"       (*) New function available to the templates: Author(); change into your
"           template-files the occurrences of:
"           - "g:author" to "Author()"
"           - "g:author_short" to "Author(1)"
"
"       v0.34
"       (*) s:Include accept a second and optional argument: where to look for
"           the template-file. ex.:
"           VimL: call s:Include('stream-signature', 'cpp/internals')
"           It can be used from global and ft-templates.
"
"       v0.35
"       (*) New function: s:path_from_root()
"       (*) New options: g:mt_IDontWantTemplatesAutomaticallyInserted_4_{&ft}
"
"       v0.36
"       (*) Interpreted variables can expand to several lines
"       (*) Merging of empty lines, (and lines of empty comments) on CTRL-R_TAB
"
"       v1.0.0
"       (*) SVN + new versioning
"       (*) Bug fix in rebuild menu
"       (*) Marker/placeholders can be set with <++>, instead of
"           ¡Marker_Txt()¡. This is customizable with |s:marker_open| and
"           |s:marker_close|.
"       (*) Support latin1 and UTF-8 encodings
"       (*) ft inheritance (e.g. 'if'-template is the same for C and C++)
"       (*) Don't jump to a marker outside the inserted area.
"           After rejoining lines, the cursor is placed just after the text
"           that has been expanded -- if there are no marker to jump to
"       (*) Partially successful auto completion for :MuTemplate
"       (*) Workaround a change in Vim 7.0 behaviour
"       (*) &wildignore is ignored
"       (*) Extra '/' or '\' at end of $VIMTEMPLATES are trimmed.
"       (*) Bug fix regarding s:cpo_save which disappeared
"
"       v2.0.0
"       (*) Kernel change: Load and convert everything into memory first
"       (*) Big Change: Template names policy changed
"       (*) Menu: toggle the value of some options.
"       (*) New helper function: s:Line() that returns the current line number
"       (*) Less dependant on :SearchInVar
"       (*) Bug fix: Problem when modeline activates folding and we try to jump
"           to the first marker.
"       (*) Bug fix: the first thing in the first line must not be a marker
"       v2.0.1
"       (*) Bug fix: Work around the regression on the encoding issue
"           introduced with the new kernel in v2.0.0
"           -> new variable: s:fileencoding for template-files that have
"           characters in non ASCII encodings
"       v2.0.2
"       (*) Defect #6: g:mt_templates_dirs is not defined when menus are not active
"           NB: g:mt_templates_dirs becomes s:__mt_templates_dirs
"       v2.0.3
"       <*) Use :SourceLocalVimrc to import project local settings before
"           expanding templates
"       v2.0.4
"       (*) It's now possible to inject variables into s:data
"       (*) VimL functions can be defined. However, nested function are not
"       supported (Issue#29)
"       v2.0.5
"       (*) Imports filetype definitions when opening template-files
"       (*) s:__mt_templates_dirs was not updated dynamically when calling
"       :MuTemplate
"       v2.1.0
"       (*) Exploits Tom Link's stakeholders plugin, when installed
"       v2.1.1
"       (*) The template-file for new template-files is now loaded
"       (*) issue#30, mt_IDontWantTemplatesAutomaticallyInserted set in .vimrc
"           is ignored.
"           TODO: def_togle_item should use preexisting values when set
"           «TBT»
"       v2.2.0
"       (*) When several template-files match a snippet name, the choice can be
"           done with |ins-completion-menu| instead of |confirm()| box thanks
"           to: g:mt_chooseWith. When using "complete" a hint is provided with
"           each snippet.
"       (*) The list of options is displayed in a (toggle-) menu
"       (*) Break undo history just before the template is expanded -> |i_CTRL-g_u|
"       (*) Functions moved to autoload plugins
"       v2.2.2
"       (*) new :MUEdit command to open the template-file
"       v2.3.0
"       (*) Surrounding functions
"       v2.3.1
"       (*) "MuT: if" & co conditionals
"       v3.0.0
"       (*) GPLv3
"       (*) :MuTemplate passes its arguments to the template inserted:
"           -> :MuTemplate c/section-sep foobar
"       (*) s:Inject() to add lines to the generated code from VimL code.
"       (*) new option: [bg]:[{ft}_]mt_templates_paths ; requires lh-dev
"       (*) fix: :MUEdit will display discriminant pathnames when all existing
"           template files have the same name (happens in the case of
"           overridden templates)
"       (*) fix: surrounding of line-wise selection
"       (*) fix: surrounding of several lines shall not loop
"       (*) C++ template-file list inherits C *and* doxygen templates.
"       (*) viml expressions can return numbers
"       v3.0.1
"       (*) Always display the choices vertically when g:mt_chooseWith=="confirm"
"       v3.0.2
"       (*) Have doxygen templates available in C
"       (*) Compatible with completion plugins like YouCompleteMe
"       v3.0.3
"       (*) |MuT-snippets| starting at the beginning of a line were not
"           correctly removing the expanded snippet-name -- regression since
"           v3.0.2
"       v3.0.4
"       (*) s:Include() can now forward more than one argument.
"       v3.0.5
"       (*) Author('short') works
"       (*) New templates files for cmake and doxyfile
"       v3.0.6
"       (*) <Plug>MuT_Surround in visual-mode fixed to support counts, with
"           latest versions of Vim
"       (*) Compatibility with completion plugins like YouCompleteMe extended
"           to the surrounding feature.
"       v3.0.7
"       (*) Fix bug to correctly read shorten names like
"           xslt/call-template.template
"       v3.0.8
"       (*) lh#mut#expand_and_jump()/:MuTemplate fixed to receive several
"           parameters
"       v3.1.0
"       (*) Refactorizations
"       (*) New function lh#mut#expand_text()
"       v3.2.0
"       (*) Support for lh#dev styling option :AddStyle
"       v3.2.1
"       (*) s:Param() will search for the key in all params
"           TODO: rethink the way parameters are passed
"       v3.2.1
"       (*) bug fix: MuT: elif... MuT: else was incorrectly managed
"       v3.3.0
"       (*) New feature: post expansion hooks
"       v3.3.2
"       (*) lh#expand*() return the number of the last line where text as been
"           inserted
"       v3.3.3
"       (*) new functions:
"           - to obtain a template definition in a list variable
"             s:GetTemplateLines()
"           - and s:Include_and_map() to include and apply map() on included
"             templates (use case: load a license text and format it as a
"             comment)
"       v3.3.5
"       (*) bug fix: MuT: elif... MuT: else was incorrectly managed (see test3)
"       v3.3.6
"       (*) Some snippets can be common to all filetypes, they are expected to
"       be in {template_root_dir}/_/
"       v3.3.8
"       (*) Bug in g:mt_IDontWantTemplatesAutomaticallyInserted_4_{ft} handling fixed
"       (*) Errors in InterpretCommands are better reported
"       v3.4.0
"       (*) Handling of lh#dev#style#*() fixed
"       v3.4.1
"       (*) New feature: s:StartIndentingHere() in order to handle file headers
"       that shall not be reindented.
"       v3.4.2
"       (*) Fix incorrect line range to reindent
"       v3.4.3
"       (*) + s:IsSurrounding() and s:TerminalPlaceHolder()
"       v3.4.8
"       (*) new support function for TeX snippets: lh#tex#mut#last_title()
"       v3.5.0
"       (*) Fix: Surrounded text is not reformatted through lh-dev apply style
"       feature.
"       v3.5.2
"       (*) Enh: s:Param() returns a reference (i.e. if the element did not
"           exist, it's added)
"       v3.5.3
"       (*) Enh: s:AddPostExpandCallback() and s:Include() exposed as
"           lh#mut#_add_post_expand_callback() and lh#mut#_include() as well.
"       v3.6.0
"       (*) Enh: New "MuT:" command: let
"       v3.6.1
"       (*) WIP: Limiting s:PushArgs() to "routines" started
"       (*) BUG: old vim versions don't have uniq()
"       (*) ENH: more flexible comment format behind 'MuT'
"       v3.6.2
"       (*) ENH: Author() takes a more useful parameter
"       (*) ENH: s:Include() can be used from an expression now
"       v3.7.0
"       (*) BUG: Incorrect use of result of s:LoadTemplate()
"       (*) BUG: Resist to lh-brackets v3.0.0 !jump! deprecation
"       (*) ENH: New function: s:SurroundableParam()
"       (*) ENH: s:Include() can be used from an expression surrounded by
"           text
"       v4.0.0
"       (*) BUG: "MuT:let" does not support variables with digits
"       (*) ENH: "MuT: debug let" is now supported
"       (*) ENH: New function s:ParamOrAsk()
"       (*) BUG: Styling was not applied on expression where /^/ is part of the
"           matching regex
"       (*) DPR: s:Arg() is to be replaced with s:CmdLineParams()
"           Objective: s:args becomes a list of dictionaries
"       v4.0.1
"       (*) BUG: Dirty fix for <+s:Include()+>
"       v4.0.2
"       (*) ENH: Use the new lh-vim-lib logging framework
"       v4.1.0
"       (*) ENH: Using new lh-vim-lib omni-completion engine
"       v4.2.0
"       (*) ENH: Use the new lh-vim-lib logging framework
"       (*) ENH: Store `v:count` into `s:content.count0`
"       v4.3.0
"       (*) ENH: Use new LucHermitte/vim-build-tools-wrapper variables
"       (*) ENH: Support fuzzier snippet expansion
"       (*) REFACT: Remove `DateStamp()`
"       (*) REFACT: Remove SearchInRuntime dependency
"
" BUGS: {{{2
"       Globals should be prefixed. Eg.: g:author .
"       Do something when there is an error in a VimL: command
"
" TODO: {{{2
"       - Re-executing commands. (Can be useful for Last Modified fields).
"       - Change <cword> to alternatives because of 'xsl:i| toto'.
"       - Check it doesn't mess with:
"          - search history, (NOK)
"          - or registers.   (OK)
"       - Documentation: variability points in the standard template-files ;
"       - Menu: enable/disable submenus according the current &filetype.
"         +--> buffermenu.vim
"       - |:undojoin| for interactive template (see cpp/for-iterator)
"         (it seems that the new engine (v2) has fixed the isssue)
"       - Hint for latin2/etc encoding issues: have a s:IncludeConv() that
"         takes the encoding of the file to load as a parameter. Or play with
"         iconv() in |MuT-expression|s.
"       - Change the names of all internal variables to something like s:__{variable}
"       - Find some way to push/pop values into variables for the scope of a
"         call to s:Include. Will be useful with s:fileencoding, s:marker_open,
"         ...
"       - :SourceLocalVimrc hook shall be overidable from $HOME/.vimrc
"       - See how the :SourceLocalVimrc idea could be adapted to the plugin
"         project.vim.
"       - Option to see whether the user prefers vim ask question about names,
"       ..., or whether he prefers to rely on stakeholder (if installed)
"       - With g:mt_chooseWith="complete", using the default choice will
"         trigger an error => find a way to force a real selection of the
"         default choice
"       - Write a helper plugin that will help us navigate in the tree of
"         included templates.
"       - <+s:foo+>foo<+s:Include(...)+><+s:bar+>
"         has many incorrect side-effects
"
"}}}1
"========================================================================
if exists("g:mu_template")
      \ && g:mu_template >= s:k_version
      \ && !exists('g:force_reload_mu_template')
  finish
endif
let g:mu_template = s:k_version
let s:cpo_save=&cpo
set cpo&vim

" Debugging purpose
command! -nargs=1 MUEcho :echo s:<args>

"========================================================================
" Low level functions {{{1
function! s:ErrorMsg(text) abort            " {{{3
  call lh#common#error_msg(a:text)
endfunction
function! s:CheckDeps(Symbol, File, path) " {{{3
  return lh#common#check_deps(a:Symbol, a:File, a:path, 'mu-template')
endfunction
" }}}1
"========================================================================
" Default definitions and options {{{1
function! s:Option(name, default) abort                  " {{{2
  if     exists('b:mt_'.a:name) | return b:mt_{a:name}
  elseif exists('g:mt_'.a:name) | return g:mt_{a:name}
  else                          | return a:default
  endif
endfunction

" g:author : recurrent special variable                    {{{2
function! Author(...) abort
  let short
        \ = a:0 == 0                    ? ''
        \ : type(a:1) == type('string') ? '_'.a:1
        \ : a:1 == 1                    ? '_short'
        \ :                               ''
  if     exists('b:author'.short) | return b:author{short}
  elseif exists('g:author'.short) | return g:author{short}
  elseif exists('$USERNAME')      | return $USERNAME    " win32
  elseif exists('$USER')          | return $USER        " unix
  else                            | return ''
  endif
endfunction

" }}}1
"========================================================================
" Core Functions {{{1

" s:SourceLocalVimrc()                                         {{{2
function! s:SourceLocalVimrc() abort
  if exists(':SourceLocalVimrc')
    try
      :SourceLocalVimrc
    catch /.*/
      echomsg v:exception
    endtry
  endif
endfunction

" s:TemplateOnBufNewFile() triggered by BufNewFile event       {{{2
function! s:TemplateOnBufNewFile() abort
  call s:SourceLocalVimrc()

  call lh#mut#dirs#update()
  " echomsg 's:TemplateOnBufNewFile'
  " let res = s:Template(0)
  let res = lh#mut#expand(0)
  if res && s:Option('jump_to_first_markers',1)
    " Register For After Modeline Event
    call lh#event#register_for_one_execution_at('BufWinEnter', ':call lh#mut#jump_to_start()', 'MuT_AfterModeline')
  endif
  " No more ':startinsert'. It seems useless and redundant with !jump!
  " startinsert
  return res
endfunction

" i_CTRL-R stubbs                                              {{{2
"Note: expand('<cword>') is not correct when there are characters after the
"current curpor position
inoremap <silent> <Plug>MuT_ckword   <C-R>=lh#mut#search_templates(lh#ui#GetCurrentKeyword())<cr>
inoremap <silent> <Plug>MuT_cWORD    <C-R>=lh#mut#search_templates(lh#ui#GetCurrentWord())<cr>
" takes a count to specify where the selected texte goes (see while-snippets)
vnoremap <silent> <Plug>MuT_Surround :<C-U>call lh#mut#surround()<cr>
if !hasmapto('<Plug>MuT_ckword', 'i')
  imap <unique> <C-R><space>  <Plug>MuT_ckword
endif
if !hasmapto('<Plug>MuT_cWORD', 'i')
  imap <unique> <C-R><tab>    <Plug>MuT_cWORD
endif
if !hasmapto('<Plug>MuT_Surround', 'v')
  vmap <unique> <C-R><tab>    <Plug>MuT_Surround
endif

" auto completion                                              {{{2
let s:commands = 'MuT\%[emplate]\|MUEd\%[it]'
function! s:Complete(ArgLead, CmdLine, CursorPos) abort
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

  if cmd !~ s:commands | return '' | endif

  " let ArgLead = substitute(ArgLead, '.*/', '', '')
  " if stridx(ArgLead, '/') == -1
    " let ArgLead =
  " endif
  let s:wildignore = &wildignore
  let &wildignore  = ""
  let ftlist = lh#mut#dirs#shorten_template_filenames(
        \ lh#path#glob_as_list(g:lh#mut#dirs#cache, ArgLead.'*.template'))
  let &wildignore = s:wildignore
  call extend(ftlist, lh#mut#dirs#get_short_list_of_TF_matching(ArgLead.'*', &ft))
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
function! s:AddMenu(m_name, m_prio, nameslist) abort
  let m_name = a:m_name
  let m_name = substitute(m_name, '^\s*\(\S.\{-}\S\)\s*$', '\1', '')
  for name in a:nameslist
    let name = substitute(name, '/', '.\&', 'g')
    if ! ((name =~ '-') && (name !~ '\.&'))
      if lh#mut#verbose() > 0
        echomsg 'amenu '.s:menu_prio.a:m_prio.' '
              \ .escape(s:menu_name.m_name.name, '\ ')
              \ .' :MuTemplate '.substitute(name,'\.&', '/', '').'<cr>'
      endif
      exe 'amenu '.s:menu_prio.a:m_prio.' '
            \ .escape(s:menu_name.m_name.name, '\ ')
            \ .' :MuTemplate '.substitute(name,'\.&', '/', '').'<cr>'
    else
      if &verbose >= 1
        echomsg "muTemplate#s:AddMenu(): discard ".name
      endif
    endif
  endfor
endfunction

" Fonction: s:BuildMenu(doRebuild: boolean)  {{{2
function! s:BuildMenu(doRebuild) abort
  " I expect the menu to have already been loaded.
  menutrans clear
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
  if !exists('s:AutoInsertMenu')
    " not setting idx_crt_value keeps the default value
    let s:AutoInsertMenu = {
          \ "variable": "mt_IDontWantTemplatesAutomaticallyInserted",
          \ "texts": [ 'yes', 'no' ],
          \ "values": [ 0, 1],
          \ "menu": {
          \     "priority": s:menu_prio.'600',
          \     "name": s:menu_name.'&Options.&Automatic Expansion'}
          \}
    call lh#menu#def_toggle_item(s:AutoInsertMenu)

    let s:ChoicesDisplay = {
          \ "variable": "mt_chooseWith",
          \ "idx_crt_value": 0,
          \ "values": [ 'complete', 'confirm'],
          \ "menu": {
          \     "priority": s:menu_prio.'610',
          \     "name": s:menu_name.'&Options.&Choose'}
          \}
    call lh#menu#def_toggle_item(s:ChoicesDisplay)

    let s:AutoJumpToFirstMarker = {
          \ "variable": "mt_jump_to_first_markers",
          \ "texts": [ 'yes', 'no' ],
          \ "values": [ 1, 0],
          \ "idx_crt_value": 0,
          \ "menu": {
          \     "priority": s:menu_prio.'620',
          \     "name": s:menu_name.'&Options.Auto &Jump to 1st placeholder'}
          \}
    call lh#menu#def_toggle_item(s:AutoJumpToFirstMarker)

    let s:HowToJoin = {
          \ "variable": "mt_how_to_join",
          \ "texts": [ '{snippet}\nfoo', '{snippet} foo', '{snippet}<++> foo' ],
          \ "values": [ 0, 1, 2],
          \ "idx_crt_value": 1,
          \ "menu": {
          \     "priority": s:menu_prio.'630',
          \     "name": s:menu_name.'&Options.How to join'}
          \}
    call lh#menu#def_toggle_item(s:HowToJoin)
  endif

  " 4- New File                       {{{3
  try
    let s:wildignore = &wildignore
    let &wildignore  = ""
    call lh#mut#dirs#update()
    " let s:__mt_templates_dirs = s:TemplateDirs()
    let new_list = lh#mut#dirs#shorten_template_filenames(
          \ lh#path#glob_as_list(g:lh#mut#dirs#cache, '*.template'))
          "NAMES WERE: \ lh#path#glob_as_list(g:lh#mut#dirs#cache, 'template.*'))
    call s:AddMenu('&New.&', '100.10', new_list)

    " 5- constructs                   {{{3
    " The following is very slow to build, updating hints doesn't help
    let ft_list = lh#mut#dirs#get_short_list_of_TF_matching('*', '*')
    call s:AddMenu('&', '300.10', ft_list)

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
let s:mut_rtp_root = expand('<sfile>:p:h:h:h')
function! s:Help() abort
  let errmsg_save = v:errmsg
  let v:errmsg = ''
  silent! help mu-template
  if v:errmsg != ""
    echomsg 'helptags ' . s:mut_rtp_root.'/doc'
    exe 'helptags ' . s:mut_rtp_root.'/doc'
    silent help mu-template
  endif
  let v:errmsg = errmsg_save
endfunction
" Help }}}1
"========================================================================
" API for Wizards {{{1
function! MuTemplate(template, data) abort
  silent! unlet s:data " required as its type may change
  let s:data = a:data
  return lh#mut#expand_and_jump(0, a:template, a:data)
endfunction

" [auto]commands {{{1
command! -nargs=* -complete=custom,<sid>Complete MuTemplate :call lh#mut#expand_and_jump(0, <f-args>)
command! -nargs=? -complete=custom,<sid>Complete MUEdit     :call lh#mut#edit(<f-args>)

function! s:AutomaticInsertion() abort
  if !exists('g:mt_IDontWantTemplatesAutomaticallyInserted') ||
        \ !g:mt_IDontWantTemplatesAutomaticallyInserted
    return 1
  elseif strlen(&ft) &&
        \ (exists('g:mt_IDontWantTemplatesAutomaticallyInserted_4_'.&ft) &&
        \ !g:mt_IDontWantTemplatesAutomaticallyInserted_4_{&ft})
    return 1
  else
    return 0
  endif
endfunction

function! s:FTDetection4Templates(filename, event) abort
  call s:SourceLocalVimrc() " update project local paths
  call lh#mut#dirs#update()
  let dir = fnamemodify(a:filename, ':h')
  let reldir = lh#path#strip_start(dir, g:lh#mut#dirs#cache)
  if reldir == dir
    if lh#mut#verbose() > 0
      echomsg "Not a MutTemplate template-file (".a:filename.")"
    endif
    return
  endif

  if empty(reldir)
    let ft = fnamemodify(a:filename, ':t:r')
  else
    let ft = matchstr(reldir, '^[^/\\]\+')
  endif
  if strlen(ft)
    exe 'set ft='.ft
  else
    exe ("doau filetypedetect BufRead " . a:filename)
  endif
  let b:ft = &ft
  set ft=template
  " Finally run mu-template
  if a:event == 'new' && s:AutomaticInsertion()
    call <SID>TemplateOnBufNewFile()
  endif
endfunction

augroup MuTemplate
  au!
  au BufNewFile * if s:AutomaticInsertion() | call <SID>TemplateOnBufNewFile() | endif
  "au BufWritePre * echon 'TODO'
  "au BufWritePre * normal ,last

  " Syntax HL & ft detection of template files
  au BufRead    *.template  call <sid>FTDetection4Templates(expand('<afile>:p'), 'read')
  au BufNewFile *.template  call <sid>FTDetection4Templates(expand('<afile>:p'), 'new')
augroup END
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"========================================================================
" vim60: set fdm=marker:
