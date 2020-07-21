"=============================================================================
" File:         python-snippets.vim                               {{{1
" Author:       Luc Hermitte <EMAIL:luc {dot} hermitte {at} gmail {dot} com>
"		<URL:http://github.com/LucHermitte/mu-template>
" License:      GPLv3 with exceptions
"               <URL:http://github.com/LucHermitte/mu-template/blob/master/License.md>
" Version:      4.3.3.
let s:k_version = '433'
" Created:      18th Jul 2020
" Last Update:  21st Jul 2020
"------------------------------------------------------------------------
" Description:
"       Pure vimscript unit cases for Python snippets
"
"------------------------------------------------------------------------
" History:      <+history+>
" TODO:         <+missing features+>
" }}}1
"=============================================================================

UTSuite [mut#python] Testing Python snippets

runtime autoload/lh/mut.vim

let s:cpo_save=&cpo
set cpo&vim

"------------------------------------------------------------------------
" ## Fixtures {{{1
function! s:BeforeAll() abort
  call lh#window#create_window_with('sp vim-test-buffer.py')
  setlocal sw=4
  SetMarker <+ +>
endfunction

function! s:AfterAll() abort
  silent bw! vim-test-buffer.py
endfunction

"------------------------------------------------------------------------
" ## Tests {{{1
" Function: s:Test_free_func() {{{2
function! s:Test_free_func() abort
  SetBufferContent trim << EOF
  EOF

  MuTemplate python/def

  AssertBufferMatches trim << EOF
    def <+name+>(<+params+>):
        """
        <+doc+>
        """
        <+pass+>
    <++>
  EOF
endfunction

"------------------------------------------------------------------------
" Function: s:Test_explicit_method_func() {{{2
function! s:Test_explicit_method_func() abort
  SetBufferContent trim << EOF
  class foo(object):
  EOF

  normal! omethod
  exe "normal a\<Plug>MuT_ckword"

  AssertBufferMatches trim << EOF
    class foo(object):
        def <+name+>(self, <+params+>):
            """
            <+doc+>
            """
            <+pass+>
        <++>
  EOF
endfunction

"------------------------------------------------------------------------
" Function: s:Test_implicit_method() {{{2
function! s:Test_implicit_method() abort
  SetBufferContent trim << EOF
  class foo(object):
  EOF

  normal! odef
  exe "normal a\<Plug>MuT_ckword"

  AssertBufferMatches trim << EOF
    class foo(object):
        def <+name+>(self, <+params+>):
            """
            <+doc+>
            """
            <+pass+>
        <++>
  EOF
endfunction

"------------------------------------------------------------------------
" Function: s:Test_attribute() {{{2
function! s:Test_attribute() abort
  SetBufferContent trim << EOF
    class foo(object):
        def __init(self, val):
  EOF

  normal! Goattr
  exe "normal a\<Plug>MuT_ckword"
  exe "normal! \<esc>Go"
  " When using lh#mut#expand_and_jump() correct indenting cannot be forced w/ Python :(
  call lh#mut#expand_and_jump(0, 'python/attribute', {'rhs':'val'})
  exe "normal! \<esc>Go"
  call lh#mut#expand_and_jump(0, 'python/attribute', {'rhs':'val', 'attr': '_myattr'})
  exe "normal! \<esc>Go"
  call lh#mut#expand_and_jump(0, 'python/attribute', {'attr': '_myattr'})

  AssertBufferMatches trim << EOF
    class foo(object):
        def __init(self, val):
            self.<+__attr+> = <+attr+>
    self.__val = val
    self._myattr = val
    self._myattr = <+attr+>
  EOF
endfunction

"------------------------------------------------------------------------
" Function: s:Test_try() {{{2
function! s:Test_try() abort
  SetBufferContent trim << EOF
  EOF

  " Because of the delayed expansion and the fac <c-y> is defined on the
  " fly, we cannot tests the templates when menu expand => we need to be
  " explict and use lh#mut#expand_and_jump() :(
  normal! G
  call lh#mut#expand_and_jump(0, 'python/try')

  " normal! Gatry_else
  " exe "normal a\<Plug>MuT_ckword\<c-y>"
  " call feedkeys("a\<Plug>MuT_ckword", '')
  " call feedkeys("\<c-y>\<esc>", 'tx')

  AssertBufferMatches trim << EOF
  try:
      <+code+>
  except <+BaseException+> as <+e+>:
      <+exceptcode+>
  <++>
  EOF
endfunction

"------------------------------------------------------------------------
" Function: s:Test_tryelse() {{{2
function! s:Test_tryelse() abort
  SetBufferContent trim << EOF
  EOF

  " Because of the delayed expansion and the fac <c-y> is defined on the
  " fly, we cannot tests the templates when menu expand => we need to be
  " explict and use lh#mut#expand_and_jump() :(
  normal! G
  call lh#mut#expand_and_jump(0, 'python/try_else')

  " normal! Gatry_else
  " exe "normal a\<Plug>MuT_ckword\<c-y>"
  " call feedkeys("a\<Plug>MuT_ckword", '')
  " call feedkeys("\<c-y>\<esc>", 'tx')

  AssertBufferMatches trim << EOF
  try:
      <+code+>
  except <+BaseException+> as <+e+>:
      <+exceptcode+>
  else:
      <+exceptelsecode+>
  <++>
  EOF
endfunction

"------------------------------------------------------------------------
" Function: s:Test_tryfinally() {{{2
function! s:Test_tryfinally() abort
  SetBufferContent trim << EOF
  EOF

  normal! Gatry_finally
  exe "normal a\<Plug>MuT_ckword"

  AssertBufferMatches trim << EOF
  try:
      <+code+>
  except <+BaseException+> as <+e+>:
      <+exceptcode+>
  finally:
      <+finallycode+>
  <++>
  EOF
endfunction

"------------------------------------------------------------------------
" Function: s:Test_tryelsefinally() {{{2
function! s:Test_tryelsefinally() abort
  SetBufferContent trim << EOF
  EOF

  normal! Gatry_else_finally
  exe "normal a\<Plug>MuT_ckword"

  AssertBufferMatches trim << EOF
  try:
      <+code+>
  except <+BaseException+> as <+e+>:
      <+exceptcode+>
  else:
      <+exceptelsecode+>
  finally:
      <+finallycode+>
  <++>
  EOF
endfunction

" }}}1
"------------------------------------------------------------------------
let &cpo=s:cpo_save
"=============================================================================
" vim600: set fdm=marker:
