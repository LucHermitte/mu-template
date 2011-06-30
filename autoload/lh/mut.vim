"=============================================================================
" $Id$
" File:         autoload/lh/mut.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      2.4.0
" Created:      05th Jan 2011
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       mu-template internal functions
"       The purpose of this autoload plugin is to provide a lazy-loading of
"       mu-template functions.
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh
"       Requires Vim7+
"       See plugin/mu-template.vim
" History:
"	v2.3.0
"	(*) expressions can be expanded from placeholders (Issue#37)
"	v2.3.0
"	(*) Surrounding functions
"	v2.2.2
"	(*) new :MUEdit command to open the template-file
" 	2.2.1
" 	(*) make sure the lines inserted are unfolded
" 	(*) s:Include() and MuTemplate() supports parameters
" 	(*) Bug in embedded functions support: ":endfor" was misinterpreted for
" 	    ":endf\%[unction]"
" 	v2.2.0
" 	(*) first version
" TODO: See plugin/mu-template.vim
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 222
function! lh#mut#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#mut#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#mut#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
" Function: lh#mut#edit(path) {{{2
function! lh#mut#edit(path)
  call lh#mut#dirs#update()
  let dir = fnamemodify(a:path, ':h')
  if dir != "" | let dir .= '/' | endif
  let ft  = fnamemodify(a:path, ':t')
  let path =  dir.ft.'.template'

  try
    let wildignore = &wildignore
    let &wildignore  = ""

    " let matching_filenames = lh#path#glob_as_list(g:lh#mut#dirs#cache, path)
    let matching_filenames = lh#path#glob_as_list(g:lh#mut#dirs#cache, path)
    if len(matching_filenames) == 0
      call lh#common#error_msg("No template file matching `".a:path."'")
      let choice = -1
    elseif len(matching_filenames) == 1
      let choice = 0
    else
      let short_names = lh#mut#dirs#shorten_template_filenames(copy(matching_filenames))
      let strings = join(short_names, "\n")
      let choice = confirm("Which template do you wish to edit?",
            \ "&Abort\n".strings, 1) - 2
    endif
    if choice < 0 | return | endif
    call lh#buffer#jump(matching_filenames[choice], 'sp')
  finally
    let &wildignore = wildignore
  endtry
endfunction

