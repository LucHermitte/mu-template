"=============================================================================
" File:		autoload/lh/cpp/file.vim                           {{{1
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://code.google.com/p/lh-vim/>
" Version:	4.3.2
let s:k_version = '4.3.2'
" Created:	12th Feb 2008
" Last Update:	24th Oct 2018
"------------------------------------------------------------------------
" Description:	«description»
"
"------------------------------------------------------------------------
" Installation:
" 	drop into {rtp}/autoload/lh/cpp
" History:	«history»
" TODO:		«missing features»
" }}}1
"=============================================================================

let s:cpo_save=&cpo
set cpo&vim
"------------------------------------------------------------------------
" ## Functions {{{1
" ## Misc Functions     {{{1
" # Version {{{2
function! lh#cpp#file#version()
  return s:k_version
endfunction

" # Debug   {{{2
let s:verbose = get(s:, 'verbose', 0)
function! lh#cpp#file#verbose(...)
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

function! lh#cpp#file#debug(expr) abort
  return eval(a:expr)
endfunction

"------------------------------------------------------------------------
" # Public {{{2
function! lh#cpp#file#IncludedPaths() abort
  " 1- Use (bpg):cpp_included_paths by default
  " 2- If not defined, fall back to lh#cpp#tags#get_included_paths()
  " 3- If lh-cpp is not installed, fall back to the path of the current file,
  "    relative to the current working directory
  let paths = copy(lh#option#get("cpp_included_paths"))
  if lh#option#is_unset(paths)
    unlet paths
    " Search to use lh-cpp function
    runtime autoload/lh/cpp/tags.vim
    if exists('*lh#cpp#tags#get_included_paths')
      let paths = lh#cpp#tags#get_included_paths()
    else
      " TODO: also add project path by default?
      let paths = [expand('%:p:h')]
    endif
  endif

  " call add(paths, '.')
  return paths
endfunction

function! s:ValidFile(filename) abort
  return filereadable(a:filename) || bufexists(a:filename)
endfunction

function! lh#cpp#file#HeaderName(file) abort
  if     exists('g:lh#alternate')             " From alternate-lite
    let alternates = lh#alternate#_find_existing_alternates({'filename': a:file, 'ft': &ft})
    call map(alternates, 'lh#path#simplify(v:val, 0)')
    let alternates = lh#list#unique_sort(alternates)
    let inc_paths = lh#cpp#file#IncludedPaths()
    "" Replace '.' path with path of current file
    " call map(inc_paths, 'substitute(v:val, "^\\.\\(/\\|$\\)", expand("%:p:h"), "g")')
    call map(alternates, 'lh#path#strip_start(v:val, inc_paths)')
    if len(alternates) > 1
      call map(alternates, 'lh#marker#txt(v:val)')
    endif
    return join(alternates,'')
  elseif exists("*EnumerateFilesByExtension") " From a.vim
    let extension   = DetermineExtension(fnamemodify(a:file, ":p"))
    let baseName    = substitute(fnamemodify(a:file, ":t"), "\." . extension . '$', "", "")
    let currentPath = fnamemodify(a:file, ":p:h")
    let allfiles1 = EnumerateFilesByExtension(currentPath, baseName, extension)
    let allfiles2 = EnumerateFilesByExtensionInPath(baseName, extension, g:alternateSearchPath, currentPath)
    let comma = strlen(allfiles1) && strlen(allfiles2)
    let allfiles = allfiles1 . (comma ? ',' : '') . allfiles2

    let l_allfiles = split(allfiles, ',')
    let l_matches  = filter(l_allfiles, 'filereadable(v:val) || bufexists(v:val)')
    call map(l_matches, 'lh#path#simplify(v:val, 0)')
    let l_matches = lh#list#unique_sort(l_matches)
    let inc_paths = lh#cpp#file#IncludedPaths()
    call map(l_matches, 'lh#path#strip_start(v:val, inc_paths)')
    if len(l_matches) > 1
      call map(l_matches, 'lh#marker#txt(v:val)')
    endif
    return join(l_matches,'')
  else " a.vim is not installed
    let base = fnamemodify(a:file, ":r")
    if      s:ValidFile(base.'.h')   | return base.'h'
    elseif  s:ValidFile(base.'.hh')  | return base.'hh'
    elseif  s:ValidFile(base.'.hpp') | return base.'hpp'
    else                             | return ''
    endif
  endif
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
