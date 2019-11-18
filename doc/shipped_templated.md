## Shipped templates
µTemplate is shipped by default with the following templates:

* [Vim](#vim)
* [Python](#python)
* [C & C++](#c--c)
* [LaTeX](#latex)
* [XSLT](#xslt)
* [Licenses](#licenses)
* [Other filetypes](#other-filetypes)

### Vim

  * On creation of a new `.vim` file, the file is filled according to the kind of vim-script detected (from the directory where the new file is stored):
    * _autoload-plugins_ will contain a few debug oriented functions ;
    * _(plain) plugins_ will contain a global anti-reinclusion guard and its override variable (for maintenance purpose), an internal `s:k_version` number, and a few indications about what plugins should contain ;
    * _ft-plugins_ will contain a global and a local anti-reinclusion guard and their override variable (for maintenance purpose), an internal `s:k_version` number, and a few indications about what ft-plugins should contain ;
    * _local-vimrcs_ will look a lot like ft-plugin ;
    * otherwise, the file won't contain anything specific ;
    * **in all cases**:
      * a default header is filled with RCS tags (`$Id$`, `$Date$`) when the file is detected within a subversion repository, and other fields for the filename (kept relative to `{rtp}` when possible), the author/maintainer, the version, a short description, history, todo, _etc._ ;
      * `cpo&vim` is set for the duration of the script ;
      * a footer forces `foldmethod` to `marker`.
> All the choices made are the result of what I've come to consider over the years to be good practices regarding vim files contents.
> Each part may be individually overridden in your local settings (`:h MuT-paths-override`)

  * The snippets _foreach_, _fori_, _fordict_, _loop-arg_, and _while_ expand respectively to the `:for` vim-loop, a `:for` on dictionary `items()`, a `:while` vim-loop that increments _i_, or another index variable, or a simple `:while` loop.
  * The snippets _try_, _catch_, _finally_, and _raii_ expand into `:try`-`:catch`, `:catch`, `:try`-`:finally`, and `:try`-`:finally` combined with [`lh#on#exit()`](http://github.com/LucHermitte/lh-vim-lib)
  * The snippets _menu-make_, and _option-project_, expand into calls to
   [`lh#menu#make`](http://github.com/LucHermitte/lh-vim-lib).

  * The snippet _plugmap_ expands into an overridable _plug-mapping_.
  * The snippet _augroup_ expands into a cleared `:augroup` ready to defined
    new `:autocommand`s.

  * The snippet _autoload-debug_ expands into the debug-oriented functions added by default to autoload-plugins -- its purpose is to add simply those functions to autoload-plugins that don't have them yet.

  * The snippet _function_ expands into a `:function!` definition. If the current script is an autoload-plugin, the function name matches the autoload-plugin name -- to insert other kinds of functions, just use the `fu` abbreviation from `vim_snippets.vim`. Otherwise, the function name will just start with a `s:`.
  * The snippet _nvi-function_ expands into a NVI-like pair of function for [lh-dev](http://github.com/LucHermitte/lh-dev)
  * The snippet _snr_ expands into an helper function to obtain a valid VimL `function()` from a script function.

  * On creation of a new vim help file (1), the file is pre-filed with:
    * a header compatible with what is expected by `:h local-additions`, your name, and a `$Date$`,
    * a default footer (`$Id`, copyright line, modeline, _etc._)
    * and two skeletons for the sections _Contents_, and _Presentation_.
> (1) Creating a new vim help file may require the following actions:
```
:e ~/.vim/doc/foo.txt
:set ft=help
:MuTemplate
```

NB: there are no µTemplate snippets for `:if`, _etc._ because they are maintained independently thanks to [my bracketing system](http://github.com/LucHermitte/lh-brackets) in `vim_snippets.vim` (todo: add link).

### Python
  *  On creation of a new Python file, the shebang line and the encoding
     line matching the current `&fileencoding` are inserted.
  * Snippets for the main control statements are provided: `if`, `ifelse`,
    `elif`, `else`, `while`
  * Snippets for `class`, `def`, `init`, `del`, and _docstring_ are also provided
  * Plus a few other snippets: `from`-`import`, `with`, ...
  * Note: a few snippets (`path-exists` and `unittest`) require [lh-dev](http://github.com/LucHermitte/lh-dev) to be installed.

### C & C++
Most of my C and C++ template-files are shipped with [lh-cpp](http://github.com/LucHermitte/lh-cpp). However a few ones are still shipped with µTemplate:
  * On creation of a new C or C++ file, the file is filled according to the kind of file detected:
    * _header files_ first compute the relative current filename from the root of the current project, and contains a (-n overridable) file header, and adds automatically generated anti-reinclusion guards
    * _source files_ first compute the relative current filename from the root of the current project, and contains a (-n overridable) file header, and includes any matching _header file_ found (in the current directory, or any compatible directory when a.vim is installed)

  * snippets for `main`, `for`, `for (int i`, `while`, `do...while`, `switch` and `case`, `if` ; NB: [lh-cpp](http://github.com/LucHermitte/lh-cpp) defines alternative [smart-snippets for these control-statements](http://github.com/LucHermitte/lh-cpp#code-snippets), and several C++-only snippets in its [repository](http://github.com/LucHermitte/lh-cpp/blob/master/after/template/cpp)

  * Note: a few snippets (`stderr` and `printf`) require [lh-dev](http://github.com/LucHermitte/lh-dev) to be installed.

### LaTeX

Four snippets that are more a proof-of-concept than real snippets for intensive LaTeX editing are provided for:
  * `\begin{center}`, `\figure`
  * beamer frames

### XSLT

Several snippets are provided for `apply-template`, `attribute`,
`call-template`, `choose`, `for-each`, `if`, `otherwise`, `param`, `template
match`, `template name`, `text`, `value-of`, `variable`, `when`, and
`with-param`.

### Licenses

µTemplate provides a way to include automatically a license text into a file.

This can be done manually with a `:MuTemplate license/commented`. Not only the author name, and the current year will be inserted automatically, but also the license text will be inserted as a comment (in the syntax of the current filetype).

This can also be done automatically. For instance, if for your C project you want a BSD-2 clause license, your `$PROJECT_ROOT/templates/c/internals/c-file-header.template` could look like:

```
VimL: call s:Include('commented', 'license', 'boost-short')
/**@file	<+s:filename+>
 * @author	¡substitute(Author(0),'\r"','\r *','g')¡
 * @version	<+version+>
 * @date        <+date+>
 */
```

Moreover, when a new `COPYING` file is created with vim, the user will be asked which license he wants.

Notes:
 * Not all existing licenses are available, don't hesitate to add your own text into `after/template/license/text/` or to send it to me.
 * Unfortunatelly at this time, licenses snippets require [lh-dev](http://github.com/LucHermitte/lh-dev) to be installed.

### Other filetypes

Extremely simple template-files are provided for new cmake, perl, html, tcl, markdown, docbook, and for template-files files.
