"=============================================================================
" File:         autoload/lh/tex/mut.vim                           {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/mu-template>
" Version:      3.4.8.
let s:k_version = '348'
" Created:      21st Jul 2015
" Last Update:
"------------------------------------------------------------------------
" Description:
"       «description»
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
function! lh#tex#mut#version()
  return s:k_version
endfunction

" # Debug   {{{2
if !exists('s:verbose')
  let s:verbose = 0
endif
function! lh#tex#mut#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#tex#mut#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" # API for mu-template {{{2
" Function: lh#tex#mut#last_title([line]) {{{3
let s:k_title_rgx = '\\\(\(sub\)*section\|part\|chapter\){'
function! lh#tex#mut#last_title(...) abort
  let ln = a:0 > 0 ? (a:1) : line('.')
  let lines = reverse(getline(1, ln))
  let idx = match(lines, s:k_title_rgx)
  return idx >= 0 ? matchstr(lines[idx], s:k_title_rgx.'\zs.\{-}\ze}') : ''
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
