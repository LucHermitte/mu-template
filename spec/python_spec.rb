# encoding: UTF-8
require 'spec_helper'
require 'pp'

RSpec.describe "Python snippets", :python do
  let (:filename) { "test.py" }

  before :each do
    vim.command('filetype plugin on')
    vim.command("file #{filename}")
    vim.set('ft=python')
    vim.set('expandtab')
    vim.set('sw=4')
    vim.command('imap <tab> <Plug>MuT_ckword')
    clear_buffer
    expect(vim.echo('lh#mut#dirs#get_templates_for("python/if")')).to match(/if.template/)
    expect(vim.echo('&ft')).to match(/python/)
    expect(vim.echo('mapcheck("<Plug>MuT_ckword", "i")')).to match(/lh#mut#search_templates/)
  end

  specify "if inserted with :MuTemplate", :if do
    vim.command('MuTemplate python/if')
    assert_buffer_contents <<-EOF
    if «condition»:
        «code»
    «»
    EOF
  end

  specify "else inserted with :MuTemplate", :else do
    vim.command('MuTemplate python/else')
    assert_buffer_contents <<-EOF
    else :
        «code»
    «»
    EOF
  end

  specify "if-else inserted from insert mode", :ifelse do
    vim.command('MuTemplate python/ifelse')
    assert_buffer_contents <<-EOF
    if «condition»:
        «code-if»
    «»
    else :
        «code-else»
    «»
    EOF
  end

  specify "while inserted with :MuTemplate", :while do
    vim.command('MuTemplate python/while')
    assert_buffer_contents <<-EOF
    while «condition»:
        «code»
    «»
    EOF
  end

  specify "def inserted with :MuTemplate", :def do
    vim.command('MuTemplate python/def')
    assert_buffer_contents <<-EOF
    def «name»(«params»):
        """
        «doc»
        """
        «pass»
    «»
    EOF
  end

  specify "with inserted with :MuTemplate", :with do
    vim.command('MuTemplate python/with')
    assert_buffer_contents <<-EOF
    with «expression» as «var»:
        «code»
    «»
    EOF
  end

  specify "class inserted class :MuTemplate", :class do
    vim.command('MuTemplate python/class')
    assert_buffer_contents <<-EOF
    class «Test»:
        """
        «class documentation»
        """

        def __init__(self, «params»):
            """
            constructor
            """
            «pass»
        «»
    «»
    EOF
  end

end
# vim: set sw=2:
