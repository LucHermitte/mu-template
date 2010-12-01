"=============================================================================
" $Id$
" File:		ftplugin/template.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim>
" Version:	2.0.4
" Created:	13th nov 2002
" Last Update:	$Date$
"------------------------------------------------------------------------
" Description:	ftplugin for mu-template's template files
"   It makes sure that the syntax coloration and ftplugins loaded match the
"   filetype aimed by the template file, while &filetype values 'template'.
" 
"------------------------------------------------------------------------
" Installation:	
"    (*) Drop it into {rtp}/ftplugin/
"    (*) Add into your $HOME/.vim/filetype.vim:
"       au BufNewFile,BufRead template.*  | 
"              \ if (expand('<afile>:p:h') =~? '.*\<template\%([/\\].\+\)\=')  |
"              \    let s:ft = matchstr(expand('<afile>:p:h'), 
"              \        '.*\<template[/\\]\zs[^/\\]\+')                        |
"              \    if strlen(s:ft)                                            |
"              \      exe 'set ft='.s:ft                                       |
"              \    else                                                       |
"              \      exe ("doau filetypedetect BufRead " . expand("<afile>")) |
"              \    endif                                                      |
"              \    let g:ft = &ft  |
"              \    set ft=template |
"              \ endif
" History:	
"    30th May 2004: v1.02
"	Installation comment changed. -> better recognition of the target ft
"    16th Apr 2006: v1.0.0
"    	empty g:ft won't load every ftplugin
" TODO:		
" (*) Auto install the patch for $HOME/.vim/filetype.vim:
"     Hint: source a hook for template files from filetype.vim, and check
"     filetype.vim sources the hook.
"=============================================================================
"
" Avoid reinclusion
if exists('b:loaded_ftplug__template_vim') | finish | endif
let b:loaded_ftplug__template_vim = 1
"
let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
if strlen(g:ft)
  exe 'runtime! syntax/'.g:ft.'.vim'
  exe 'runtime! ftplugin/'.g:ft.'.vim ftplugin/'.g:ft.'_*.vim ftplugin/'.g:ft.'/*.vim'
endif

" unlet g:ft

"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