" Function: lh#mut#expand(NeedToJoin, ...) {{{2
function! lh#mut#expand(NeedToJoin, ...)
  " echomsg 'lh#mut#expand('.a:NeedToJoin.string(a:000).')'
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
    call  s:LoadTemplate(0, dir.ft.'.template')

    " 2.0 Reset default settings
    " clear any function definition
    let s:__function = []
    " Default values for placeholder characters (they can be overridden in each
    " template file).
    let s:marker_open  = '<+'
    let s:marker_close = '+>'
    " Default support for evaluation of placeholder-text
    silent! unlet s:dont_eval_markers 
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
	  call lh#common#warning_msg('muTemplate: This vim executable cannot convert the text from "'.s:fileencoding.'" to &enc="'.&enc.'" as requested by the template-file')
	endif
      endif
      " @post: :functions must be fully defined
      if !empty(s:__function)
	throw 'function definition not terminated (:enfunction expected)'
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
      " Activate Tom Link's Stakeholders in case it is installed
      if exists(':StakeholdersEnable') && s:Option('use_stakeholders', 1)
	if !exists('#stakeholders') " Stakeholder not enabled for all buffers
	  if !exists('b:stakeholders') || exists('b:stakeholders_range')
	    " previously activated on a range, or never activated
	    " echomsg "try EnableInRange(".pos.','.last.')'
	    " Reset previous range
	    call stakeholders#DisableBuffer()
	    " Set new range in case there is no global activation
	    call stakeholders#EnableInRange(pos, last)
	  else
	    " echomsg "already activated for the current buffer ?"
	  endif
	else " Stakeholders Enabled for all buffers
	  if exists('b:stakeholders')
	    " Relaunch for the new global range
	    call stakeholders#DisableBuffer()
	    call stakeholders#EnableBuffer()
	  else
	    " echomsg "leave it to autocmds?"
	    call stakeholders#EnableBuffer()
	  endif
	endif
      endif " Stakeholders installed

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
    let s:args=[]
    " and unfold the lines inserted
    if &foldenable
      silent! exe (pos).','.(last).'foldopen!'
    endif
  endtry
  " }}}3
endfunction

" Function: lh#mut#jump_to_start() {{{2
function! lh#mut#jump_to_start()
  " echomsg 'lh#mut#jump_to_start()'
  " set foldopen+=insert,jump
  " Need to be sure there was a marker in the text inserted
  let marker_line = lh#list#match(s:content.lines, Marker_Txt('.\{-}'))
  let therewasamarker = -1 != marker_line
  if therewasamarker
    " echomsg "jump from ".(marker_line+s:content.start)
    exe (marker_line+s:content.start)
    " normal! zO
    try
      let save_gscf = lh#option#get('marker_select_current_fwd', 1)
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

" Function: lh#mut#expand_and_jump(needToJoin, ...)        {{{2
function! lh#mut#expand_and_jump(needToJoin, ...)
  " echomsg "lh#mut#expand_and_jump"
  try 
    call lh#mut#dirs#update()
    let s:args = []
    if a:0 > 1
      call s:PushArgs([a:2])
      " echomsg 'all: ' . string(s:args)
    endif
    let res = (a:0>0)
	  \ ? lh#mut#expand(a:needToJoin, a:1)
	  \ : lh#mut#expand(a:needToJoin)
    if res && s:Option('jump_to_first_markers',1)
      call lh#mut#jump_to_start()
    endif
    return res
  finally
    let s:args=[]
  endtry
endfunction

" Function: lh#mut#surround()                                  {{{2
function! lh#mut#surround()
  try 
    " 1- ask which template to execute {{{3
    let which = INPUT("which snippet?")
    let files = lh#mut#dirs#get_short_list_of_FT_matching(which.'*', &ft)

    let nbChoices = len(files)
    " call confirm(nbChoices."\n".files, '&ok', 1)
    if (nbChoices == 0)
      call lh#common#error_msg("muTemplate: No template file matching <".which."> for ".&ft." files")
      return ""
    elseif (nbChoices > 1)
      let save_choose_method = g:mt_chooseWith
      try 
        let g:mt_chooseWith = 'confirm'
        let choice = s:ChooseTemplateFile(files, which)
      finally
        let g:mt_chooseWith = save_choose_method
      endtry
      if choice <= 1 | return "" | endif
    else
      let choice = 2
    endif
    " File <- n^th choice
    let file = files[choice - 2]

    " 2- extract the thing to be surrounded {{{3
    let surround_id = 'surround'.v:count1
    let s:content[surround_id] = lh#visual#cut()

    " 3- insert the template {{{3
    " return s:InsertTemplateFile(a:word,file)
    if !lh#mut#expand_and_jump(0,file)
      call lh#common#error_msg("muTemplate: Problem to insert the template: <".a:file.'>')
    endif
    return ''
  finally
    silent! unlet s:content[surround_id]
  endtry
endfunction
"------------------------------------------------------------------------
" Function: lh#mut#search_templates(word)                      {{{2
function! lh#mut#search_templates(word)
  let s:args = []
  " 1- Build the list of template files matching the current word {{{3
  let w = substitute(a:word, ':', '-', 'g').'*'
  " call confirm("w =  #".w."#", '&ok', 1)
  let files = lh#mut#dirs#get_short_list_of_FT_matching(w, &ft)

  " 2- Select one template file only {{{3
  let nbChoices = len(files)
  " call confirm(nbChoices."\n".files, '&ok', 1)
  if (nbChoices == 0)
    call lh#common#warning_msg("muTemplate: No template file matching <".w."> for ".&ft." files")
    return ""
  elseif (nbChoices > 1)
    let choice = s:ChooseTemplateFile(files, w)
    if choice <= 1 | return "" | endif
  else
    let choice = 2
  endif

  " File <- n^th choice
  let file = files[choice - 2]
  " call confirm("choice=".choice."\nfile=".file, '&ok', 1)

  " 3- Template-file to insert ? {{{3
  return s:InsertTemplateFile(a:word,file)
endfunction
"------------------------------------------------------------------------
" ## Internal functions {{{1
" Tools functions                                          {{{2
function! s:Option(name, default)                        " {{{3
  if     exists('b:mt_'.a:name) | return b:mt_{a:name}
  elseif exists('g:mt_'.a:name) | return g:mt_{a:name}
  else                          | return a:default
  endif
endfunction

" let s:value_start = '%%%('
" let s:value_end   = ')'
let s:value_start = '¡'
let s:value_end   = '¡'
function! s:Value(text)            " {{{3
  return '\%('.s:value_start . a:text . s:value_end.'\)'
endfunction

function! s:Command(text)          " {{{3
  return 'VimL:' . a:text
endfunction

function! s:Comment(text)          " {{{3
  return s:Command('" '.a:text)
endfunction

" function! s:PushArgs()             {{{3
function! s:PushArgs(args)
  call add(s:args, a:args)
endfunction

" function! s:PopArgs()              {{{3
function! s:PopArgs()
  if !empty(s:args)
    call remove(s:args, -1)
  endif
endfunction

" function! s:Args()                 {{{3
" @returns a list. If the list is empty, this mean no parameter was given.
let s:args = []
function! s:Args()
  " echomsg string(s:args)
  return empty(s:args) ? [] : s:args[-1]
endfunction

" function! s:Include()              {{{3
function! s:Include(template, ...)
  let pos = s:content.crt
  " let correction = s:NeedToJoin > 0
  let correction = 0
  let dir = fnamemodify(a:template, ':h')
  if dir != "" | let dir .= '/' | endif
  if a:0>0 && !empty(a:1)
    let dir .= a:1 . '/'
  endif
  " pushing a list permit to test the void args case
  " todo: mark the line where s:Pop should be applied
  call s:PushArgs(a:0>1 ? [a:2] : [])
  if 0 == s:LoadTemplate(pos-correction, dir.a:template.'.template')
    call lh#common#warning_msg("muTemplate: No template file matching <".dir.a:template.'.template'.">\r".'dir='.dir.'|'.a:template.'|'.string(a:000))
  endif
endfunction

function! s:path_from_root(path)   " {{{3
  let path = a:path
  if exists('b:sources_root')
    let s = strlen(b:sources_root)
    if b:sources_root[s-1] !~ '/\|\\'
      let b:sources_root .=
	    \ ((!exists('shellslash')||&shellslash)?'/':'\')
      let s += 1
    endif
    let p = stridx(path, b:sources_root)
    if 0 == p
      let path = strpart(path, s)
    endif
  endif
  return path
endfunction

" function s:Surround(id, default)   {{{3
function! s:Surround(id, default)
  let key = 'surround'.a:id
  return has_key(s:content,key)
        \ ? (s:content[key])
        \ : (a:default)
  endif
endfunction

" function s:Line()                  {{{3
" Returns current line
function! s:Line()
  return s:content.crt + s:content.start
endfunction

" {[bg]:mt_jump_to_first_markers}                          {{{3
" Boolean: specifies whether we want to jump to the first marker in the file.

" How to join with next line : {[bg]:mt_how_to_join}       {{{3
"   Used only with i_CTRL-R_TAB
"   == 0 : "{pattern}^r\t foo" -> "{the template}\nfoo"
"   == 1 : "{pattern}^r\t foo" -> "{the template} foo"
"   == 2 : "{pattern}^r\t foo" -> "{the template}«» foo"

" }}}2
"------------------------------------------------------------------------
" Core Functions {{{2
let s:content = { 'lines' : [], 'crt' : 0, 'start' : 0}

function! s:LoadTemplate(pos, templatepath)                  " {{{3
  " echomsg "s:LoadTemplate(".a:pos.", '".a:templatepath."')"
  try
    let wildignore = &wildignore
    let &wildignore  = ""

    let matching_filenames = lh#path#glob_as_list(g:lh#mut#dirs#cache, a:templatepath)
    if len(matching_filenames) == 0
      return 0 " NB: the finally block is still executed
      " call lh#common#warning_msg("muTemplate: No template file matching <".a:templatepath.">")
    else
      if &verbose >= 1
	echo "Loading <".matching_filenames[0].">"
      endif
      let lines = readfile(matching_filenames[0])
      let lines += [ 'VimL: call s:PopArgs()']
      call extend(s:content.lines, lines, a:pos)
      " echomsg string(s:content)
    endif
  finally
    let &wildignore = wildignore
  endtry
  return len(s:content.lines)
endfunction

" s:InterpretValue() will interpret a sequence between ¡.\{-}¡ {{{3
" ... and return the computed value.
" To possibly expand a sequence into an empty string, use the
" 'bool_expr ?  act1 : act2' VimL operator ; cf vim.template for examples of
" use.
function! s:InterpretValue(what)
  try
    " todo: can we use eval() now?
    exe 'let s:__r = ' . a:what
    " NB: cannot use a local variable, hence the "s:xxxx"
    return s:__r
  catch /.*/
    call lh#common#warning_msg("muTemplate: Cannot interpret `".a:what."': ".v:exception)
    return a:what
  endtry
endfunction

" s:InterpretCommand() will interpret a sequence 'VimL:.*'     {{{3
" ... and return nothing
" Back-Door to trojans !!!
function! s:InterpretCommand(what)
  try
    if empty(s:__function)
      if a:what =~ '^:\?fu\%[nction]'
	let s:__function += [a:what]
      elseif a:what =~ '^:\?endf\%[unction]'
	throw 'not within the definition of a function'
      else
	exe a:what
      endif
    else
      if a:what =~ '^:\?fu\%[nction]'
	throw 'already within the definition of a function (nested functions are not supported (yet))'
      else
	let s:__function += [a:what]
	if a:what !~ '^:\?endfo\%[r]' && a:what =~ '^:\?endf\%[unction]'
	  let fn_def = join(s:__function, "\n")
	  let s:__function = []
	  exe fn_def
	endif " :endfunction
      endif " != :function
    endif
  catch /.*/
    call lh#common#warning_msg("muTemplate: Cannot execute `".a:what."': ".v:exception)
    throw "muTemplate: Cannot execute `".a:what."': ".v:exception
  endtry
endfunction

" s:InterpretValues(line) ~ eval expressions in {line}         {{{3
function! s:InterpretValues(line)
  " @pre must not be defining VimL functions
  if !empty(s:__function)
    throw 'already within the definition of a function (no non-VimL code authorized)'
  endif

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

" s:InterpretMarkers(line) ~ eval markers as expr in {line}    {{{3
" todo merge with s:InterpretValues
function! s:InterpretMarkers(line)
  " @pre must not be defining VimL functions
  if !empty(s:__function)
    throw 'already within the definition of a function (no non-VimL code authorized)'
  endif

  let res = ''
  let tail = a:line
  let re =  '\(.\{-}\)'.s:Marker('\(.\{-}\)').'\(.*\)'
  let may_merge = 0
  while strlen(tail)!=0
    let split = matchlist(tail, re)
    if len(split) <2 || strlen(split[0]) == 0
      " nothing found
      let res .= tail
      let tail = ''
      " let may_merge = 0
    else
      try 
        let value = eval(split[2])
      catch /.*/
        let value = Marker_Txt(split[2])
      endtry
      let res .= split[1] . value
      let tail = split[3]
      let may_merge = 1
    endif
  endwhile
  " echomsg "may_merge=".may_merge."  ---  ".res
  return res
  " return { 'line' : res, 'may_merge' : may_merge }
endfunction

" s:NoRegex(text)                                              {{{3
function! s:NoRegex(text)
  return escape(a:text, '\.*/')
endfunction

" s:Marker(text)                                               {{{3
function! s:Marker(regex)
  return s:NoRegex(s:marker_open) . a:regex . s:NoRegex(s:marker_close)
endfunction

function! s:InterpretLines(first_line)                       " {{{3
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
      call s:InterpretCommand( matchstr(the_line, '\c'.s:Command('\s*').'\zs.*'))
    elseif the_line !~ '^\s*$'
      " NB 1- We must know the expression characters before any interpretation.
      "    2- :r inserts an empty line before the template loaded
      "    => We do not interpret empty lines
      "    => s:value_start and s:value_end must always be specified!

      if s:Marker('') != markerCharacters
	" Replaces plain marker characters into current marker characters.
        if exists('s:dont_eval_markers') && s:dont_eval_markers
          let the_line = substitute(the_line, s:Marker('\(.\{-}\)'), Marker_Txt('\1'), 'g')
        else
          let the_line = s:InterpretMarkers(the_line)
        endif
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

" function! s:Reencode()                                       {{{3
function! s:Reencode()
  call map(s:content.lines, 'lh#encoding#iconv(v:val, '.string(s:fileencoding).', &enc)')
endfunction

" s:IsKindOfEmptyLine(lineNo)                                  {{{3
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

" s:ChooseByComplete()                                         {{{3
function! s:ChooseByComplete()
  let entries = []
  let i = 0
  for file in s:__complete.files
    call add(entries, {"word": file, "menu": (lh#mut#dirs#hint(file)) })
  endfor
  let c = col('.')
  let l = c - strlen(s:__complete.word) +1 
  let s:__complete.c = l
  let g:entries = {"c":c, "l":l, "entries": entries}
  " inoremap <buffer> <silent> <cr> <c-\><c-n>:call <sid>FinishCompletion()<cr>
  call lh#icomplete#run(l, entries, (s:getSNR()."FinishCompletion"))
  return ''
endfunction

" s:FinishCompletion()                                         {{{3
function! s:FinishCompletion()
  let l =getline('.')
  let choice = l[(s:__complete.c-1) : (col('.')-1)]
  " echomsg "finishing! ->" . choice
  let post_action = s:InsertTemplateFile(choice, choice)
  if !empty(post_action)
    exe "normal ".post_action
  else
    call lh#common#error_msg("No template associated to ".choice)
  endif
endfunction

" s:getSNR()                                                   {{{3
function! s:getSNR()
  if !exists("s:SNR")
    let s:SNR=matchstr(expand("<sfile>"), "<SNR>\\d\\+_\\zegetSNR$")
  endif
  return s:SNR 
endfunction

" s:ChooseTemplateFile(files)                                  {{{3
function! s:ChooseTemplateFile(files, word)
  if g:mt_chooseWith == 'confirm'
    let strings = join(a:files, "\n")
    let choice = confirm("Which template do you wish to use ?",
	  \ "&Abort\n".strings, 1)
  elseif g:mt_chooseWith == 'complete'
    try
      let s:__complete = {}
      let s:__complete.files = a:files
      let s:__complete.word  = a:word
      call feedkeys ("\<c-r>=".s:getSNR()."ChooseByComplete()\<cr>")
      " call feedkeys("\<c-x>\<c-u>")
      " call feedkeys("\<c-o>:call ".s:getSNR()."FinishCompletion()\<cr>")
      let choice = 0
    finally
    endtry
  else
    throw "muTemplate: Invalid value for g:mt_chooseWith option"
  endif
  return choice
endfunction

" s:InsertTemplateFile(word,file)                              {{{3
function! s:InsertTemplateFile(word,file)
  if "" != a:file " 3.A- => YES there is one {{{4
    " 3.1- Remove the current word {{{5
    " Note: <esc> is needed to escape from "Visual insertion mode"
    " TODO: manage a blinking pb
    let l = strlen(a:word)	" No word to expand ; abort
    if     0 == l
    elseif 1 == l		" Select a one-character length word
      silent exe "normal! \<esc>vc\<c-g>u\<esc>"
    else			" Select a 1_n-characters length word
      let ew = escape(a:word, '\.*[/')
      call search(ew, 'b')
      silent exe "normal! \<esc>v/".ew."/e\<cr>c\<c-g>u\<esc>"
      " exe "normal! \<esc>viWc\<esc>"
    endif
    " Insert a line break
    silent exe "normal! i\<cr>\<esc>\<up>$"

    " 3.2- Insert the template {{{5
    if &verbose >= 1
      call confirm("Using the template file: <".a:file.'>', '&ok', 1)
    endif
    " Todo: check what happens with g:mt_jump_to_first_markers off
    if !lh#mut#expand_and_jump(s:Option('how_to_join',1),a:file)
      call lh#common#error_msg("Hum... problem to insert the template: <".a:file.'>')
    endif
    " Note: <esc> is needed to escape from "Visual insertion mode"
    " Workaround a change in Vim 7.0 behaviour
    return "\<c-\>\<c-n>\<c-\>\<c-n>gv\<c-g>"
    " return "\<esc>\<right>"
  else          " 3.B- No template file available for the current word {{{4
    return ""
  endif " }}}4
endfunction
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
