"=============================================================================
" File:         autoload/lh/mut/dirs.vim                          {{{1
" Author:       Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" License:      GPLv3 with exceptions
"               <URL:http://code.google.com/p/lh-vim/wiki/License>
" Version:      3.3.6
let s:k_version = 336
" Created:      05th Jan 2011
" Last Update:  03rd Jan 2017
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
" 	v3.3.6
" 	(*) Some snippets can be common to all filetypes, they are expected to
" 	be in {template_root_dir}/_/
" 	v3.0.7
" 	(*) Fix bug to correctly read shorten names like
" 	    xslt/call-template.template
" 	v3.0.2
" 	(*) Have doxygen templates available in C
" 	v3.0.0
" 	(*) GPLv3
" 	(*) new option: [bg]:[{ft}_]mt_templates_paths
" 	(*) C++ template-file list inherits C *and* doxygen templates.
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
function! lh#mut#dirs#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#mut#dirs#verbose(...)
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

function! lh#mut#dirs#debug(expr) abort
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
  let template_dirs = split(&runtimepath, ',')
  call map(template_dirs, 'v:val."/template"')
  let result = []
  if exists('$VIMTEMPLATES')
    " $VIMTEMPLATES is used if defined
    " This must be a list of directories separated by ';' or ','
    " Note: $VIMTEMPLATES has precedence over 'runtimepath'
    let result = [$VIMTEMPLATES]
  endif
  let result += template_dirs
  let specific_paths = lh#ft#option#get('mt_templates_paths', &ft, [])
  let sp = type(specific_paths) == type([])
        \ ? specific_paths
        \ : split(specific_paths, ',')
  let result = sp + result
  " \\ -> \, // -> /
  call map(result, 'substitute(v:val, "\\v([/\\\\])\\1", "\1", "g")')
  " path/ -> path
  cal map(result, 'substitute(v:val, "[/\\\\]$", "", "")')

  " Keep only template directories that exist
  call filter(result, 'isdirectory(v:val)')
  let g:lh#mut#dirs#cache = join(result, ',')
  return result
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
  let matching_filenames = lh#path#glob_as_list(g:lh#mut#dirs#cache, templatepath, 0)
  return matching_filenames
endfunction

" Function: lh#mut#dirs#shorten_template_filenames(list)       {{{2
function! lh#mut#dirs#shorten_template_filenames(list)
  " 1- Strip path part from lh#mut#dirs#cache
  let list = lh#path#strip_start(a:list, g:lh#mut#dirs#cache)
  " 2- simplify filename to keep only the non "template" part
  "NAMES WERE: call map(a:list, 'substitute(v:val, "\\<template\.", "", "")')
  call map(list, 'substitute(v:val, "\\.template\\>$", "", "")')
  return list
endfunction

" Function: lh#mut#dirs#get_short_list_of_TF_matching(word, filetype) {{{2
function! lh#mut#dirs#get_short_list_of_TF_matching(word, filetype)
  " 1- Build the list of template files matching the current word {{{3
  let files = s:GetTemplateFilesMatching(a:word, a:filetype)
  " let [files, sec] = lh#time#bench(function('s:GetTemplateFilesMatching'), a:word, a:filetype)
  " call s:Verbose('s:GetTemplateFilesMatching(%1, %2) takes %3s to return %4 entries', a:word, a:filetype, sec, len(files))

  " 2- Shorten the template-file names                            {{{3
  if a:word != '*'
    " Don't fetch hints when building menus
    call s:UpdateHints(files)
  endif
  let strings = lh#mut#dirs#shorten_template_filenames(files)
  " let [strings, sec] = lh#time#bench('lh#mut#dirs#shorten_template_filenames', files)
  " call s:Verbose('lh#mut#dirs#shorten_template_filenames() takes %1s to simplify %2 entries', sec, len(files))
  return strings
endfunction "}}}3

" Function: lh#mut#dirs#hint(name)                             {{{2
function! lh#mut#dirs#hint(name)
  return s:__cache[a:name].hint
endfunction

"------------------------------------------------------------------------
" ## Internal functions {{{1
" Filetypes inheritance                                        {{{2
if !exists('g:mt_inherited_ft_for_c')
  let g:mt_inherited_ft_for_c      = 'dox'
endif
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
    return split(g:mt_inherited_ft_for_{a:filetype}, ',')
  else
    return []
  endif
endfunction

" s:GetTemplateFilesMatching(word, filetype)                   {{{2
function! s:GetTemplateFilesMatching(word, filetype)
  " Look for filetypes (C++ -> C, ...)
  let gpatterns=[]
  let fts = [a:filetype, '_']
  while !empty(fts)
    let ft = remove(fts, 0)
    "NAMES WERE: call add( gpatterns , ' template.'.ft.'-'.a:word )
    "NAMES WERE: call add( gpatterns , ft.'/template.'.a:word)
    call add( gpatterns , ' '.ft.'-'.a:word.'.template' )
    call add( gpatterns , ft.'/'.a:word.'.template')
    let fts += s:InheritedFiletypes(ft)
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

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
