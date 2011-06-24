"=============================================================================
" $Id$
" File:         autoload/lh/mut/dirs.vim                          {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:      2.3.0
" Created:      05th Jan 2011
" Last Update:  $Date$
"------------------------------------------------------------------------
" Description:
"       mu-template internal functions
"       The purpose of this autoload plugin is to provide an internal library
"       to plugin/mu-template.vim and autoload/lh/mut.vim (that will always be
"       loaded)
" 
"------------------------------------------------------------------------
" Installation:
"       Drop this file into {rtp}/autoload/lh
"       Requires Vim7+
"       See plugin/mu-template.vim
" History:      
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
let s:k_version = 220
function! lh#mut#dirs#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = 0
function! lh#mut#dirs#verbose(...)
  if a:0 > 0 | let s:verbose = a:1 | endif
  return s:verbose
endfunction

function! s:Verbose(expr)
  if s:verbose
    echomsg a:expr
  endif
endfunction

function! lh#mut#dirs#debug(expr)
  return eval(a:expr)
endfunction


"------------------------------------------------------------------------
" ## Exported functions {{{1
"
" Function: lh#mut#dirs#update() {{{2
" Defines directories to search for templates
let lh#mut#dirs#cache = ''
function! lh#mut#dirs#update()
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

  let g:lh#mut#dirs#cache = result
endfunction

" Function: lh#mut#dirs#get_templates_for([pattern]) {{{2
" unused
function! lh#mut#dirs#get_templates_for(...)
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
  let templatepath = dir.ft.'.template'
  let matching_filenames = lh#path#glob_as_list(g:lh#mut#dirs#cache, templatepath)
  return matching_filenames
endfunction

" Function: lh#mut#dirs#shorten_template_filenames(list)       {{{2
function! lh#mut#dirs#shorten_template_filenames(list)
  :let g:list =a:list
  " 1- Strip path part from lh#mut#dirs#cache
  call map(a:list, 'lh#path#strip_start(v:val, g:lh#mut#dirs#cache)')
  " 2- simplify filename to keep only the non "template" part
  "NAMES WERE: call map(a:list, 'substitute(v:val, "\\<template\.", "", "")')
  call map(a:list, 'substitute(v:val, "\.template\\>", "", "")')
  return a:list
endfunction

" Function: lh#mut#dirs#get_short_list_of_FT_matching(word, filetype) {{{2
function! lh#mut#dirs#get_short_list_of_FT_matching(word, filetype)
  " 1- Build the list of template files matching the current word {{{3
  let files = s:GetTemplateFilesMatching(a:word, a:filetype)

  " 2- Shorten the template-file names                            {{{3
  call s:UpdateHints(files)
  let strings = lh#mut#dirs#shorten_template_filenames(files)
  return strings
endfunction

" Function: lh#mut#dirs#hint(name)                             {{{2
function! lh#mut#dirs#hint(name)
  return s:__cache[a:name].hint
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
" Filetypes inheritance                                        {{{2
if !exists('g:mt_inherited_ft_for_cpp')
  let g:mt_inherited_ft_for_cpp    = 'c'
endif
if !exists('g:mt_inherited_ft_for_csharp')
  let g:mt_inherited_ft_for_csharp = 'c'
endif
if !exists('g:mt_inherited_ft_for_java')
  let g:mt_inherited_ft_for_java   = 'c'
endif

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
  call lh#mut#dirs#update()
  try
    let l:wildignore = &wildignore
    let &wildignore  = ""
    let files = lh#path#glob_as_list(g:lh#mut#dirs#cache, gpatterns)
    return files
  finally
    let &wildignore = l:wildignore
  endtry
endfunction

" s:UpdateHints(files)                                         {{{2
let s:__cache = {}
function! s:UpdateHints(files)
  for file in a:files

    " Strip path part from lh#mut#dirs#cache
    let p = lh#path#strip_start(file, g:lh#mut#dirs#cache)
    " simplify filename to keep only the non "template" part
    let short = substitute(p, "\.template\\>", "", "")

    if ! has_key(s:__cache, short)
      let s:__cache[short] = { "date": 0}
    endif
    let info = s:__cache[short]
    let date = getftime(file)
    if info.date < date
      let content = readfile(file)
      let hint_line = match(content, 'VimL:\s*"\s*hint\s*')
      let info.hint = hint_line<0 ? '' : matchstr(content[hint_line], 'hint:\s*\zs.*')
      let info.date = date
      "
    endif
    " echomsg string(s:__cache[short])
  endfor
endfunction


"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
