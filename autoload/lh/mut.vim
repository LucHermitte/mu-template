"=============================================================================
" File:         autoload/lh/mut.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/mu-template>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/mu-template/blob/master/License.md>
" Version:      4.3.1
let s:k_version = 431
" Created:      05th Jan 2011
" Last Update:  09th Mar 2018
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
"       v4.3.1
"       (*) PORT: Fix unletting in `MuT: let`
"       (*) ENH: Add way to inject parameters in parent ctx
"       v4.3.0
"       (*) ENH: Use new LucHermitte/vim-build-tools-wrapper variables
"       (*) ENH: Support fuzzier snippet expansion
"       (*) ENH: Add `s:IncludeSeveralSnippets()`
"       (*) ENH: Use new stylistic API from lh-dev
"       (*) BUG: Fix surrounding with Python control-statements
"       v4.2.0
"       (*) ENH: Use the new lh-vim-lib logging framework
"       (*) ENH: Store `v:count` into `s:content.count0`
"       v4.1.0
"       (*) ENH: Using new lh-vim-lib omni-completion engine
"       v4.0.1
"       (*) BUG: Dirty fix for <+s:Include()+>
"       v4.0.0
"       (*) BUG: "MuT:let" does not support variables with digits
"       (*) ENH: "MuT: debug let" is now supported
"       (*) ENH: New function s:ParamOrAsk()
"       (*) BUG: Styling was not applied on expression where /^/ is part of the
"           matching regex
"       (*) DPR: s:Arg() is to be replaced with s:CmdLineParams()
"           Objective: s:args becomes a list of dictionaries
"       v3.7.0
"       (*) BUG: Incorrect use of result of s:LoadTemplate()
"       (*) BUG: Resist to lh-brackets v3.0.0 !jump! deprecation
"       (*) ENH: New function: s:SurroundableParam()
"       (*) ENH: s:Include() can be used from an expression surrounded by
"           text
"       v3.6.2
"       (*) ENH: s:Include() can be used from an expression now
"       v3.6.1
"       (*) WIP: Limiting s:PushArgs() to "routines" started
"       (*) BUG: old vim versions don't have uniq()
"       (*) ENH: more flexible comment format behind 'MuT'
"       v3.6.0
"       (*) Enh: New "MuT:" command: let
"       v3.5.3
"       (*) Enh: s:AddPostExpandCallback() and s:Include() exposed as
"           lh#mut#_add_post_expand_callback() and lh#mut#_include() as well.
"       v3.5.2
"       (*) Enh: s:Param() returns a reference (i.e. if the element did not
"           exist, it's added)
"       v3.5.0
"       (*) Fix: Surrounded text is not reformatted through lh-dev apply style
"       feature.
"       v3.4.6
"       (*) + s:IsSurrounding() and s:TerminalPlaceHolder()
"       v3.4.2
"       (*) Fix incorrect line range to reindent
"       v3.4.1
"       (*) New feature: s:StartIndentingHere() in order to handle file headers
"       that shall not be reindented.
"       v3.4.0
"       (*) Handling of lh#dev#style#*() fixed
"       v3.3.8
"       (*) Errors in InterpretCommands are better reported
"       v3.3.5
"       (*) bug fix: MuT: elif... MuT: else was incorrectly managed (see test3)
"       v3.3.3
"       (*) new functions:
"           - to obtain a template definition in a list variable
"             s:GetTemplateLines()
"           - and s:Include_and_map() to include and apply map() on included
"             templates (use case: load a license text and format it as a
"             comment)
"       v3.3.2
"       (*) lh#expand*() return the number of the last line where text as been
"           inserted
"       v3.3.0
"       (*) New feature: post expansion hooks
"       v3.2.1
"       (*) bug fix: MuT: elif... MuT: else was incorrectly managed
"       v3.2.1
"       (*) s:Param() will search for the key in all params
"           TODO: rethink the way parameters are passed
"       v3.2.0
"       (*) Support for lh#dev styling option :AddStyle
"       v3.1.0
"       (*) Refactorizations
"       (*) New function lh#mut#expand_text()
"       v3.0.8
"       (*) lh#mut#expand_and_jump()/:MuTemplate fixed to receive several
"           parameters
"       v3.0.6
"       (*) Compatibility with completion plugins like YouCompleteMe extended
"           to the surrounding feature.
"       v3.0.4
"       (*) s:Include() can now forward more than one argument.
"       v3.0.3
"       (*) |MuT-snippets| starting at the beginning of a line were not
"       correctly removing the expanded snippet-name.
"       v3.0.2
"       (*) Compatible with completion plugins like YouCompleteMe
"       v3.0.1
"       (*) Always display the choices vertically when g:mt_chooseWith=="confirm"
"       (*) Issue#46: No longer use default shortcuts with "confirm"
"           selection-mode for vim under console.
"       v3.0.0
"       (*) s:Inject() to add lines to the generated code from VimL code.
"       (*) fix: surrounding of line-wise selection
"       v2.3.1
"       (*) "MuT: if" & co conditionals
"       (*) expressions can be expanded from placeholders (Issue#37)
"       v2.3.0
"       (*) Surrounding functions
"       v2.2.2
"       (*) new :MUEdit command to open the template-file
"       2.2.1
"       (*) make sure the lines inserted are unfolded
"       (*) s:Include() and MuTemplate() supports parameters
"       (*) Bug in embedded functions support: ":endfor" was misinterpreted for
"           ":endf\%[unction]"
"       v2.2.0
"       (*) first version
" TODO: See plugin/mu-template.vim
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#mut#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#mut#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(...)
  call call('lh#log#this', a:000)
endfunction

function! s:Verbose(...)
  if s:verbose
    call call('s:Log', a:000)
  endif
endfunction

function! lh#mut#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
" Function: lh#mut#edit(path) {{{2
function! lh#mut#edit(path) abort
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
      " in case they all have the same name, we must display the provenance
      if len(short_names) > 1 && short_names[0] == short_names[1]
        let short_names = copy(matching_filenames)
        let short_names = lh#path#strip_common(short_names)
      endif
      let strings = join(short_names, "\n")
      try
        let save_guioptions = &guioptions
        set guioptions+=v
        let choice = confirm("Which template do you wish to edit?",
              \ "&Abort\n".strings, 1) - 2
      finally
        let &guioptions = save_guioptions
      endtry
    endif
    if choice < 0 | return | endif
    call lh#buffer#jump(matching_filenames[choice], 'sp')
  finally
    let &wildignore = wildignore
  endtry
endfunction

" Function: lh#mut#expand(NeedToJoin, ...)                 {{{2
function! lh#mut#expand(NeedToJoin, ...) abort
  call s:Verbose('lh#mut#expand(%1)', [a:NeedToJoin]+a:000)
  let s:content.lines = []

  " 1- Determine the name of the template file expected {{{3
  if a:0 > 0
    let dir = fnamemodify(a:1, ':h')
    if dir != "" | let dir .= '/' | endif
    let ft  = fnamemodify(a:1, ':t')
    " first option : the template file is specified ; cf. cpp/template-class
  else
    let ft=strlen(&ft) ? &ft : 'unknown'
    let dir = ''
    " otherwise (default) : the template file is function of the current
    " filetype
  endif

  " 2- Prepare the new session {{{3
  call s:ResetContext()

  " 3- Load the associated template {{{3
  call s:LoadTemplate(0, dir.ft.'.template')
  " call s:Verbose("Template loaded: %1", s:content.lines)

  " 4- Expand the lines {{{3
  return s:DoExpand(a:NeedToJoin)
