"=============================================================================
" $Id$
" File:		ftplugin/template.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim>
" Version:	2.3.0
" Created:	13th nov 2002
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	ftplugin for mu-template's template files
"   It makes sure that the syntax coloration and ftplugins loaded match the
"   filetype aimed by the template file, while &filetype values 'template'.
" 
"------------------------------------------------------------------------
" History:	
"    30th May 2004: v1.02
"	Installation comment changed. -> better recognition of the target ft
"    16th Apr 2006: v1.0.0
"    	empty b:ft won't load every ftplugin
"    v2.3.0.
"       n_CTRL-W_f overriden to follow s:Include() calls in template-files.
" TODO:		
" (*) Auto install the patch for $HOME/.vim/filetype.vim:
"     Hint: source a hook for template files from filetype.vim, and check
"     filetype.vim sources the hook.
"=============================================================================
"
" Avoid reinclusion
let s:k_version = 230
if &cp || (exists("b:loaded_ftplug_template")
      \ && (b:loaded_ftplug_template >= s:k_version)
      \ && !exists('g:force_reload_ftplug_template'))
  finish
endif
let b:loaded_ftplug_template_vim = s:k_version
"
let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
if exists('b:ft') && strlen(b:ft) && b:ft != 'template'
  exe 'runtime! syntax/'.b:ft.'.vim'
  exe 'runtime! ftplugin/'.b:ft.'.vim ftplugin/'.b:ft.'_*.vim ftplugin/'.b:ft.'/*.vim'
endif

nnoremap <buffer> <silent> <c-w>f :call <sid>OpenFile()<cr>

"=============================================================================
" Global Definitions {{{1
" Avoid global reinclusion {{{2
if &cp || (exists("g:loaded_ftplug_template")
      \ && (g:loaded_ftplug_template >= s:k_version)
      \ && !exists('g:force_reload_ftplug_template'))
  let &cpo=s:cpo_save
  finish
endif
let g:loaded_ftplug_template = s:k_version
" unlet b:ft

function! s:OpenFile()
  let l = getline('.')
  if l !~ 's:Include('
    exe "normal! \<c-w>f"
  else
    let [a, file, path ; tail] = matchlist(l, 's:Include(\s*\([^,]\+\),\s*\([^)]\+\))')
    let file = eval(file)
    let path = eval(path)
    call lh#mut#edit(path.'/'.file)
  endif
endfunction

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
