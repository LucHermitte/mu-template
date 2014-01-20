"=============================================================================
" $Id$
" File:		mkVba/mk-mu-template.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	3.1.0
let s:version = '3.1.0'
" Created:	06th Nov 2007
" Last Update:	$Date$
"------------------------------------------------------------------------
cd <sfile>:p:h
try 
  let save_rtp = &rtp
  let &rtp = expand('<sfile>:p:h:h').','.&rtp
  exe '22,$MkVimball! mu-template-'.s:version
  set modifiable
  set buftype=
finally
  let &rtp = save_rtp
endtry
finish
after/plugin/mu-template.vim
after/template/MyProject-file-header.template
after/template/addon-info.template
after/template/c.template
after/template/c/case.template
after/template/c/do.template
after/template/c/for.template
after/template/c/fori.template
after/template/c/header-guard.template
after/template/c/if.template
after/template/c/internals/c-file-header.template
after/template/c/internals/c-header-content.template
after/template/c/internals/c-header-guard.template
after/template/c/internals/c-header-typical.template
after/template/c/internals/c-header.template
after/template/c/internals/c-imp.template
after/template/c/main.template
after/template/c/section-sep.template
after/template/c/stderr.template
after/template/c/switch.template
after/template/c/while.template
after/template/cmake.template
after/template/cmake/add_subdirectory.template
after/template/cmake/boost-loop-on-tests.template
after/template/cmake/boost-test.template
after/template/cmake/cpack.template
after/template/cmake/cpp11.template
after/template/cmake/doxygen.template
after/template/cmake/find-boost.template
after/template/cmake/if.template
after/template/cmake/internals/root.template
after/template/cmake/internals/subdirs.template
after/template/cpp.template
after/template/cpptu-header.template
after/template/cppunit-header.template
after/template/docbk/code.template
after/template/docbk/emphasis.template
after/template/docbk/filename.template
after/template/docbk/function.template
after/template/docbk/glossentry.template
after/template/docbk/glossterm.template
after/template/docbk/itemizedlist.template
after/template/docbk/listitem.template
after/template/docbk/literal.template
after/template/docbk/para.template
after/template/docbk/programlisting.template
after/template/docbk/section.template
after/template/docbk/title.template
after/template/doxygen/Doxyfile.template
after/template/help.template
after/template/html.template
after/template/license/boost-full.template
after/template/license/boost-short.template
after/template/license/copying.template
after/template/license/gplv3-full.template
after/template/license/gplv3-short.template
after/template/perl.template
after/template/perl/item.template
after/template/perl/over.template
after/template/sh.template
after/template/sh/case.template
after/template/sh/current-dir.template
after/template/sh/does_match.template
after/template/sh/field.template
after/template/sh/for.template
after/template/sh/if-nb-args.template
after/template/sh/if.template
after/template/sh/lvalue.template
after/template/sh/rvalue.template
after/template/tcl.template
after/template/template.template
after/template/template/arg.template
after/template/template/if.template
after/template/template/include.template
after/template/template/reindent.template
after/template/test-included.template
after/template/test.template
after/template/tex/begin-end.template
after/template/tex/center.template
after/template/tex/down.template
after/template/tex/figure.template
after/template/tex/frac.template
after/template/tex/frame-beamer.template
after/template/tex/frame-vhelp-beamer.template
after/template/unknown.template
after/template/vim.template
after/template/vim/augroup.template
after/template/vim/autoload-debug.template
after/template/vim/foreach.template
after/template/vim/fori.template
after/template/vim/function.template
after/template/vim/internals/get-script-kind.template
after/template/vim/internals/vim-autoload-debug.template
after/template/vim/internals/vim-autoload-function.template
after/template/vim/internals/vim-autoload-plugin.template
after/template/vim/internals/vim-footer.template
after/template/vim/internals/vim-ftplugin.template
after/template/vim/internals/vim-header.template
after/template/vim/internals/vim-mkvba.template
after/template/vim/internals/vim-other-scripts.template
after/template/vim/internals/vim-plugin.template
after/template/vim/internals/vim-rc-local-ccpp.template
after/template/vim/internals/vim-rc-local-cpp-style.template
after/template/vim/internals/vim-rc-local-default.template
after/template/vim/internals/vim-rc-local-global-cmake-def.template
after/template/vim/internals/vim-rc-local.template
after/template/vim/loop-arg.template
after/template/vim/menu-make.template
after/template/vim/option-protect.template
after/template/vim/plugmap.template
after/template/vim/snr.template
after/template/xslt/apply-template.template
after/template/xslt/attribute.template
after/template/xslt/call-template.template
after/template/xslt/choose.template
after/template/xslt/copy-of.template
after/template/xslt/for-each.template
after/template/xslt/if.template
after/template/xslt/otherwise.template
after/template/xslt/param.template
after/template/xslt/template-match.template
after/template/xslt/template-name.template
after/template/xslt/text.template
after/template/xslt/value-of.template
after/template/xslt/variable.template
after/template/xslt/when.template
after/template/xslt/with-param.template
autoload/lh/cpp/file.vim
autoload/lh/mut.vim
autoload/lh/mut/cmake.vim
autoload/lh/mut/dirs.vim
doc/mu-template.txt
ftplugin/template.vim
mkVba/mk-mu-template.vim
mu-template-addon-info.txt
mu-template.README
syntax/2html.vim