endfunction "}}}3

" Function: lh#mut#expand_text(NeedToJoin, text, ...)      {{{2
function! lh#mut#expand_text(NeedToJoin, text, ...) abort
  call s:Verbose('lh#mut#expand_text(%1)', [a:NeedToJoin, a:text] + a:000)
  let s:content.lines = type(a:text) == type([]) ? a:text : split(a:text, "\n")
  try
    let s:args = []
    if a:0 > 1
      call s:PushArgs(a:000[1:])
      " echomsg 'all: ' . string(s:args)
    endif
    call s:ResetContext()
    let res = s:DoExpand(a:NeedToJoin)
    if res && s:Option('jump_to_first_markers',1)
      call lh#mut#jump_to_start()
      " return [res, lh#mut#jump_to_start()]
    endif
    " return [res, '']
    return res
  finally
    let s:args = []
  endtry
endfunction

" Function: lh#mut#jump_to_start()                         {{{2
function! lh#mut#jump_to_start() abort
  call s:Verbose('lh#mut#jump_to_start()')
  " set foldopen+=insert,jump
  " Need to be sure there was a marker in the text inserted
  let marker_line = lh#list#match(s:content.lines, lh#marker#txt('.\{-}'))
  let s:therewasamarker = -1 != marker_line
  if s:therewasamarker
    " echomsg "jump from ".(marker_line+s:content.start)
    exe (marker_line+s:content.start)
    " normal! zO
    let cleanup = lh#on#exit()
          \.restore_option('marker_select_current_fwd')
    try
      let b:marker_select_current_fwd = 1
      exe "normal \<Plug>MarkersJumpF"
      " return Marker_Jump({'direction':1, 'mode':'i'})
    finally
      call cleanup.finalize()
    endtry
  else
    :exe s:moveto
  endif
  " return ''
endfunction

" Function: lh#mut#expand_and_jump(needToJoin, ...)        {{{2
function! lh#mut#expand_and_jump(needToJoin, ...) abort
  call s:Verbose("lh#mut#expand_and_jump(".a:needToJoin.",".join(a:000, ',').")")
  try
    call lh#mut#dirs#update()
    let s:args = []
    if a:0 > 1
      " When calling from :MuTemplate, the type of the elements will be string
      let arg = type(a:2) == type('string') ? {'cmdline': a:000[1:]} : a:000[1:]
      call s:PushArgs(arg)
      " echomsg 'all: ' . string(s:args)
    endif
    let res = (a:0>0)
          \ ? lh#mut#expand(a:needToJoin, a:1)
          \ : lh#mut#expand(a:needToJoin)
    if res && s:Option('jump_to_first_markers',1)
      " return [res, lh#mut#jump_to_start()]
      call lh#mut#jump_to_start()
    endif
    return res
    " return [res, '']
  finally
    let s:args=[]
  endtry
endfunction

" Function: lh#mut#surround()                              {{{2
function! lh#mut#surround() abort
  try
    " 1- ask which template to execute {{{3
    let which = lh#ui#input("which snippet?")
    let files = lh#mut#dirs#get_short_list_of_TF_matching(which.'*', &ft)

    let nbChoices = len(files)
    " call confirm(nbChoices."\n".files, '&ok', 1)
    if (nbChoices == 0)
      call lh#common#error_msg("muTemplate: No template file matching <".which."> for ".&ft." files")
      return ""
    elseif (nbChoices > 1)
      let save_choose_method = s:Option('chooseWith', 'complete')
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
    let s:content.count0 = v:count
    let surround_id = 'surround'.v:count1
    let s:content[surround_id] = lh#visual#cut()
    " The following hack is required in line-wise surrounding to not expand the
    " template-file after the first line after the one surrounded.
    if s:content[surround_id] =~ "\n$" " line-wise surrounding
      silent put!=''
    endif
    if stridx(s:content[surround_id], "\n") < 0 " suppose this is on a single-line
      let l = strlen(s:content[surround_id])
      let line = getline('.')
      let pos = getpos('.')
      " Clear the line from the word to expand
      if pos[2] > 1
        call setline('.', line[0:pos[2]-2])
      else
        call setline('.', '')
      endif
      " Insert a line break
      " call append('.', line[(pos[2]-1+l):])
      call append('.', line[(pos[2]-1):])
      call setpos('.', pos)
    endif

    " 3- insert the template {{{3
    let s:content.is_surrounding = 1
    let s:content.surrounding_with = visualmode()
    let NeedToJoin = s:content.surrounding_with != 'V'
    if !lh#mut#expand_and_jump(NeedToJoin,file)
      call lh#common#error_msg("muTemplate: Problem to insert the template: <".a:file.'>')
    endif
    return ''
  finally
    silent! unlet s:content[surround_id]
    silent! unlet s:content.is_surrounding
    silent! unlet s:content.surrounding_with
  endtry
endfunction
"------------------------------------------------------------------------
" Function: lh#mut#search_templates(word)                  {{{2
function! lh#mut#search_templates(word) abort
  call s:Verbose('Expand snippet for `%1`', a:word)
  let s:args = []
  " 1- Build the list of template files matching the current word {{{3
  " The substitute() is used with languages like xlst
  let w = '*'.substitute(a:word, ':', '-', 'g').'*'
  " let w = substitute(a:word, ':', '-', 'g').'*'
  " call confirm("w =  #".w."#", '&ok', 1)
  let files = lh#mut#dirs#get_short_list_of_TF_matching(w, &ft)

  " 2- Select one template file only {{{3
  let nbChoices = len(files)

  call s:Verbose("%1 choices:\n%2", nbChoices, files)
  if (nbChoices == 0)
    call lh#common#warning_msg("muTemplate: No template file matching <".w."> for ".&ft." files")
    return ""
  elseif (nbChoices > 1)
    let choice = s:ChooseTemplateFile(files, a:word)
    if choice <= 1 | return "" | endif
  else
    let choice = 2
  endif

  " File <- n^th choice
  let file = files[choice - 2]
  call s:Verbose("choice=%1\nfile=%2", choice, file)

  " 3- Template-file to insert ? {{{3
  return s:InsertTemplateFile(a:word,file)
endfunction
"------------------------------------------------------------------------
" ## Internal functions {{{1
" Tools functions                                          {{{2
function! s:Option(name, default)  " {{{3
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

function! s:ValueV(text)           " {{{3
  return '%('.s:NoRegexV(s:value_start) . a:text . s:NoRegexV(s:value_end).')'
endfunction

function! s:Command(text)          " {{{3
  return 'VimL:' . a:text
endfunction

function! s:Special(text)          " {{{3
  return 'MuT:' . a:text
endfunction

function! s:Comment(text)          " {{{3
  return s:Command('" '.a:text)
endfunction

" Function: s:PushArgs()             {{{3
function! s:PushArgs(args) abort
  call add(s:args, a:args)
