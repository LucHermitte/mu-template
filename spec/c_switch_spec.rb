# encoding: UTF-8
require 'spec_helper'
require 'pp'

# =====[ switch ]===== {{{1
RSpec.describe "C switch-case snippets", :c, :switch do
  let (:filename) { "test.c" }

  # ====[ Executed once before all test {{{2
  before :all do
    if !defined? vim.runtime
        vim.define_singleton_method(:runtime) do |path|
            self.command("runtime #{path}")
        end
    end
    vim.runtime('spec/support/input-mock.vim')
    expect(vim.command('verbose function lh#ui#input')).to match(/input-mock.vim/)
    expect(vim.echo('lh#mut#dirs#get_templates_for("c/switch")')).to match(/switch.template/)
  end

  # ====[ Always executed before each test {{{2
  before :each do
    vim.command('filetype plugin on')
    vim.command("file #{filename}")
    vim.set('ft=c')
    vim.set('expandtab')
    vim.set('sw=4')
    vim.command('imap <tab> <Plug>MuT_ckword')
    clear_buffer
    expect(vim.echo('&ft')).to match(/c/)
    expect(vim.echo('mapcheck("<Plug>MuT_ckword", "i")')).to match(/lh#mut#search_templates/)

    vim.command('let g:mocked_input = 42')
    expect(vim.echo('lh#ui#input("toto")')).to eq '42'
    expect(vim.echo('lh#style#clear()')).to eq '0'
  end

  # ==========[ :MuTemplate {{{2
  specify "inserted with ':MuTemplate', no brackets", :cmd_mut do
    vim.command('let g:mocked_input = 0')
    expect(vim.echo('lh#ui#input("toto")')).to eq '0'
    # Set K&R/Stroustrup style
    vim.command('UseStyle breakbeforebraces=stroustrup -ft=c')
    vim.command('UseStyle spacesbeforeparens=control-statements -ft=c')
    vim.command('UseStyle empty_braces=nl -ft=c')
    vim.command('MuTemplate c/switch')
    assert_buffer_contents <<-EOF
    switch («expr») {
        case «case»:
            «case-code»;
            break;
        default:
            «default-code»;
            break;
    }
    «»
    EOF
  end

  specify "inserted with ':MuTemplate un deux trois', no brackets", :cmd_mut, :params do
    vim.command('let g:mocked_input = 0')
    expect(vim.echo('lh#ui#input("toto")')).to eq '0'
    # Set K&R/Stroustrup style
    vim.command('UseStyle breakbeforebraces=stroustrup -ft=c')
    vim.command('UseStyle spacesbeforeparens=control-statements -ft=c')
    vim.command('MuTemplate c/switch un deux trois')
    assert_buffer_contents <<-EOF
    switch («expr») {
        case un:
            «un-code»;
            break;
        case deux:
            «deux-code»;
            break;
        case trois:
            «trois-code»;
            break;
        default:
            «default-code»;
            break;
    }
    «»
    EOF
  end

  specify "inserted with ':MuTemplate un deux trois', w/ brackets", :cmd_mut, :param do
    vim.command('let g:mocked_input = 1')
    expect(vim.echo('lh#ui#input("toto")')).to eq '1'
    # Set Allman style
    vim.command('UseStyle breakbeforebraces=allman -ft=c')
    vim.command('UseStyle spacesbeforeparens=control-statements -ft=c')
    vim.command('MuTemplate c/switch un deux trois')

    assert_buffer_contents <<-EOF
    switch («expr»)
    {
        case un:
            {
                «un-code»;
                break;
            }
        case deux:
            {
                «deux-code»;
                break;
            }
        case trois:
            {
                «trois-code»;
                break;
            }
        default:
            {
                «default-code»;
                break;
            }
    }
    «»
    EOF
  end

  specify "inserted with ':MuTemplate', w/ brackets", :cmd_mut do
    vim.command('let g:mocked_input = 1')
    expect(vim.echo('lh#ui#input("toto")')).to eq '1'
    # Set Allman style
    vim.command('UseStyle breakbeforebraces=allman -ft=c')
    vim.command('UseStyle spacesbeforeparens=control-statements -ft=c')
    vim.command('MuTemplate c/switch')

    assert_buffer_contents <<-EOF
    switch («expr»)
    {
        case «case»:
            {
                «case-code»;
                break;
            }
        default:
            {
                «default-code»;
                break;
            }
    }
    «»
    EOF
  end

  # ==========[ lh#mut#expand_and_jump {{{2
  specify "inserted with 'call lh#mut#expand_and_jump(no_use_block, f(42))', no brackets", :fn_mut do
    vim.command('silent! unlet g:mocked_input = 0') # don't need it
    # Set K&R/Stroustrup style
    vim.command('UseStyle breakbeforebraces=Stroustrup -ft=c')
    vim.command('UseStyle spacesbeforeparens=control-statements -ft=c')
    vim.command('call lh#mut#expand_and_jump(0, "c/switch", {"use_blocks":0, "expr": "f(42)"})')
    assert_buffer_contents <<-EOF
    switch (f(42)) {
        case «case»:
            «case-code»;
            break;
        default:
            «default-code»;
            break;
    }
    «»
    EOF
  end

  specify "inserted with 'call lh#mut#expand_and_jump(no_use_block, f(42), [1,2,3])', no brackets", :fn_mut, :param do
    vim.command('silent! unlet g:mocked_input = 0') # don't need it
    # Set K&R/Stroustrup style
    vim.command('UseStyle breakbeforebraces=Stroustrup -ft=c')
    vim.command('UseStyle spacesbeforeparens=control-statements -ft=c')
    vim.command('call lh#mut#expand_and_jump(0, "c/switch", {"values": ["un", "deux", "trois"], "use_blocks":0, "expr": "f(42)"})')
    assert_buffer_contents <<-EOF
    switch (f(42)) {
        case un:
            «un-code»;
            break;
        case deux:
            «deux-code»;
            break;
        case trois:
            «trois-code»;
            break;
        default:
            «default-code»;
            break;
    }
    «»
    EOF
  end

  specify "inserted with 'call lh#mut#expand_and_jump(use_block, f(42), [1,2,3])', w/ brackets", :fn_mut, :param do
    vim.command('silent! unlet g:mocked_input = 0') # don't need it
    # Set Allman style
    vim.command('UseStyle breakbeforebraces=Allman -ft=c')
    vim.command('UseStyle spacesbeforeparens=control-statements -ft=c')
    vim.command('call lh#mut#expand_and_jump(0, "c/switch", {"values": ["un", "deux", "trois"], "use_blocks":1, "expr": "f(42)"})')
    assert_buffer_contents <<-EOF
    switch (f(42))
    {
        case un:
            {
                «un-code»;
                break;
            }
        case deux:
            {
                «deux-code»;
                break;
            }
        case trois:
            {
                «trois-code»;
                break;
            }
        default:
            {
                «default-code»;
                break;
            }
    }
    «»
    EOF
  end

end

# }}}1
# vim: set sw=2:fdm=marker:
