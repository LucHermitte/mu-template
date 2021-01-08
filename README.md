# µTemplate [![Last release](https://img.shields.io/github/tag/LucHermitte/mu-template.svg)](https://github.com/LucHermitte/mu-template/releases) [![Build Status](https://secure.travis-ci.org/LucHermitte/mu-template.png?branch=master)](http://travis-ci.org/LucHermitte/mu-template) [![Project Stats](https://www.openhub.net/p/21020/widgets/project_thin_badge.gif)](https://www.openhub.net/p/21020)

## Introduction

µTemplate is a template-files loader for Vim. Once loaded, templates are interpreted and expanded according to a flexible syntax.

  * [Features](#features)
  * [Typical workflows](doc/workflows.md)
    * [Plugin Configuration](doc/workflows.md#plugin-configuration)
    * [Snippet Expansion](doc/workflows.md#snippet-expansion)
    * [Surrounding with a snippet](doc/workflows.md#surrounding-with-a-snippet)
    * [Filetype dependent templates for new files](doc/workflows.md#filetype-dependent-templates-for-new-files)
  * [Shipped templates](doc/shipped_templates.md)
    * [Vim](doc/shipped_templates.md#vim)
    * [Python](doc/shipped_templates.md#python)
    * [C & C++](doc/shipped_templates.md#c--c)
    * [LaTeX](doc/shipped_templates.md#latex)
    * [XSLT](doc/shipped_templates.md#xslt)
    * [Licenses](doc/shipped_templates.md#licenses)
    * [Other filetypes](doc/shipped_templates.md#other-filetypes)
  * [Examples](#examples)
    * [C-`if` snippet](#c-if-snippet)
    * [C-`case` snippet](#c-case-snippet)
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
  * Supports re-indentation (if desired), and Python indentation ;
  * Works well with vim folding ;
  * I18n friendly ;
  * The expansion happens after any [_local vimrcs_](http://github.com/LucHermitte/local_vimrc) present are loaded -- in order to set project-specific variables before the expansion is done.

  * Thanks to [Tom Link's StakeHolders](http://www.vim.org/scripts/script.php?script_id=3326) plugin, µTemplate does now have tied placeholders (modifying one named placeholder modifies other placeholders with the same name). Not installing Stakeholders will not prevent you from using µTemplate.

However, it misses the following features:
  * Several snippets per template-file -- It's extremely unlikely that µTemplate will ever work this way.
  * One key that does everything: expansion of snippets/previously typed keywords/dictionary/..., or jump to the next placeholder depending on the context.

## Examples

A few examples are better than a long speech, check the [documentation](doc/mu-template.txt) for more precisions.

Note: all the default template-files shipped with mu-template can be browsed from the [repository](after/template/)

### C-`if` snippet
Snippet that uses `¡`, `s:Surround()`, [lh-style's styling feature](http://github.com/LucHermitte/lh-style#formatting.of.brackets.characters)
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
}<+s:TerminalPlaceHolder()+>
```

### C-`case` snippet
Snippet that uses `¡`, `s:TerminalPlaceHolder()`, [lh-style's styling feature](http://github.com/LucHermitte/lh-style#formatting.of.brackets.characters), and that takes options.
```
VimL:" {case:} File Template, Luc Hermitte, 05th Jan 2011
VimL:" hint: case {tag: ...; break;}
VimL: let s:value_start = '¡'
VimL: let s:value_start = '¡'
VimL: let s:value_end = s:value_start
VimL: let s:marker_open = '<+'
VimL: let s:marker_close = '+>'
VimL: let s:case = empty(s:Args()) ? lh#marker#txt('case') : (s:Args()[0])
VimL: let s:_with_block2 = len(s:Args()) <= 1 ? INPUT("Insert a block for the case (0/1) ?") : (s:Args()[1])
case <+s:case+>:
<+s:_with_block2?'{':''+>
<+¡substitute(s:case, lh#marker#txt('\(.\{-}\)'), '\1', '')¡-code+>;
break;
<+s:_with_block2?'}':''+>
```

### Vim-`plugmap` snippet
Recursive snippet that takes options, uses `s:Include()`,
`s:SurroundableParam()`, `:MuT`-commands, and that contain a loop

```
VimL:" ``VimL <Plug> mappings'' File Template, Luc Hermitte <hermitte {at} free {dot} fr>
VimL:" hint: <Plug>mapping + default mapping
VimL: let s:reindent     = 1
VimL: let s:marker_open  = '<+'
VimL: let s:marker_close = '+>'
MuT:  let s:mapmode = s:SurroundableParam('mode', 1, lh#option#unset())
MuT:  let s:plugname = s:SurroundableParam('plug', 2, lh#option#unset())
MuT:  if lh#option#is_unset(s:mapmode)
MuT:    let s:mapmode = INPUT('Mode (invox)?', lh#marker#txt('mode'))
MuT:  endif
MuT:  if lh#option#is_unset(s:plugname)
MuT:    let s:plugname =  INPUT('<Plug>?',       lh#marker#txt('name'))
MuT:  endif
VimL: call s:Include('get-script-kind', 'vim/internals')
VimL: let s:buffer = s:ftplug ? '<buffer> ' : ''
MuT:  if strlen(s:mapmode) == 1 || lh#marker#is_a_marker(s:mapmode)
<+s:mapmode+>noremap <+s:buffer+><silent> <Plug><+s:plugname+> <+definition+>
if !hasmapto('<Plug><+s:plugname+>', '<+s:mapmode+>')
  <+s:mapmode+>map <+s:buffer+><silent> <unique> <+keybinding+> <Plug><+s:plugname+>
endif
MuT:  else
VimL:    for mode in split(s:mapmode, '\zs') | call s:Include('plugmap', 'vim', {'mode': mode, 'plug': s:plugname}) | endfor
MuT:  endif
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
  * Requirements: Vim 7.+, [lh-vim-lib](http://github.com/LucHermitte/lh-vim-lib), [lh-style](http://github.com/LucHermitte/lh-style), and my [bracketing-system](http://github.com/LucHermitte/lh-brackets), and optionally [lh-dev](http://github.com/LucHermitte/lh-dev).
  * With [vim-addon-manager](https://github.com/MarcWeber/vim-addon-manager), install `mu-template@lh`. This is the preferred method because of the various dependencies.

    ```vim
    ActivateAddons mu-template@lh
    " And don't forget
    ActivateAddons stakeholders
    " don't forget also to support a few default snippets
    ActivateAddons lh-dev
    ```

  * or you can use [vim-flavor](https://github.com/kana/vim-flavor) that also
    supports dependencies

    ```
    flavor 'LucHermitte/mu-template'
    " And don't forget
    flavor 'tomtom/stakeholders_vim'
    " don't forget also to support a few default snippets
    flavor 'LucHermitte/lh-dev'
    ```

  * N.B.: installing [lh-cpp](http://github.com/LucHermitte/lh-cpp) or [lh-refactor](http://github.com/LucHermitte/lh-refactor) with VAM or vim-flavor will also install µTemplate.
  * or you can clone the git repositories
    ```bash
    git clone git@github.com:LucHermitte/lh-vim-lib.git
    git clone git@github.com:LucHermitte/lh-style.git
    git clone git@github.com:LucHermitte/lh-brackets.git
    git clone git@github.com:LucHermitte/mu-template.git
    # and don't forget:
    git clone git@github.com:tomtom/stakeholders_vim.git
    # don't forget also to support a few default snippets
    git clone git@github.com:LucHermitte/lh-dev.git
    ```

  * or with Vundle/NeoBundle:
    ```vim
    Bundle 'LucHermitte/lh-vim-lib'
    Bundle 'LucHermitte/lh-style'
    Bundle 'LucHermitte/lh-brackets'
    Bundle 'LucHermitte/mu-template'
    " and don't forget:
    Bundle 'tomtom/stakeholders_vim'
    " don't forget also to support a few default snippets
    Bundle 'LucHermitte/lh-dev'
    ```

### Note: regarding [COC](https://github.com/neoclide/coc.nvim)

Since v.4.4.0, µTemplate delegates the selection of its snippets to COC, when
COC is detected.

## Credits
  * Gergely Kontra is the author of the first version of µTemplate.
  * Luc Hermitte (LH) is the current maintainer of this enhanced version of mu-template.
  * Robert Kelly IV, Zdenek Sekera for their insight and the feedback they provided me (LH).
  * Troy Curtis Jr, for his intensive testing.

## See also
There are many other template-files loaders for Vim, see the [non exhaustive list of vim.wikia](http://vim.wikia.com/wiki/Category:Automated_Text_Insertion), or the [comparative matrix](http://vim-wiki.mawercer.de/wiki/topic/text-snippets-skeletons-templates.html) in Marc Weber's vim wiki.
