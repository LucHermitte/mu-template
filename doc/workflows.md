# Typical workflows
* [Plugin Configuration](#plugin-configuration)
    * [For expanding a snippet](#for-expanding-a-snippet)
* [Snippet Expansion](#snippet-expansion)
* [Surrounding with a snippet](#surrounding-with-a-snippet)
* [Notes](#notes)
    * [The placeholders](#the-placeholders)
* [Filetype dependent templates for new files](#filetype-dependent-templates-for-new-files)

## Plugin Configuration
### For expanding a snippet
First of all, you need to remember the keybinding used to expand snippets, or chose one of your own. By default, snippet expansion is bound to `CTRL+R` then `TAB`. It can be changed into your `.vimrc` with for instance

```vim
" Overriding insert mode keybinding
imap <c-space>  <Plug>MuT_ckword
" Overriding visual mode keybinding
xmap <c-space>  <Plug>MuT_Surround
```

### For overriding snippets

See [below](#to-define-your-own-templates-or-even-override-the-default-templates).

----

## Snippet Expansion
... in INSERT mode

Let's say, you want to expand the `c/while` snippet in C or C++.

Type, in insert mode, any sequence of **consecutive** characters appearing (anywhere) in the name of the snippet you want to expand (or an empty space if you want to chose from every known snippets -- for the current filetype), and trigger snippet expansion.

IOW, you can have a white space before hitting `<c-r><tab>` (or whatever you chose), or `w`, or `wh`,... or `while` -- let's call it the _lead string_.

* If only one snippet matches, it's immediately expanded (like `if` in C and C++).
* If several snippets match, you can then type other characters from the snippet name to restrict the list of snippets shown.
    For instance, in C++, with [lh-cpp](https://github.com/LucHermitte/lh-cpp) installed,
    * If you type: `w` and then hit `<c-r><tab>`,  you'll see a list of 11 snippet names with a short description.
    * Hitting `e` will restrict the list to all snippets than contain in order the lead string (`w`), plus the typed characters (`e` here), which leaves `cpp/weak_ptr`, `while-getline` and `while`.
    * You can continue to restrict the selection by hitting more characters, or moving around with the cursors.
    * Select with `ENTER`, or `CTRL+Y`. Abort, with `ESCAPE`, `CTRL+E`...

There is a screencast in lh-cpp documentation: https://github.com/LucHermitte/lh-cpp/blob/master/doc/screencast-snippet-baseNV-class.gif

#### Note
At this time, there is a difference in behaviour between the _lead string_ and the characters typed afterward. `we<c-r><tab>` and `w<c-r><tab>e` won't give the same result. This is the choice I made, and that may change in the future.


----

## Surrounding with a snippet
... In VISUAL mode

Snippets can be used to surround anything.

Let's say, you want to surround the current selection with the `c/while` snippet in C or C++.

1. First, select what you wish to surround, possibly in a linewise fashion ([`:h linewise-visual`](http://vimhelp.appspot.com/visual.txt.html#linewise%2dvisual)),
2. Then, hit the snippet expanding keybinding for visual mode (`<c-r><tab>` by default)
3. At the prompt, type a sequence of characters that appears at the start the snippet name you want to expand
4. If several snippets match, you'll have to chose one through a confirm box -- depending on whether you are using vim, or gvim, or some other option the exact UI may change.

If you don't abort, the snippet will be expanded, and the first placeholder designated in the snippet will be replaced with the selection. In `c/while` case, the selection becomes the instructions looped over.

If you want to use the selection in another part of the snippet, given the snippet properly supports this, you'll have to type the number of the placeholder you'll have to be replaced with the selection before hitting the _expand_ keybinding. In `c/while` case, we can use something that will be used as the loop condition by typing 2 + `CTRL+R`+`TAB`


Unfortunately not all snippets are documented. I've started to document some of the C++ snippets in [lh-cpp](https://github.com/LucHermitte/lh-cpp/blob/master/doc/snippets.md).

In most cases, you'll have to edit the snippet to see what it does. It can be done with `:MUEdit`. Try for instance `:MUEdit c/while` (command-line expansion is supported).


----

## Notes
### The placeholders
They are mark(er)s where the cursor can jump to. They are described in [lh-brackets](https://github.com/LucHermitte/lh-brackets) documentation.

By default, when the cursor jumps to a placeholder, this placeholder gets selected in [SELECT-mode](http://vimhelp.appspot.com/visual.txt.html#Select%2dmode). Meaning, that everything we start typing is directly inserted in place of the placeholder text.

If several placeholders have the same name, `«cond»`, they will all get replaced simultaneously as we type if and only if [tomtom/stakeholders_vim](https://github.com/tomtom/stakeholders_vim) is installed.

IIRC, jumping from one placeholder to the next is described in [`:h markers`](https://github.com/LucHermitte/lh-brackets/blob/master/doc/lh-map-tools.txt#L462)

#### Note
The placeholder technology used in mu-template is one of the oldest in Vim ecosystem. It may seem less attractive than the ones from other plugins as the French quote characters appear. This is the one that has been introduced later on in latex-suite.

So far, I'm keeping these marker characters as they easily permit to jump forth, and back!

----

## Filetype dependent templates for new files

Before being a snippet engine, µTemplate was a template file expander. IOW,
everytime we open a new file, a default skeleton is expanded.

There is not much to do, this is automatic.

Yet, you may wish:

## to inhibit this feature
Add in your `.vimrc`

```vim
let g:mt_IDontWantTemplatesAutomaticallyInserted = 1
```

## to trigger the feature on explicit demand
Be sure to be in the buffer you want to fill with a skeleton. and type in the
command line:

```vim
:MuTemplate
```

Note that you'll probably want to purge the buffer content with `:%d`.

Note that `:MuTemplate c/while` will expand the `c/while` snippet at cursor
position.

## to define your own templates, or even override the default templates

New templates for the filetype `{ft}` are meant to be dropped in:

- `$HOME/.vim/template/{ft}.template` to define or override globally the template
  for this filetype.
- `{prj}/template/{ft}.template` to define or override the template for this
  filetype in the restricted context of a current project.
  In that case, we need to assign the value `"{prj}"` to the variable `(bpg):mt_templates_paths`. See [lh-vim-lib documentation on project variables](https://github.com/LucHermitte/lh-vim-lib/blob/master/doc/Options.md#project-options).

    ```vim
    " From a local vimrc
    let b:mt_templates_paths = "{prj}"
    " Or if we use lh-vim-lib Project feature, still from a local vimrc
    LetTo p:mt_templates_paths = "{prj}"
    ```

See `:h MuT-paths` for more details.

### Edit an existing template file
If a template file already exists you can edit it with `:MUEdit` command that
supports command-line completion.

```vim
:MuEdit {ft}
" or for snippets
:MuEdit {ft}/{snippet}
```

In all cases, avoid to change the template files I ship with µTemplate as they
are likelly to be overridden the next time you update your installed version.

Instead, you'll often observe _variation-points_ meants to be overriden. The
variation-points are just other template files that are included and that can
be overridden.

Regarding µTemplate syntax for the template-files, see
[its documentation](mu-template.txt), or the various
[shipped template files](../after/template/).
You'll find ever more advanced and complex examples in
[lh-cpp](https://github.com/LucHermitte/lh-cpp).