endfunction

" Function: s:PopArgs()              {{{3
function! s:PopArgs() abort
  if !empty(s:args)
    call remove(s:args, -1)
  endif
endfunction

" Function: s:InjectInParentArgs()   {{{3
function! s:InjectInParentArgs(args) abort
  call lh#assert#value(len(s:args)).is_gt(1)
  let parent_args = s:args[-2]
  while !empty(parent_args) && type(parent_args) != type({})
    call lh#assert#type(parent_args).is([])
    let parent_args2 = parent_args[-1]
    unlet parent_args
    let parent_args = parent_args2
    unlet parent_args2
  endwhile
  if type(parent_args)==type([]) && empty(parent_args)
    call add(parent_args, a:args)
  else
    call lh#assert#type(parent_args).is({})
    call extend(parent_args, a:args)
  endif
endfunction

" Function: s:Args()                 {{{3
" @returns a list. If the list is empty, this means no parameter was given.
let s:args = []
function! s:Args() abort
  " echomsg string(s:args)
  return empty(s:args) ? [] : s:args[-1]
endfunction

" Function: s:Param(name,default)    {{{3
" @returns a list. If the list is empty, this mean no parameter was given.
function! s:Param(name, default) abort
  if empty(a:name)
    return s:args[-1]
  else
    let i = len(s:args) - 1
    while i > -1
      silent! unlet arg
      let arg = s:args[i]

      if type(arg)==type([])
        let j = len(arg) - 1
        while j > -1
          if type(arg[j])==type({}) && has_key(arg[j], a:name)
            return arg[j][a:name]
          endif
          let j -= 1
        endwhile

      elseif type(arg)==type({}) && has_key(arg, a:name)
        return arg[a:name]
      endif
      let i -= 1
    endwhile
    " Force to return a modifiable reference
    let res = {(a:name) : a:default }
    " Try to use last param
    " TODO: refactor s:PushArgs & co:
    " -> arguments shall only be pushed on call to include and popped on the
    "  way back
    " -> Otherwise, there should be a current stack for local-template and sub-templates
    " -> This means that if we try to change a s:Param(), we should be able to
    "  revert modifications on pop.
    if !empty(s:args) && type(s:args[-1]) == type([])
      call add(s:args[-1], res)
    else " push, which should be avoided
      call s:PushArgs(res)
    endif
    return res[a:name]
  endif
  " echomsg string(s:args)
endfunction

