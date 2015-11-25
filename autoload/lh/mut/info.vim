"=============================================================================
" File:         autoload/lh/mut/info.vim                          {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/mu-template>
" Version:      3.5.1.
let s:k_version = '351'
" Created:      24th Nov 2015
" Last Update:
"------------------------------------------------------------------------
" Description:
"       Extract template information
"
" nnoremap £ :put=lh#mut#info#as_markdown(expand('<cWORD>'))<CR><C-W>_zb
"
"------------------------------------------------------------------------
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#mut#info#version()
  return s:k_version
endfunction

" # Debug   {{{2
if !exists('s:verbose')
  let s:verbose = 0
endif
function! lh#mut#info#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#mut#info#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" # Main functions {{{2
" Function: lh#mut#info#get(path) {{{3
function! lh#mut#info#get(path) abort
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

    let res = lh#mut#info#_get(matching_filenames[choice])
    res.name = short_names[choice]
    return res
  finally
    let &wildignore = wildignore
  endtry
endfunction

" Function: lh#mut#info#as_markdown(path) {{{3
function! lh#mut#info#as_markdown(path) abort
  let info = lh#mut#info#get(a:path)

  let res = []
  let res += lh#mut#info#_field_to_md(info, 'hint')
  let res += lh#mut#info#_field_to_md(info, 'params')
  let res += lh#mut#info#_field_to_md(info, 'options')
  let res += lh#mut#info#_field_to_md(info, 'surround')
  let res += lh#mut#info#_field_to_md(info, 'hooks')
  let res += lh#mut#info#_field_to_md(info, 'variationpoints')
  return res
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

" # Entry point {{{2
" Function: lh#mut#info#_get(filename) {{{3
" Return:
" - variationpoints
" - name
" - parameters
" - hint
" - surround
" - import/hooks
function! lh#mut#info#_get(filename) abort
  let lines = readfile(a:filename)

  let res = { }

  " Variation points
  let vp = filter(copy(lines), 'v:val =~ "s:Include"')
  call filter(vp, 'v:val !~ "post-expand-callback\|post-include"')
  call map(vp, 'matchstr(v:val, "\\vs:Include\\k*\\(\\zs.*\\ze\\)")')
  let res['variationpoints'] = vp

  " Parameters
  let params = filter(copy(lines), 'v:val =~ "s:Param(\\|s:Args("')
  let res['params'] = params

  " Options
  let options = filter(copy(lines), 'v:val =~ "\\voption#(dev#)=get\\("')
  call map(options, 'matchstr(v:val, "\\voption#(dev#)=get\\(\\zs.*\\ze\\)")')
  let res['options'] = options

  " Hint
  let hint_line = match(lines, 'VimL:\s*"\s*hint\s*')
  let res['hint'] = hint_line<0 ? '' : substitute(lines[hint_line], '\v.*hint:\s*(.*)', '`\1`', '')

  " Surround
  let surround = filter(copy(lines), 'v:val =~ "s:Surround("')
  let res['surround'] = surround

  " Post import/post expand hook
  let hooks = filter(copy(lines), 'v:val =~ "s:AddPostExpandCallback"')
  call map(hooks, 'matchstr(v:val, "\\v.*s:AddPostExpandCallback\\(.\\zs.*\\ze.\\).*")')
  call map(hooks, 'substitute(v:val, "\\v.*(\\<.*\\>).*", "`\\1`", "g")')
  let res['hooks'] = hooks

  return res
endfunction

" # To markdown helpers {{{2

" Function: lh#mut#info#_field_to_md(info, field) {{{3
let s:k_fields = {
      \   'variationpoints': 'Variation Points'
      \ , 'params'         : 'Parameters'
      \ , 'options'        : 'Options'
      \ , 'hint'           : 'Produces'
      \ , 'surround'       : 'Surround'
      \ , 'hooks'          : 'Also includes'
      \ }
function! lh#mut#info#_field_to_md(info, field) abort
  if ! has_key(a:info, a:field)
    return []
  endif
  let info = a:info[a:field]
  if empty(info)
    return []
  endif
  let res = []
  let res += ['**'.s:k_fields[a:field].':**']
  if type(info) == type('string)')
    let res[-1] .= ' '.info
  " elseif len(info) == 1
    " let res[-1] .= info[0]
  else
    let res += map(info, '"  * ".v:val')
  endif
  let res += ['']
  return res
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
