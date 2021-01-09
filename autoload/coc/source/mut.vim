"=============================================================================
" File:         autoload/coc/source/mut.vim                       {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"               <URL:http://github.com/LucHermitte/mu-template>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/mu-template/blob/master/License.md>
" Version:      4.4.0.
let s:k_version = '440'
" Created:      08th Jan 2021
" Last Update:  09th Jan 2021
"------------------------------------------------------------------------
" Description:
"       Registers MuTemplate as a source for COC
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
function! coc#source#mut#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! coc#source#mut#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...) abort
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...) abort
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! coc#source#mut#debug(expr) abort
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" ## Exported functions {{{1
inoremap <silent> <Plug>MuT4COC <c-r>=<sid>expand_file()<cr>

" Function: coc#source#mut#init() {{{2
function! coc#source#mut#init() abort
  return {
        \ 'priority': 99,
        \ 'shortcut': 'µT',
        \ 'triggerCharacters': ['MuT']
        \}
endfunction

" Function: coc#source#mut#should_complete() {{{2
function! coc#source#mut#should_complete(opt) abort
  return 1
endfunction

" Function: coc#source#mut#complete() {{{2
function! coc#source#mut#complete(opt, cb) abort
  let w = a:opt.word . '*'
  let files = lh#mut#dirs#get_short_list_of_TF_matching(w, &ft, 1)
  let styles = lh#style#get(&ft)
  " Use "\%n" to insert "\n" and not a newline; see tex/note.template
  let Hint   = { f -> substitute(substitute(lh#mut#dirs#hint(f), '\\n', "\n", 'g'), '\\%n', '\\n', 'g') }
  let Apply_style = { h -> empty(l:styles) ? h : lh#style#apply_these(l:styles, h) }
  let entries = map(copy(files), {_,f -> {'file':f, 'equal': 'equal=1', 'word': substitute(f, '^'.&ft.'/', '', ''), 'kind': 'S', 'info': l:Apply_style(l:Hint(f)), 'isSnippet': 1}})
  " equal=1 seems requires to not see MuT snippets being discarded
  " isSnippet doesn't seem to be used by COC
  call s:Verbose("coc#MuT: opt %1, callback: %2 -> %3", a:opt, a:cb, entries)
  call a:cb(entries)
endfunction

" Function: coc#source#mut#on_complete(item) {{{2
function! coc#source#mut#on_complete(item) abort
  call s:Verbose("Finish COC-µT expansion of %1", a:item)
  " i_CTRL-R= isn't silent, while the plug mapping is.
  " And feedkeys() seems to be required for a smooth integration with COC
  let s:item_to_expand = a:item
  call feedkeys("\<Plug>MuT4COC")
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

function! s:expand_file() abort
  return lh#mut#_insert_template_file(s:item_to_expand.word, s:item_to_expand.file)
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
