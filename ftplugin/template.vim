"=============================================================================
" File:		ftplugin/template.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim>
" Version:	4.3.0
" Created:	13th nov 2002
" Last Update:	12th Sep 2017
"------------------------------------------------------------------------
" Description:	ftplugin for mu-template's template files
"   It makes sure that the syntax coloration and ftplugins loaded match the
"   filetype aimed by the template file, while &filetype values 'template'.
"
"------------------------------------------------------------------------
" History:
"    v4.3.0: Add CTRL-L_e to display snippet s: variables
"    v4.0.0: Better n_CTRL-W on s:Include()
"    v3.5.3. Syntax file for templates that embeds some of vim syntax
"    v2.3.0.
"       n_CTRL-W_f overriden to follow s:Include() calls in template-files.
"    30th May 2004: v1.02
"	Installation comment changed. -> better recognition of the target ft
"    16th Apr 2006: v1.0.0
"    	empty b:ft won't load every ftplugin
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
runtime syntax/template.vim

nnoremap <buffer> <silent> <c-w>f :call <sid>OpenFile()<cr>
xnoremap <buffer>          <c-l>e <c-\><c-n>:echo lh#object#to_string(lh#mut#debug(lh#visual#selection()))<cr>gv
nnoremap <buffer>          <c-l>e :echo lh#object#to_string(lh#mut#debug(expand('<cword>')))<cr>

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

function! s:OpenFile() abort
  let l = getline('.')
  if l !~ 's:Include('
    exe "normal! \<c-w>f"
  else
    let [a, file, path ; tail] = matchlist( l, '\vs:Include\(\s*([^,]+)%(,\s*([^,\)]+)(,\s*[^\)]+)=)=\)')
    let file = eval(file)
    let path = empty(path) ? '' : eval(path).'/'
    call lh#mut#edit(path.file)
  endif
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
