## Introduction

µTemplate is a template-files loader for Vim. Once loaded, templates are interpreted and expanded according to a flexible syntax.

  * [Features](#features)
  * [Shipped templates](#shipped-templates)
    * [Vim](#vim)
    * [C & C++](#c-&-c++)
    * [LaTeX](#latex)
    * [XSLT](#xslt)
    * [Licenses](#licenses)
    * [Other filetypes](#other-filetypes)
  * [Examples](#examples)
    * [C-`if` snippet](#c--if-snippet)
    * [C-`case` snippet](#c--case-snippet)
    * [Interactive template-file: C++ Class Template](#interactive-template-file:-c++-class-template)
    * [Completely useless recursive example](#completely-useless-recursive-example)
  * [Installation](#installation)
  * [Credits](#credits)
  * [See also](#see-also)


## Features
  * Template-files can be expanded:
    * automatically when opening a new buffer (unless deactivated from the .vimrc),
    * explicitly through menus or the command line,
    * from the INSERT-mode in a snippet-like fashion ;
    * from the VISUAL-mode to surround the selection with a snippet ;
  * All snippets are defined in their own template-file ;
  * The template-files can be overridden by the user, or in the context of a specific project ;
  * Filetype specific snippets can be defined for the INSERT-mode (they can be inherited, e.g. C snippets can be used from C++, Java, _etc._), the list of matching snippets will be presented with a hint for each snippet ;
  * Computed VimL expressions can be inserted ;
  * VimL instructions can be executed during the expansion ;
  * Template-files can include other template-files in a function-like manner (parameters are even supported);
  * Fully integrated with my [placeholders-system](http://github.com/LucHermitte/lh-brackets) ;
  * Supports re-indentation (if desired) ;
  * Works well with vim folding ;
  * I18n friendly ;
  * The expansion happens after any [_local vimrcs_](http://github.com/LucHermitte/local_vimrc) present are loaded -- in order to set project-specific variables before the expansion is done.

  * Thanks to [Tom Link's StakeHolders](http://www.vim.org/scripts/script.php?script_id=3326) plugin, µTemplate does now have tied placeholders (modifying one named placeholder modifies other placeholders with the same name). Not installing Stakeholders will not prevent you from using µTemplate.

However, it misses the following features:
  * Several snippets per template-file -- It's extremely unlikely that µtemplate will ever work this way.
  * One key that does everything: expansion of snippets/previously typed keywords/dictionary/..., or jump to the next placeholder depending on the context.

## Shipped templates
µTemplate is shipped by default with the following templates:

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

  * The snippets _foreach_, _fori_, and _loop-arg_ expand respectively to the `:for` vim-loop, or a `:while` vim-loop that increments _i_, or another index variable.

  * The snippet _plugmap_ expands into an overridable _plug-mapping_.

  * The snippet _autoload-debug_ expands into the debug-oriented functions added by default to autoload-plugins -- its purpose is to add simply those functions to autoload-plugins that don't have them yet.

  * The snippet _function_ expands into a `:function!` definition. If the current script is an autoload-plugin, the function name matches the autoload-plugin name -- to insert other kinds of functions, just use the `fu` abbreviation from `vim_snippets.vim`. Otherwise, the function name will just start with a `s:`.

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


NB: there are no µTemplate snippets for `:if`, `:try`, _etc._ because they are maintained independently thanks to [my bracketing system](http://github.com/LucHermitte/lh-brackets) in `vim_snippets.vim` (todo: add link).

### C & C++
Most of my C and C++ template-files are shipped with [lh-cpp](http://github.com/LucHermitte/lh-cpp). However a few ones are still shipped with µTemplate:
  * On creation of a new C or C++ file, the file is filled according to the kind of file detected:
    * _header files_ first compute the relative current filename from the root of the current project, and contains a (-n overridable) file header, and adds automatically generated anti-reinclusion guards
    * _source files_ first compute the relative current filename from the root of the current project, and contains a (-n overridable) file header, and includes any matching _header file_ found (in the current directory, or any compatible directory when a.vim is installed)

  * snippets for `main`, `for`, `for (int i`, `while`, `do...while`, `switch` and `case`, `if` ; NB: [lh-cpp](http://github.com/LucHermitte/lh-cpp) defines alternative [smart-snippets for these control-statements](http://github.com/LucHermitte/lh-cpp#code-snippets), and several C++-only snippets in its [repository](http://github.com/LucHermitte/lh-cpp/after/template/cpp)

### LaTeX

Four snippets that are more a proof-of-concept than real snippets for intensive LaTeX editing are provided for:
  * `\begin{center}`, `\figure`
  * beamer frames

### XSLT

Several snippets are provided for `attribute`, `for-each`, `if`, `otherwise`, `template match`, `template name`, `value-of`, and `when`

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

N.B.: Not all existing licenses are available, don't hesitate to add your own text into `after/template/license/text/` or to send it to me.


### Other filetypes

Extremely simple template-files are provided for new cmake, perl, html, tcl, markdown, docbook, and for template-files files.


## Examples

A few examples are better than a long speech, check the [documentation](doc/mu-template.txt) for more precisions.

Note: all the default template-files shipped with mu-template can be browsed from the [subversion repository](after/template/)

### C-`if` snippet
```
VimL:"{if} Template-File, Luc Hermitte
VimL:" hint: if (cond) { action }
VimL: let s:value_start = '¡'
VimL: let s:value_end = '¡'
VimL: let s:reindent = 1
VimL: let s:marker_open = '<+'
VimL: let s:marker_close = '+>'
if(¡substitute(s:Surround(2, '<+cond+>'), '^\_s*\|\_s*$', '', 'g')¡){
¡s:Surround(1, '<+code+>')¡
}<++>
```

### C-`case` snippet
```
VimL:" {case:} File Template, Luc Hermitte, 05th Jan 2011
VimL:" hint: case {tag: ...; break;}
VimL: let s:value_start = '¡'
VimL: let s:value_start = '¡'
VimL: let s:value_end = s:value_start
VimL: let s:marker_open = '<+'
VimL: let s:marker_close = '+>'
VimL: let s:case = empty(s:Args()) ? Marker_Txt('case') : (s:Args()[0])
VimL: let s:_with_block2 = len(s:Args()) <= 1 ? INPUT("Insert a block for the case (0/1) ?") : (s:Args()[1])
case <+s:case+>:
<+s:_with_block2?'{':''+>
<+¡substitute(s:case, Marker_Txt('\(.\{-}\)'), '\1', '')¡-code+>;
break;
<+s:_with_block2?'}':''+>
```

### Interactive template-file: C++ Class Template
```
VimL:" C++ Class Template, Luc Hermitte
VimL:" hint: Class Wizard (asks for class semantics)
VimL: let s:value_start = '¡'
VimL: let s:value_end = '¡'
VimL: let s:reindent = 1
VimL: let s:marker_open = '<+'
VimL: let s:marker_close = '+>'
VimL: let s:clsname = empty(s:Args()) ? INPUT("class name ?", lh#marker#txt(expand('%:t:r'))) : (s:Args()[0])
VimL: call CppDox_ClassWizard(s:clsname)
VimL:"
VimL:"
VimL: call s:Include("section-sep", "c", s:clsname." class")
VimL: silent! unlet s:doc
VimL: let s:doc = []
VimL: let s:doc += [{ "tag": "ingroup", "text": "g".lh#option#get('dox_group', lh#marker#txt('Group')) }]
VimL: let s:doc += [{ "tag": "brief" }]
VimL: let s:doc += [{ "text": "\n" }]
VimL: let s:doc += [{ "text": "<+doc+>" }]
VimL: let s:doc += [{ "text": "\n" }]
VimL: let s:doc += [{ "tag": "invariant"}]
VimL: let s:doc += [{ "text": "\n" }]
VimL: let s:doc += [{ "tag": "semantics"}]
VimL: let s:doc += [{ "text": g:CppDox_semantics}]
VimL: let s:doc += [{ "text": "\n" }]
VimL: let s:doc += [{ "tag": "version", "text": "$"."revision$"}]
VimL: let s:doc += [{ "tag": "author"}]
VimL: call s:Include("formatted-comment", "cpp/internals", s:doc)
class <+s:clsname+>
¡g:CppDox_inherits¡
{
public:
/**<+lh#dox#tag('name')+> Construction/destruction
*/
//<+lh#dox#tag('{')+>
VimL: let s:fn_comments = { }
VimL: let s:fn_comments.brief = "Default constructor."
VimL: let s:fn_comments.throw = {"optional": 1}
VimL: call s:Include("function-comment", "cpp/internals",s:fn_comments)
<+s:clsname+>();

VimL: "
VimL: " not documented, this is :DOX job
<+s:clsname+>(<+define the params, and document me w/ :DOX+>);

VimL: "
VimL: " todo: support using default implementations
MuT: if g:CppDox_do_copy
VimL: call s:Include("copy-constructor", "cpp", s:clsname)
VimL: call s:Inject([""])
VimL: call s:Include("copy-and-swap", "cpp", s:clsname)

MuT: endif
VimL: call s:Include("destructor", "cpp",{"name":(s:clsname), "virtual": (g:CppDox_isVirtualDest) })
//<+lh#dox#tag('}')+>

<+Other public functions+>;

¡IF(strlen(g:CppDox_protected_members), "protected:\n", '')¡
¡g:CppDox_protected_members¡
private:
¡g:CppDox_forbidden_members¡

<+Private functions+>;

<+Attributes+>;
};<++>
```

### Completely useless recursive example
  * test.template
```
VimL: let s:value_start  = '¡'
VimL: let s:value_end    = '¡'
VimL: let s:marker_open  = '<+'
VimL: let s:marker_close = '+>'
VimL: let s:var = 1
BEGIN<++>
/*
 * ¡'$'¡Id$
 */
¡s:var¡
a¡s:var¡
¡s:var + 5¡a
a¡s:var¡a¡s:var¡
a¡s:var¡a¡s:var¡a
here <+we go+>
VimL: let s:msg =''
VimL: call s:Include('test-included')
VimL: let s:msg =' again'
VimL: call s:Include('test-included')

------
Some tests:
VimL: let s:expr = "first line\nsecond line\n "
text ¡s:expr¡
text
END
```
  * test-included.template
```
VimL: let s:times = exists('s:times') ? (s:times+1) : 1
This part has been included¡s:msg¡ ¡((s:times==1)?'once':(s:times==2 ? 'twice' : (s:times.' times')))¡.
VimL: if s:times <= 4 | call s:Include('test-included') | endif
VimL: silent! unlet s:times
```


## Installation
  * Requirements: Vim 7.+, [lh-vim-lib](http://github.com/LucHermitte/lh-vim-lib), [searchInRuntime](http://github.com/LucHermitte/searchInRuntime), and my [bracketing-system](http://github.com/LucHermitte/lh-brackets)
  * With [vim-addon-manager](https://github.com/MarcWeber/vim-addon-manager), install mu-template@lh. This is the preferred method because of the various dependencies.
```vim
ActivateAddons mu-template@lh
```
  * N.B.: installing [lh-cpp](http://github.com/LucHermitte/lh-cpp) or [lh-refactor](http://github.com/LucHermitte/lh-refactor) with VAM will also install µtemplate.
  * or you can clone the git repositories
```
git clone git@github.com:LucHermitte/lh-vim-lib.git
git clone git@github.com:LucHermitte/lh-tags.git
git clone git@github.com:LucHermitte/lh-dev.git
git clone git@github.com:LucHermitte/lh-brackets.git
git clone git@github.com:LucHermitte/searchInRuntime.git
```
  * or with Vundle/NeoBundle:
```vim
Bundle 'LucHermitte/lh-vim-lib'
Bundle 'LucHermitte/lh-tags'
Bundle 'LucHermitte/lh-dev'
Bundle 'LucHermitte/lh-brackets'
Bundle 'LucHermitte/searchInRuntime'
Bundle 'LucHermitte/mu-template'
Bundle 'tomtom/stakeholders_vim'
```

## Credits
  * Gergely Kontra is the author of the first version of µTemplate
  * Luc Hermitte (LH) is the current maintainer of this enhanced version of mu-template
  * Robert Kelly IV, Zdenek Sekera for their insight and the feedback they provided me (LH).

## See also
There are many other template-files loaders for Vim, see the [non exhaustive list of vim.wikia](http://vim.wikia.com/wiki/Category:Automated_Text_Insertion), or the [comparative matrix](http://vim-wiki.mawercer.de/wiki/topic/text-snippets-skeletons-templates.html) in Marc Weber's vim wiki.
