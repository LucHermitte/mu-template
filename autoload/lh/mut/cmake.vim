"=============================================================================
" File:         autoload/lh/mut/cmake.vim                         {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      001
" Created:      29th Sep 2013
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       Core functions to generate CMake templates
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh/mut
"       Requires Vim7+
"       «install details»
" History:      «history»
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
let s:k_version = 1
function! lh#mut#cmake#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#mut#cmake#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#mut#cmake#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1

" Function: lh#mut#cmake#is_root_cmakelist(dir) {{{2
function! lh#mut#cmake#is_root_cmakelist(dir)
  " fnamemodify is required in order to ignore the current CMakeLists.txt in
  " case the file exists and is being regenerated with :MuTemplate
  let f =findfile("CMakeLists.txt", fnamemodify(a:dir, ':h').";")
  return empty(f)
endfunction

" Function: lh#mut#cmake#subdirs(dir) {{{2
function! lh#mut#cmake#subdirs(dir)
  let dirs = split(glob(a:dir.'/*'), '\n')
  let dirs = filter(dirs, 'isdirectory(v:val)')
  let dirs = map(dirs, 'lh#path#relative_to(a:dir, v:val)[:-2]')
  return dirs
endfunction

" Function: lh#mut#cmake#has_a_doxyfile(dir) {{{3
" @pre {a:dir} is expected to be an absolute file name
function! lh#mut#cmake#find_doxyfile(dir)
  " Search the file on the disk, in the sub-directories
  let f = split(glob(a:dir.'/**/Doxyfile*'), '\n')
  let f = map(f, 'lh#path#relative_to(a:dir, v:val)[:-2]')
  " Or in the buffer lists (in case it hasn't been saved yet)
  if empty(f)
    let f = map(lh#buffer#list(), 'bufname(v:val)')
    call filter(f, 'v:val =~ "Doxyfile"')
    call filter(f, 'lh#path#is_in(v:val, a:dir)')
  endif
  return f
endfunction
"------------------------------------------------------------------------
" ## Internal functions {{{1

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
