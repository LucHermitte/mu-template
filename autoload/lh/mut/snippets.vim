"=============================================================================
" File:         autoload/lh/mut/snippets.vim                      {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/mu-template>
" Version:      4.3.0.
let s:k_version = '430'
" Created:      17th Jan 2017
" Last Update:  19th Jan 2017
"------------------------------------------------------------------------
" Description:
"       Helper functions for define snippets
"
"------------------------------------------------------------------------
" History:
" v4.3.0: Move from lh-cpp
" TODO:         «missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#mut#snippets#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#mut#snippets#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Log(expr, ...)
  call call('lh#log#this',[a:expr]+a:000)
endfunction

function! s:Verbose(expr, ...)
  if s:verbose
    call call('s:Log',[a:expr]+a:000)
  endif
endfunction

function! lh#mut#snippets#debug(expr) abort
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
" # Functions to tune mu-template class skeletons {{{2

" Function: lh#mut#snippets#_filter_functions(list, visibility) {{{3
" Function: lh#mut#snippets#_filter_functions(list, field, value)
" TODO: use lh-dev ft-polymorphism as C++ has specific rules regarding
" visibility management and the "how" field that dictates when definitions are
" defaulted or deleted in C++11
LetIfUndef g:cpp_opened_default_visibiliy    = 'public'
LetIfUndef g:java_opened_default_visibiliy   = 'public'
LetIfUndef g:csharp_opened_default_visibiliy = 'public'
function! lh#mut#snippets#_filter_functions(list, ...) abort
  if a:0 == 1
    let value = a:1
    let field = 'visibility'
    let default = lh#ft#option#get('opened_default_visibiliy', &ft, '')
  elseif a:0 == 2
    let value = a:2
    let field = a:1
    let default = ''
  else
    call lh#assert#unexpected('Incorrect number of argument in lh#mut#snippets#_filter_functions -> '.string(a:000))
  endif
  let res = copy(a:list)
  call filter(res, 'get(v:val, field, default) == value')
  return res
endfunction

" Function: lh#mut#snippets#new_function_list() {{{3
function! s:add(fns)      dict abort " {{{4
  let self.list += a:fns
  call map(a:fns, 'extend(v:val, {"add_new": function(s:getSNR("AddNew"))})')
  " for fn in a:fns
    " call extend(fn, {'add_new': function(s:getSNR('AddNew'))})
  " endfor
  return self
endfunction
function! s:insert(fn)    dict abort " {{{4
  call extend(a:fn, {'add_new': function(s:getSNR('AddNew'))})
  call insert(self.list, a:fn)
  return self
endfunction
function! s:get(id)       dict abort " {{{4
  if type(a:id) == type('name')
    let res = filter(copy(self.list), 'has_key(v:val, "name") && v:val.name =~ a:id')
  else
    let res = filter(copy(self.list), 's:FunctionMatchesDescription(v:val, a:id)')
  endif
  return res
endfunction
function! s:get1(id, ...) dict abort " {{{4
  let matching_functions = self.get(a:id)
  if len(matching_functions) > 1
    throw "MuTemplate: Too many functions match ".string(a:id)
  elseif empty(matching_functions)
    " New reference created, and returned
    let new_fn = a:0 > 0 ? a:1 : {}
    " Force the searched pattern onto the function to return, at least this,
    " is correct
    call extend(new_fn, a:id)
    call self.add([new_fn])
    return new_fn
  endif
endfunction
function! s:filter(descr) dict abort " {{{4
  let res = filter(copy(self.list), 's:FunctionMatchesDescription(v:val, a:descr)')
  return res
endfunction
function! s:reverse()     dict abort "{{{4
  return reverse(self.list)
endfunction
function! lh#mut#snippets#new_function_list() abort " {{{4
  let fl = lh#object#make_top_type({ 'list': []})
  let fl.add       = function(s:getSNR('add'))
  let fl.insert    = function(s:getSNR('insert'))
  let fl.get       = function(s:getSNR('get'))
  let fl.get1      = function(s:getSNR('get1'))
  let fl.filter    = function(s:getSNR('filter'))
  let fl.reverse   = function(s:getSNR('reverse'))

  " Return object {{{4
  return fl
" }}}4
endfunction

function! s:AddNew(dst) dict abort
  return extend(self, a:dst, 'keep')
endfunction

"------------------------------------------------------------------------

"------------------------------------------------------------------------
" ## Internal functions {{{1

" # Misc {{{2
" s:getSNR([func_name]) {{{3
function! s:getSNR(...)
  if !exists("s:SNR")
    let s:SNR=matchstr(expand('<sfile>'), '<SNR>\d\+_\zegetSNR$')
  endif
  return s:SNR . (a:0>0 ? (a:1) : '')
endfunction

" Function: s:FunctionMatchesDescription(fn, descr) {{{3
function! s:FunctionMatchesDescription(fn, descr)
  for [k, v] in items(a:descr)
    if ! has_key(a:fn, k) || a:fn[k] != v
      return 0
    endif
    return 1
  endfor
endfunction

"------------------------------------------------------------------------
" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