" Function: s:ParamOrAsk(name, ...)  {{{3
function! s:ParamOrAsk(name, ...) abort
  let res = s:Param(a:name, lh#option#unset())
  if lh#option#is_set(res) | return res | endif
  return call('lh#ui#input',a:000)
endfunction

" Function: s:CmdLineParams(...)     {{{3
function! s:CmdLineParams(...) abort
  let args = lh#list#flatten(copy(s:args))
  " call filter(args, 'has_key(v:val, "cmdline")')
  let cmdline = lh#list#transform_if(args, [], 'v:val.cmdline', 'type(v:val) == type({}) && has_key(v:val, "cmdline")')
  return !empty(cmdline) ? cmdline[-1] : a:000
endfunction

" Function: s:Include()              {{{3
function! s:Include(template, ...) abort
  call s:Verbose('s:Include(%1)', [a:template] + a:000)
  let pos = s:content.crt
  " let correction = s:NeedToJoin > 0
  " if include is called from an expression, clean and prepare for line merging
  if s:content.lines[pos] =~ '\v'.s:ValueV('s:Include\(.*\)').'|'.s:MarkerV('s:Include\(.*\)')
    let correction = 1
    call s:AddPostExpandCallback({'join': pos+2})
    call s:AddPostExpandCallback({'join': pos+1})
  else
    let correction = 0
  endif
  let dir = fnamemodify(a:template, ':h')
  if dir != "" | let dir .= '/' | endif
  if a:0>0 && !empty(a:1)
    let dir .= a:1 . '/'
  endif
  " pushing a list permit to test the void args case
  " todo: mark the line where s:Pop should be applied
  " todo: check if pushing while no file found as no pop will get executed
  call s:PushArgs(a:0>1 ? a:000[1:] : [])
  " There is at least always one line: the PopArgs()
  if 1 == s:LoadTemplate(pos+correction, dir.a:template.'.template')
    if correction == 1
      " only set when called from an expression
      return a:template
    else
      call lh#common#warning_msg("muTemplate: No template file matching <".dir.a:template.'.template'.">\r".'dir='.dir.'|'.a:template.'|'.string(a:000))
    endif
  endif
  return ""
endfunction

function! s:IncludeSeveralSnippets(snippet_list, scope, common_arg, specific_args)
  " As we cannot hope to see the contexts correctly stacked when executing `for
  " xxx in yyy | call s:Include(...)`, here is this helper function that
  " injects as many `s:Include()` calls as necessary
  call s:Verbose('s:IncludeSeveralSnippets(%{1.snippet_list}, %{1.scope}, %{1.common_arg}, %{1.specific_args}', a:)
  if type(a:snippet_list) == type('')
    " Only one snippet => only one list to iterate
    let lines = map(a:specific_args, '"VimL: call s:Include(".string(a:snippet_list).", ".string(a:scope).", ".string(extend(copy(a:common_arg), v:val)).")"')

    call s:Verbose('s:IncludeSeveralSnippets -> %1', lines)
  else
    " Several snippets => twos lists to iterate
    call lh#assert#equal(type(a:snippet_list), type([]))
    call lh#assert#equal(len(a:snippet_list), len(a:specific_args))
  endif

  call s:Inject(lines)

endfunction

" Function: lh#mut#_include(template, ...) {{{3
function! lh#mut#_include(template, ...) abort
  return call('s:Include', [a:template]+a:000)
endfunction

" Function: s:Include_and_map()      {{{3
function! s:Include_and_map(template, map_action, ...) abort
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
  " todo: check if pushing while no file found as no pop will get executed
  call s:PushArgs(a:0>1 ? a:000[1:] : [])
  if 0 == s:LoadTemplate(pos-correction, dir.a:template.'.template', a:map_action)
    call lh#common#warning_msg("muTemplate: No template file matching <".dir.a:template.'.template'.">\r".'dir='.dir.'|'.a:template.'|'.string(a:000))
  endif
endfunction

" Function: s:GetTemplateLines()     {{{3
function! s:GetTemplateLines(template, ...) abort
  call s:Verbose('s:GetTemplateLines(%1)', [a:template] + a:000)
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
  " todo: check if pushing while no file found as no pop will get executed
  " call s:PushArgs(a:0>1 ? a:000[1:] : [])
  let lines = s:LoadTemplateLines(pos-correction, dir.a:template.'.template')
  if 0 == len(lines)
    call lh#common#warning_msg("muTemplate: No template file matching <".dir.a:template.'.template'.">\r".'dir='.dir.'|'.a:template.'|'.string(a:000))
  endif
  return lines
endfunction

" Function: s:AddPostExpandCallback(callback) {{{3
function! s:AddPostExpandCallback(callback) abort
  let s:content.callbacks += [a:callback]
endfunction

" Function: lh#mut#_add_post_expand_callback(callback) {{{3
function! lh#mut#_add_post_expand_callback(callback) abort
  call s:AddPostExpandCallback(a:callback)
endfunction

" Function: s:Inject(lines)          {{{3
function! s:Inject(lines) abort
  let pos = s:content.crt
  call extend(s:content.lines, a:lines, s:content.crt+0)
endfunction

" Function: s:InjectAndTransform(templatename) {{{3
function! s:InjectAndTransform(templatename, Transformation, ...) abort
  let dir = fnamemodify(a:templatename, ':h')
  if dir != "" | let dir .= '/' | endif
  if a:0>0 && !empty(a:1)
    let dir .= a:1 . '/'
  endif
  let templatepath = dir.a:templatename.'.template'
  try
    let wildignore_save = &wildignore
    let &wildignore = ""
    let matching_filenames = lh#path#glob_as_list(g:lh#mut#dirs#cache, templatepath)
    if len(matching_filenames) == 0
      return 0 " NB: the finally block is still executed
      " call lh#common#warning_msg("muTemplate: No template file matching <".a:templatepath.">")
    else
      if &verbose >= 1
        echo "Loading <".matching_filenames[0].">"
      endif
      call s:PushArgs(a:0>1 ? [a:2] : [])
      let lines = readfile(matching_filenames[0])
      let lines = a:Transformation(lines)
      let lines += [s:Command( 'call s:PopArgs()')]
      call extend(s:content.lines, lines, a:pos)
  finally
    let &wildignore = wildignore_save
  endtry
endfunction

function! s:path_from_root(path) abort " {{{3
  let path = a:path
  let sources_root = lh#option#get('sources_root')
  if lh#option#is_unset(sources_root)
    unlet sources_root
    let sources_root = lh#option#get('paths.sources')
  endif
  if lh#option#is_set(sources_root)
    let sources_root = lh#path#to_dirname(sources_root)
    let s = strlen(sources_root)
    let p = stridx(path, sources_root)
    if 0 == p
      let path = strpart(path, s)
    endif
  endif
  return path
endfunction

" Function: s:SurroundRaw(id, default)  {{{3
" Return the visual selection, without trying to prevent style
" application on it
function! s:SurroundRaw(id, default) abort
  let key = 'surround'.a:id
  if has_key(s:content, key)
    return s:content[key]
  else
    return a:default
  endif
endfunction

" Function: s:Surround(id, default)  {{{3
function! s:Surround(id, default) abort
  let key = 'surround'.a:id
  if has_key(s:content, key)
    let content = s:content[key]

    " In the case of surrounding multiple lines with python, we need to fix the
    " indentation here
    if get(s:content, 'reindent') == 'python' && stridx(content, "\n") >= 0
      let ref_line = s:content.lines[s:content.crt]
      let ref_indent = matchstr(ref_line, '^\s*')
      let lRes = split(content, "\n")
      let min_res_indent = min(map(copy(lRes), "matchend(v:val, '^\\s*')"))
      " The calling engine will already restore the expected indent through
      " leading spaces on the first line.
      " What we need: make sure subsequent lines are correctly indented
      " TODO: simplify

      call map(lRes, 'v:val[min_res_indent:]')
      let lRes1 = map(lRes[1:], 'ref_indent . v:val')
      let content = join([lRes[0]]+lRes1, "\n")
      call s:Verbose('Content for s:Surround(%1): %2', a:id, "\n"+content)
    endif

    let s:content.need_to_reinject_ignored = 1
    return lh#style#just_ignore_this(content, s:content.cache_of_ignored_matches)
  else
    return a:default
  endif
endfunction

" Function: s:SurroundableParam(name, surround_id, [default=«name»]) {{{3
function! s:SurroundableParam(name, surround_id, ...) abort
  let default = a:0 > 0 ? a:1 : lh#marker#txt(a:name)
  return s:Param(a:name, s:Surround(a:surround_id, default))
endfunction

" Function: s:IsSurrounding()        {{{3
function! s:IsSurrounding() abort
  return has_key(s:content,"is_surrounding")
        \ && (s:content.is_surrounding)
endfunction

" Function: s:TerminalPlaceHolder()  {{{3
function! s:TerminalPlaceHolder() abort
  return !s:IsSurrounding() ? lh#marker#txt() : ''
endfunction

" Function: s:Line()                 {{{3
" Returns current line
function! s:Line() abort
  return s:content.crt + s:content.start
endfunction

" Function: s:StartIndentingHere()   {{{3
function! s:StartIndentingHere() abort
  let s:content.first_line_indented = s:Line()
  let s:reindent = 1
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
let s:content = { 'lines' : [], 'crt' : 0, 'start' : 0, 'scope': [1], 'callbacks': [], 'variables': []}

" s:PushNewContext(ctx)                                        {{{3
function! s:PushNewContext(ctx)
  call s:Verbose("s:PushNewContext(%1)", a:ctx)
  let context = lh#on#exit()
        \.register('call '.s:getSNR('PopArgs()'))
  let context.__name__ = a:ctx
  call s:content.contexts.push(context)
  return context
endfunction

" s:PopContext()                                               {{{3
function! s:PopContext()
  let context = s:content.contexts.pop()
  call s:Verbose("s:PopContext(%2, %1)", context, context.__name__)
  call context.finalize()
endfunction

" s:LoadTemplateLines(pos, templatepath)                       {{{3
function! s:LoadTemplateLines(pos, templatepath) abort
  call s:Verbose("s:LoadTemplateLines(".a:pos.", '".a:templatepath."')")
  try
    let wildignore = &wildignore
    let &wildignore  = ""

    let matching_filenames = lh#path#glob_as_list(g:lh#mut#dirs#cache, a:templatepath)
    if len(matching_filenames) == 0
      return [] " NB: the finally block is still executed
      " call lh#common#warning_msg("muTemplate: No template file matching <".a:templatepath.">")
    else
      if &verbose >= 1
        echo "Loading <".matching_filenames[0].">"
      endif
      let lines = readfile(matching_filenames[0])
      return lines
    endif
  finally
    let &wildignore = wildignore
  endtry
endfunction

" s:NonNullIndent(line) abort                                  {{{3
function! s:NonNullIndent(line) abort
  let id = indent(a:line)
  if id == 0 && has_key(s:content, 'indentexpr')

    let cleanup = lh#on#exit()
          \.restore_cursor()
    try
      let v:lnum = a:line " There is a bug in standard indent/python.vim
      " It explictly uses v:lnum instead of its parameter, and it moves the
      " cursor...
      silent! let id = call(s:content.indentexpr, [a:line])
    finally
      call cleanup.finalize()
    endtry

  endif
  return id
endfunction

" s:LoadTemplate(pos, templatepath [, map_action])             {{{3
function! s:LoadTemplate(pos, templatepath, ...) abort
  call s:Verbose('s:LoadTemplate(%1)', [a:pos, a:templatepath]+a:000)
  let lines = s:LoadTemplateLines(a:pos, a:templatepath)
  let context = s:PushNewContext(a:templatepath)
  " Context is restored after lines have been processed. It shall not be
  " restored before that. But then, we cannot have a "VimL:" line that calls
  " `s:Include()`  in a `:for` loop. Hence: `s:IncludeSeveralSnippets()`
  let lines += [s:Command( 'call s:PopContext()')]
  if a:0 > 0
    let map_action = a:1
    let pat_not_text = '\v\c(^'.s:Command('').'|'.s:Special('').')'
    call map(lines, "v:val =~ pat_not_text ? (v:val) : ".map_action)
  endif
  if get(s:, 'reindent') == 'python'
    call context.restore(s:content, 'crt_indent')
    if !has_key(s:content, 'crt_indent')
      let s:content.crt_indent = a:pos > 0
            \ ? len(matchstr(s:content.lines[a:pos - 1], '\v^\s*'))
            \ : s:NonNullIndent(line('.'))
      call s:Verbose("Loading(%1 at %2) no previous indent - using %3 <- %4", a:templatepath, a:pos, s:content.crt_indent, a:pos > 0 ? 'nb heading spaces of(previous line)' : 'indent(".")')
    else
      call s:Verbose("Loading(%1 at %2) from previous indent %3", a:templatepath, a:pos, s:content.crt_indent)
    endif
    let s:content.crt_indent += &sw * s:Param('indented', 0)
    let indent = repeat(' ', s:content.crt_indent)
    call map(lines, 'v:val !~? "\\v^VimL:|^MuT:|^\\s*$" ? indent . v:val : v:val')
  endif
  call extend(s:content.lines, lines, a:pos)
  return len(lines)
endfunction

" s:ResetContext()                                             {{{3
" @post s:content.start = line('.')
" @post s:content.scope = [1]
" @post s:content.callbacks = []
" @post s:content.crt_indent doesn't exists
" @post s:content.styles = lh#style#get(&ft)
" @post no variables
function! s:ResetContext() abort
  call s:Verbose('s:ResetContext()')
  let pos                                = line('.')
  let s:content.start                    = pos
  let s:content.scope                    = [1]
  let s:content.callbacks                = []
  let s:content.contexts                 = lh#stack#new()
  let s:content.styles                   = lh#style#get(&ft)
  let s:content.cache_of_ignored_matches = []
  let s:content.need_to_reinject_ignored = 0
  if has_key(s:content, 'crt_indent')
    unlet s:content.crt_indent
  endif
  if has_key(s:content, 'can_apply_style')
    unlet s:content.can_apply_style
  endif
  if !empty(&indentexpr)
    let s:content.indentexpr             = substitute(&indentexpr, '(.*)', '', '')
  endif
  call s:ClearVariables()
endfunction

" s:DoExpand(NeedToJoin)                                       {{{3
" @pre s:content.lines array is filled with the lines to expand
function! s:DoExpand(NeedToJoin) abort
  call s:Verbose('s:DoExpand(%1)', a:NeedToJoin)
  if empty(s:content.lines)
    return 0
  endif

  let pos = line('.')
  let s:NeedToJoin = a:NeedToJoin
  let foldenable=&foldenable
  silent! set nofoldenable
  try
    " 1- Reset default settings {{{4
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
    " 2- Interpret {{{4
    call s:InterpretLines(pos)
    " let [dummy, dur] = lh#time#bench(s:function('InterpretLines'), pos)
    " echo printf("Expansion in %fs",dur)
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

    " 3- Insert {{{4
    call append(pos, s:content.lines)
    let last=pos + len(s:content.lines)
    " echomsg 'last='.last

    " Goto the first line and delete it or join it (unless in visual surround mode) {{{4
    if empty(getline(pos))
      " TODO: as I no longer use :read, get rid of this forced empty-line stuff...
      silent exe pos."normal! dd0"
    elseif get(s:content, 'surrounding_with', '') != 'V'
      silent exe pos."normal! J!0"
    endif
    let last -= 1
    " Activate Tom Link's Stakeholders in case it is installed {{{4
    call s:TryActivateStakeholders(pos, last)

    " Reindent {{{4
    " Other indenting scheme: "python", managed elsewhere
    if get(s:, 'reindent', 0) == 1
      silent exe get(s:content, 'first_line_indented', pos).','.(last).'normal! =='
      unlet s:reindent
    endif
    silent! unlet s:content.first_line_indented

    " Join with the line after the template that have been inserted {{{4
    call s:JoinWithNext(s:NeedToJoin,pos,last)

    " Execute the post-expand callbacks (like add_include_dirs)
    let nb_lines_added =  s:ExecutePostExpandCallbacks()
    let pos             += nb_lines_added
    let last            += nb_lines_added
    let s:content.start += nb_lines_added
    return last
  finally " Reset settings {{{4
    let &foldenable=foldenable
    let s:args=[]
    " and unfold the lines inserted
    if &foldenable
      silent! exe (pos).','.(last).'foldopen!'
    endif
  endtry
endfunction "}}}4

" s:InterpretValue() will interpret a sequence between ¡.\{-}¡ {{{3
" ... and return the computed value.
" To possibly expand a sequence into an empty string, use the
" 'bool_expr ?  act1 : act2' VimL operator ; cf vim.template for examples of
" use.
function! s:InterpretValue(what) abort
  let what = substitute(a:what, '\v'.s:content.__re_marker, s:content.__placeholder_submatch_1, 'g')
  " Special case: s:Include => need to split the line before and after
  let nl = what =~ 's:Include' ? '\r' : ''
  " echo "interpret value: " . what
  try
    " todo: can we use eval() now?
    exe 'let s:__r = ' . what
    " NB: cannot use a local variable, hence the "s:xxxx"
    return nl . s:__r . nl
  catch /.*/
    call lh#common#warning_msg("muTemplate: Cannot interpret `".a:what."': ".v:exception)
    return a:what
  endtry
endfunction

" s:InterpretCommand() will interpret a sequence 'VimL:.*'     {{{3
" ... and return nothing
" Back-Door to trojans !!!
function! s:InterpretCommand(what) abort
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
    call lh#common#warning_msg("muTemplate: Cannot execute `".a:what."': ".v:exception.'  ('.v:throwpoint.')')
    throw "muTemplate: Cannot execute `".a:what."': ".v:exception.'  ('.v:throwpoint.')'
  endtry
endfunction

" s:InterpretValues(line) ~ eval expressions in {line} (deprecated) {{{3
" @deprecated
function! s:InterpretValues(line) abort
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
      " Style should be applied everywhere but on surrounded things
      let value = s:InterpretValue(split[2])
      let res .= split[1] . value
      let tail = split[3]
      let may_merge = 1
    endif
  endwhile
  " echomsg "may_merge=".may_merge."  ---  ".res
  return { 'line' : res, 'may_merge' : may_merge }
endfunction

" s:InterpretValuesAndMarkersV2(line) ~ eval markers as expr in {line} {{{3
function! s:InterpretValuesAndMarkers2(line) abort
  " @pre must not be defining VimL functions
  if !empty(s:__function)
    throw 'already within the definition of a function (no non-VimL code authorized)'
  endif

  " NB: Styling is applyied on-the-fly, except on surrounded text, i.e.
  " replaces characters from a list (-> style policies for {, ( regarding
  " spaces, newlines, etc.

  let s:content.__re_marker = s:MarkerV('(.{-})')
  let s:content.__re_value  = s:ValueV('(.{-})')
  let re =  '\v%('.s:content.__re_value.'|'.s:content.__re_marker.')'
  let s:content.__empty_placeholder = lh#marker#txt()
  let s:content.__placeholder_submatch_1 = lh#marker#txt('\1')
  " Problems
  " -> we need to apply the style on things generated
  " -> as long as they aren't surrounded code.
  " => surrounded stuff are memorized, the style is applied at the end.

  let res = substitute(a:line, re, '\=s:InterpretAValueOrAMarker(submatch(1), submatch(2))', 'g')
  let may_merge = res != a:line
  if get(s:content, 'can_apply_style', 1)
    " s:content.can_apply_style can change on MuT commands. It's not
    " expected to change in MuT expression => we test it once and
    " whenever we like in s:InterpretValuesAndMarkers2()
    let res = s:ApplyStyling(res)
  elseif s:content.need_to_reinject_ignored
    " Typical scenario: surrounded text shall not be restyled.
    " => s:Surround() memorizes text to ignore. But in that case the
    " test shall be reinjected.
    " Note that s:ApplyStyling() already reinjects text automatically,
    " but it doesn't handle the case of
    " "MuT: let s:foo = s:Surround(1, 'default')"
    let res = s:ReinjectUnstyledText(res)
  endif
  call s:Verbose("may_merge=%1; %2 --> %3", may_merge, a:line, res)
  return { 'line' : res, 'may_merge' : may_merge }
endfunction

" Function: s:InterpretAValueOrAMarker(value, marker) {{{3
function! s:InterpretAValueOrAMarker(value, marker) abort
  call s:Verbose('s:InterpretAValueOrAMarker(value=%1, marker=%2)', a:value, a:marker)
  " Style should be applied everywhere but on surrounded things
  if !empty(a:value)
    call lh#assert#value(a:marker).empty()
    let value = s:InterpretValue(a:value)
  elseif empty(a:marker)
    let value = s:content.__empty_placeholder
  elseif ! get(s:, 'dont_eval_markers', 0)
    " There may be an expression within the marker
    let marker = substitute(a:marker, '\v'.s:content.__re_value, '\=s:InterpretValue(submatch(1))', 'g')
    try
      let nl = marker =~ 's:Include' ? "\n" : ''
      "BUG in Vim7.3: eval() may not fail but return 0
      let value = nl. eval(marker) .nl
    catch /.*/
      let value = lh#marker#txt(marker)
    endtry
  else
    let value = lh#marker#txt(a:marker)
  endif
  let res = type(value)!=type("") ? string(value) : value
  return res
endfunction

" s:InterpretValuesAndMarkers(line) ~ eval markers as expr in {line} (deprecated){{{3
" todo merge with s:InterpretValues
" @deprecated
let s:k_first = '\v(.{-})'
let s:k_last  = '(.*)'

function! s:InterpretValuesAndMarkers(line) abort
  call lh#assert#unexpected('This function has been deprecated!')
  " @pre must not be defining VimL functions
  if !empty(s:__function)
    throw 'already within the definition of a function (no non-VimL code authorized)'
  endif

  " NB: Styling is applyied on-the-fly, except on surrounded text, i.e.
  " replaces characters from a list (-> style policies for {, ( regarding
  " spaces, newlines, etc.

  " echo "line:" . a:line
  let res = ''
  let value = '' " so it can be unlet without error
  let tail = a:line
  " let re_marker = s:MarkerV('(.{-})')
  " let re_value  = s:ValueV('(.{-})')
  " let re =  s:k_first.'%('.re_value.'|'.re_marker.')'.s:k_last
  " let k_empty_placeholder = lh#marker#txt()
  " let k_placeholder_submatch_1 = lh#marker#txt('\1')
  let s:content.__re_marker = s:MarkerV('(.{-})')
  let s:content.__re_value  = s:ValueV('(.{-})')
  let re =  s:k_first.'\v%('.s:content.__re_value.'|'.s:content.__re_marker.')'.s:k_last
  let s:content.__empty_placeholder = lh#marker#txt()
  let s:content.__placeholder_submatch_1 = lh#marker#txt('\1')
  " let g:re = re
  let may_merge = 0
  " Because of the splitting, context is lost.
  " -> we need to apply the setting on things generated
  " -> as long as they aren't surrounded code.
  " => surrounded stuff are memorized, the style is applied at the end.
  let can_apply_style = get(s:content, 'can_apply_style', 1)
  let s:content.cache_of_ignored_matches = []
  while strlen(tail)!=0
    let split = matchlist(tail, re)
    if len(split) <2 || strlen(split[0]) == 0
      " nothing found
      let res .= tail
      let tail = ''
      " let may_merge = 0
    else
      " Style should be applied everywhere but on surrounded things
      let s:content.can_apply_style = 1 " s:Surround will reset it to 0
      unlet value
      if !empty(split[2])     " Value to interpret
        let value = s:InterpretValue(split[2])
        if  can_apply_style && ! get(s:content, 'can_apply_style', 1)
          " can_apply_style remembers the global setting while
          " s:content.can_apply_style returns whether s:Surround() has
          " been called.
          let value = lh#style#just_ignore_this(value, s:content.cache_of_ignored_matches)
        endif
      elseif get(s:, 'dont_eval_markers', 0)
        let value = substitute(value, s:Marker('\(.\{-}\)'), s:content.__placeholder_submatch_1, 'g')
      else
        if !empty(split[3]) " Marker to interpret
          let part = split[3]
          " There may be an expression within the marker
          let part = s:InterpretValues(part).line
          try
            let nl = part =~ 's:Include' ? "\n" : ''
            "BUG in Vim7.3: eval() may not fail but return 0
            let value = nl. eval(part) .nl
          catch /.*/
            let value = lh#marker#txt(part)
          endtry
        else
          let value = s:content.__empty_placeholder
        endif
      endif
      let sValue = (type(value)!=type("") ? string(value) : value)
      " call s:Verbose("sValue: `%1`", sValue)
      let res .= split[1] . sValue
      let tail = split[4]
      let may_merge = 1
    endif
  endwhile
  if can_apply_style
    let res = s:ApplyStyling(res)
  endif
  call s:Verbose("may_merge=%1; %2 --> %3", may_merge, a:line, res)
  return { 'line' : res, 'may_merge' : may_merge }
endfunction

" s:ApplyStyling(line) ~ add spaces or NL before/after brackets{{{3
function! s:ApplyStyling(line) abort
  " @pre must not be defining VimL functions
  if !empty(s:__function)
    throw 'already within the definition of a function (no non-VimL code authorized)'
  endif

  if empty(s:content.styles) && ! s:content.need_to_reinject_ignored
    return a:line
  endif
  return lh#style#apply_these(s:content.styles, a:line, get(s:content, 'cache_of_ignored_matches', []))
endfunction

" s:ReinjectUnstyledText(line) -- reinject unstyled surrounded {{{3
function! s:ReinjectUnstyledText(line) abort
  " @pre must not be defining VimL functions
  call lh#assert#value(s:__function).empty('already within the definition of a function (no non-VimL code authorized)')
  call lh#assert#value(s:content).has_key('cache_of_ignored_matches')

  return lh#style#reinject_cached_ignored_matches(a:line, s:content.cache_of_ignored_matches)
endfunction

" s:NoRegex(text)                                              {{{3
function! s:NoRegex(text) abort
  return escape(a:text, '\.*/')
endfunction

" s:NoRegexV(text)                                             {{{3
function! s:NoRegexV(text) abort
  return escape(a:text, '\.*/<+>[](){}')
endfunction

" s:Marker(text)                                               {{{3
function! s:Marker(regex) abort
  return s:NoRegex(s:marker_open) . a:regex . s:NoRegex(s:marker_close)
endfunction

" s:MarkerV(text)                                              {{{3
" \vRegex
function! s:MarkerV(regex) abort
  return s:NoRegexV(s:marker_open) . a:regex . s:NoRegexV(s:marker_close)
endfunction

" s:isBranchActive()                                           {{{3
function! s:isBranchActive() abort
  " If there is a 0 in the scope, it means we are with an inactive branch
  " (if/else)
  return min(s:content.scope) == 1
endfunction

" s:InterpretMuTCommand(the_line)                              {{{3
function! s:InterpretMuTCommand(the_line) abort
  try
    let [dummy, special_cmd, cond; tail] = matchlist(a:the_line, s:Special('\v\s*(\S+)(\s+.*)='))
    if     special_cmd == 'if' " {{{4
      if s:isBranchActive()
        let is_true = eval(cond)
        call insert(s:content.scope, is_true)
      else " Don't bother to evaluate anything, but push a new "if/else/endif"
        call insert(s:content.scope, -2)
      endif
    elseif special_cmd == 'elseif' " {{{4
      if len(s:content.scope) <= 1
        throw "'MuT: elseif' used, but there was no if"
      endif
      if min(s:content.scope[1:]) == 1 " Within an active branch => check the current if
        if s:content.scope[0] != 0 " something has been true in the past
          let s:content.scope[0] = -1 " => ignoring this case
        else
          let is_true = eval(cond) " can be evaluated as we're within an active branch
          let s:content.scope[0] = is_true
        endif
      endif
    elseif special_cmd == 'else' " {{{4
      if len(s:content.scope) <= 1
        throw "'MuT: else' used, but there was no if"
      endif
      let s:content.scope[0] = s:content.scope[0] == 0 " only of nothing has ever been true
    elseif special_cmd == 'endif' " {{{4
      if len(s:content.scope) <= 1
        throw "'MuT: else' used, but there was no if"
      endif
      call remove(s:content.scope, 0)
    elseif special_cmd == 'let' || (special_cmd == 'debug' && cond =~ '\v^\s*let>') " {{{4
      if ! s:isBranchActive()
        return
      endif
      " same as VimL :let, but also does an unlet and register the variable for
      " later unlet
      " Moreover, "s:" is automatically added
      " Note: doesn't support dict, nor lists
      let [all, debug, script, varname, op, expr; tail] = matchlist(a:the_line, '\v'.s:Special('\s*(debug\s+)=\zslet\s*(s:)=(\w+)\s*([.+*/-]=\=)\s*(.*)'))
      let s:content.variables += [varname]
      if stridx(expr, script.varname) == -1 && op == '=' && exists('s:'.varname)
        silent! unlet s:{varname}
      endif
      if empty(script)
        let all = substitute(all, '\v(s:)@<!<'.varname.'>', 's:&', 'g')
      endif
      exe all
    elseif special_cmd =~ '^.*"' " comment {{{4
      " Ignore!
    else " {{{4
      throw "Unsupported 'Mut: ".special_cmd."' MuT-command"
    endif " }}}4"
  catch /.*/
    throw substitute(v:exception, '^Vim\((.\{-})\)\=:', '', '')." when parsing ".a:the_line." --  (".v:throwpoint.')'
  endtry
endfunction

" s:InterpretLines(first_line)                                 {{{3
function! s:InterpretLines(first_line) abort
  call s:Verbose('s:InterpretLines(firstline: %1)', a:first_line)
  " Constants
  let markerCharacters = lh#marker#txt('')

  let s:content.crt = 0
  let pat_command = '\c^\s*'.s:Command('')
  let pat_special = '\c^\s*'.s:Special('')
  let command_extract_re = '\c^\s*'.s:Command('\s*').'\zs.*'
  while s:content.crt < len(s:content.lines)
    " echomsg s:content.crt . ' < ' . len(s:content.lines) . ' ----> ' . s:content.lines[s:content.crt]
    let the_line = s:content.lines[s:content.crt]
    call s:Verbose('  Interpreting %1', the_line)

    " MuT: lines
    if the_line =~ pat_special
      call s:InterpretMuTCommand(the_line)
      call remove(s:content.lines, s:content.crt) " implicit next, must be done before any s:Include
      continue
    elseif ! s:isBranchActive()
      call remove(s:content.lines, s:content.crt) " implicit next, must be done before any s:Include
      continue
    endif

    " In all cases
    if the_line =~ pat_command
      call remove(s:content.lines, s:content.crt) " implicit next, must be done before any s:Include
      call s:InterpretCommand( matchstr(the_line, command_extract_re))
    elseif the_line !~ '^\s*$'
      " NB 1- We must know the expression characters before any interpretation.
      "    2- :r inserts an empty line before the template loaded
      "    => We do not interpret empty lines
      "    => s:value_start and s:value_end must always be specified!

      " let line = s:InterpretValuesAndMarkers(the_line)
      let line = s:InterpretValuesAndMarkers2(the_line)
      " call lh#assert#value(line).eq(linev2)
      let the_line = line.line

      if the_line =~ '^\s*$' && line.may_merge
        " The line becomes empty after the evaluation of the expression => strip it
        call remove(s:content.lines, s:content.crt) " implicit next
      else
        " Put back the interpreted lines in the content buffer
        if match(the_line, "[\n\r]") >= 0
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

" s:Reencode()                                                 {{{3
function! s:Reencode() abort
  call map(s:content.lines, 'lh#encoding#iconv(v:val, '.string(s:fileencoding).', &enc)')
endfunction

" s:IsKindOfEmptyLine(lineNo)                                  {{{3
" @return true on empty lines or on lines containing an empty comment
function! s:IsKindOfEmptyLine(lineNo) abort
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
function! s:ChooseByComplete() abort
  let entries = []
  let i = 0
  for file in s:__complete.files
    call add(entries, {"word": file, "menu": (lh#mut#dirs#hint(file)) })
  endfor
  let c = col('.')
  let l = c - strlen(s:__complete.word)
  let s:__complete.c = l
  " let g:entries = {"c":c, "l":l, "entries": entries}
  let FinishCompletion = function(s:getSNR("FinishCompletion"))
  call lh#icomplete#new(l-1, entries, FinishCompletion).start_completion()
  return ""
endfunction

" s:FinishCompletion()                                         {{{3
function! s:FinishCompletion(choice) abort
  let l =getline('.')
  let choice = a:choice
  " let choice = l[(s:__complete.c-1) : (col('.')-1)]
  " echomsg "finishing! ->" . choice
  let post_action = s:InsertTemplateFile(choice, choice)
  if !empty(post_action)
    exe "normal ".post_action
  else
    call lh#common#error_msg("No template associated to ".choice)
  endif
endfunction

" s:getSNR([func_name])                                        {{{3
function! s:getSNR(...) abort
  if !exists("s:SNR")
    let s:SNR=matchstr(expand('<sfile>'), '<SNR>\d\+_\zegetSNR$')
  endif
  return s:SNR . (a:0>0 ? (a:1) : '')
endfunction

" s:function([func_name])                                      {{{3
function! s:function(...) abort
  return function(call('s:getSNR', a:000))
endfunction

" s:ChooseTemplateFile(files)                                  {{{3
function! s:ChooseTemplateFile(files, word) abort
  let mt_chooseWith = s:Option('chooseWith', 'complete')
  if mt_chooseWith == 'confirm' && len(a:files) >= (10+26+25)
    call lh#common#error_msg("Too many choices ".len(a:files).
          \" for the `confirm' mode, the snippet selection-mode is forced to `complete'")
    try
      let g:mt_chooseWith = 'complete'
      let res = s:ChooseTemplateFile(a:files, a:word)
    finally
      let g:mt_chooseWith = 'confirm'
    endtry
    return res
  elseif mt_chooseWith == 'confirm'
    if has('gui_running')
      let strings = join(a:files, "\n")
    else
      let choices = []
      let key = '0'
      for file in a:files
        let choices += ['&'. key . ' ' .file]
        let key
              \ = key == '9' ? 'a'
              \ : key == 'z' ? 'B'
              \ : nr2char(char2nr(key)+1)
        " after "Z" is not handled...
      endfor
      let strings = join(choices, "\n")
    endif
    try
      " Always display the choices vertically
      let guioptions_save = &guioptions
      set guioptions+=v
      let choice = confirm("Which template do you wish to use ?",
            \ "&Abort\n".strings, 1)
    finally
      let &guioptions = guioptions_save
    endtry
  elseif mt_chooseWith == 'complete'
    try
      let s:__complete = {}
      let s:__complete.files = a:files
      let s:__complete.word  = a:word
      call s:ChooseByComplete()
      let choice = 0
    finally
    endtry
  else
    throw "muTemplate: Invalid value for g:mt_chooseWith option"
  endif
  return choice
endfunction

" s:InsertTemplateFile(word,file)                              {{{3
function! s:InsertTemplateFile(word,file) abort
  if "" != a:file " 3.A- => YES there is one {{{4
    " 3.1- Remove the current word {{{5
    " Note: <esc> is needed to escape from "Visual insertion mode"
    " TODO: manage a blinking pb
    let l = strlen(a:word)      " No word to expand ; abort
    if     0 == l
      " elseif 1 == l           " Select a one-character length word
      " silent exe "normal! \<esc>vc\<c-g>u\<esc>"
    else                        " Select a 1_n-characters length word
      let ew = escape(a:word, '\.*[/')
      call search(ew, 'b')
      let pos = getpos('.')
      " silent exe "normal! \<esc>v/".ew."/e\<cr>c\<c-g>u\<esc>"
      " silent exe "normal! \<esc>c".l."\<Right>\<c-g>u\<esc>"
      let line = getline('.')
      " Clear the line from the word to expand
      if pos[2] > 1
        call setline('.', line[0:pos[2]-2])
      else
        call setline('.', '')
      endif
      " Insert a line break
      call append('.', line[(pos[2]-1+l):])
      call setpos('.', pos)
    endif
    " Insert a line break
    " silent exe "normal! i\<cr>\<esc>\<up>$"

    " 3.2- Insert the template {{{5
    call s:Verbose("Using the template file: <%1>", a:file)
    " Todo: check what happens with g:mt_jump_to_first_markers off
    " let [res, act] = lh#mut#expand_and_jump(s:Option('how_to_join',1),a:file)
    let res = lh#mut#expand_and_jump(s:Option('how_to_join',1),a:file)
    if ! res
      call lh#common#error_msg("Hum... problem to insert the template: <".a:file.'>')
      return ""
    endif
    " Note: <esc> is needed to escape from "Visual insertion mode"
    " Workaround a change in Vim 7.0 behaviour
    if s:therewasamarker
      " return act
      return "\<c-\>\<c-n>\<c-\>\<c-n>gv\<c-g>"
    else
      return "\<c-\>\<c-n>"
    endif
  else          " 3.B- No template file available for the current word {{{4
    return ""
  endif " }}}4
endfunction

" s:TryActivateStakeholders(pos, last)                         {{{3
function! s:TryActivateStakeholders(pos,last) abort
  if exists(':StakeholdersEnable') && s:Option('use_stakeholders', 1)
    if !exists('#stakeholders') " Stakeholder not enabled for all buffers
      if !exists('b:stakeholders') || exists('b:stakeholders_range')
        " previously activated on a range, or never activated
        " echomsg "try EnableInRange(".a:pos.','.a:last.')'
        " Reset previous range
        call stakeholders#DisableBuffer()
        " Set new range in case there is no global activation
        call stakeholders#EnableInRange(a:pos, a:last)
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
endfunction

" s:JoinWithNext(NeedToJoin,last,pos)                          {{{3
function! s:JoinWithNext(NeedToJoin,pos,last) abort
  if     a:NeedToJoin >= 2
    silent exe a:last."normal! A".lh#marker#txt('')."\<esc>J!"
    let s:moveto = 'call cursor('.a:last.','.virtcol('.').')'
  elseif a:NeedToJoin >= 1
    "Here: problem when merging empty &comments
    if s:IsKindOfEmptyLine(a:last+1)
      silent exe (a:last+1).'delete _'
      let s:moveto = a:last.'normal! $'
    else
      " exe a:last."normal! J!"
      exe a:last
      let s:moveto = 'call cursor('.a:last.','.virtcol('$').')'
      silent exe a:last."normal! gqj"
    endif
  else " NeedToJoin == 0
    let s:moveto = 'call cursor('.a:pos.',1)'
  endif
endfunction

" s:ExecutePostExpandCallbacks()                               {{{3
" Let's suppose lines added may be anywhere, and that they search where to be
" inserted
" => join lines before adding anything
function! s:ExecutePostExpandCallbacks() abort
  " 1- first: lines to join
  let lines_to_join = lh#list#possible_values(s:content.callbacks, 'join')
  call reverse(lines_to_join)
  for l in lines_to_join
    let lines = getline(l, l+1)
    let lines[0] .= lines[1]
    undojoin | silent call setline(l, lines[0])
    undojoin | silent exe (l+1).'delete _'
  endfor

  " 2- then line to add
  let nb_lines_added = 0
  for Callback in s:content.callbacks
    if type(Callback) == type(function('has'))
      let nb_lines_added += Callback()
    elseif type(Callback) == type({})
      if has_key(Callback, 'join')
        let lines_to_join += [Callback.join]
      else
        let nb_lines_added +=  lh#function#execute(Callback)
      endif
    else
      execute 'let nb_lines_added += '.Callback
    endif
    unlet Callback
  endfor
  return nb_lines_added - len(lines_to_join)
endfunction

function! s:ClearVariables()
  call lh#list#unique_sort(s:content.variables)
  for v in s:content.variables
    silent! unlet s:{v}
  endfor
  let s:content.variables = []
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
