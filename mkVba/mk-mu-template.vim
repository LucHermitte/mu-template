"=============================================================================
" $Id$
" File:		mkVba/mk-mu-template.vim
" Author:	Luc Hermitte <EMAIL:hermitte {at} free {dot} fr>
"		<URL:http://hermitte.free.fr/vim/>
" Version:	3.0.5
let s:version = '3.0.5'
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
after/template/addon-info
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
after/template/cmake/boost-test.template
after/template/cmake/cpack.template
after/template/cmake/cpp11.template
after/template/cmake/doxygen.template
after/template/cmake/if.template
after/template/cmake/internals/root.template
after/template/cmake/internals/subdirs.template
after/template/cpp.template
after/template/cpptu-header.template
after/template/cppunit-header.template
after/template/help.template
after/template/html.template
after/template/java
after/template/license/boost-full.template
after/template/license/boost-short.template
after/template/license/copying.template
after/template/license/gplv3-full.template
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
after/template/vim/internals/vim-rc-local.template
after/template/vim/loop-arg.template
after/template/vim/menu-make.template
after/template/vim/option-protect.template
after/template/vim/plugmap.template
after/template/vim/snr.template
after/template/xslt/xsl-attribute.template
after/template/xslt/xsl-for-each.template
after/template/xslt/xsl-if.template
after/template/xslt/xsl-otherwise.template
after/template/xslt/xsl-template-match.template
after/template/xslt/xsl-template-name.template
after/template/xslt/xsl-value-of.template
after/template/xslt/xsl-when.template
autoload/lh/cpp/file.vim
autoload/lh/mut.vim
autoload/lh/mut/dirs.vim
doc/mu-template.txt
ftplugin/template.vim
mkVba/mk-mu-template.vim
mu-template-addon-info.txt
mu-template.README
syntax/2html.vim
