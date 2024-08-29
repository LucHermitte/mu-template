require 'tmpdir'
require 'vimrunner'
require 'vimrunner/rspec'
require 'support/vim'
require 'rspec/expectations'
require 'support/vim_matchers'
# require 'simplecov'

# SimpleCov.start

module Vimrunner
  class Client
    def runtime(script)
        script_path = Path.new(script)
        command("runtime #{script_path}")
    end

    def prepend_rtp(dir)
      dir_path = Path.new(dir)
      if File.directory?(dir_path)
        prepend_runtimepath(dir)
      else
        pp "Path #{dir_path} doesn't exist"
      end
    end
  end

  module Platform
    # For tests use in order of priority:
    # 1. gvim   -- when available
    # 2. vim    -- if possible
    # nvim is not compatible with vimrunner, let's ignore it now
    def best_vim
      prefered_vims.find { |vim| suitable?(vim) } or raise NoSuitableVimError
    end
    private

    def prefered_vims
      gvims + %w( vim )
    end
  end

end

Vimrunner::RSpec.configure do |config|
  # Use a single Vim instance for the test suite. Set to false to use an
  # instance per test (slower, but can be easier to manage).
  config.reuse_server = true

  vim_plugin_path = File.expand_path('.')
  vim_flavor_path   = ENV['HOME']+'/.vim/flavors'

  # Use different vimrc in order to see packages installed by vim-flavor
  vimrc = File.expand_path('../support/test.vimrc', __FILE__)

  # Decide how to start a Vim instance. In this block, an instance
  # should be spawned and set up with anything project-specific.
  config.start_vim do
    vim = Vimrunner::Server.new(:executable => Vimrunner::Platform.best_vim, :vimrc => vimrc).start
    vim.add_plugin(vim_flavor_path, 'bootstrap.vim')
    vim.prepend_runtimepath(vim_plugin_path+'/after')
    vim.prepend_runtimepath(vim_plugin_path)

    # lh-UT
    vim_UT_path      = File.expand_path('../../../vim-UT', __FILE__)
    vim.prepend_runtimepath(vim_UT_path)
    vim.runtime('plugin/UT.vim')

    # pp vim_flavor_path
    # lh-vim-lib
    vim_lib_path      = File.expand_path('../../../lh-vim-lib', __FILE__)
    vim.prepend_runtimepath(vim_lib_path)
    vim.runtime('plugin/let.vim') # LetIfUndef
    # vim.runtime('plugin/ui-functions.vim') # lh#ui#confirm
    # vim.command(':messages')

    # lh-style
    vim_style_path = File.expand_path('../../../lh-style', __FILE__)
    vim.prepend_runtimepath(vim_style_path)
    vim.runtime('plugin/lh-style.vim') # AddStyle

    # lh-brackets
    vim_brackets_path = File.expand_path('../../../lh-brackets', __FILE__)
    vim.prepend_runtimepath(vim_brackets_path)
    vim.runtime('plugin/misc_map.vim') # Inoreab
    vim.runtime('plugin/common_brackets.vim') # Brackets
    vim.runtime('plugin/bracketing.base.vim') # !mark!, !jump!

    # mu-template
    mu_template_path = File.expand_path('../../../mu-template@lh', __FILE__)
    vim.prepend_runtimepath(mu_template_path+'/after')
    vim.prepend_runtimepath(mu_template_path)
    vim.runtime('plugin/mu-template.vim')

    pp vim.echo('"RTP -> " . &rtp')

    has_redo = vim.echo('has("patch-7.4.849")')
    if has_redo != "1"
      puts "WARNING: this flavor of vim won't permit to support redo"
    end
    # The returned value is the Client available in the tests.
    vim
  end
end

RSpec.configure do |config|
  config.include Support::Vim

  def write_file(filename, contents)
    dirname = File.dirname(filename)
    FileUtils.mkdir_p dirname if not File.directory?(dirname)

    File.open(filename, 'w') { |f| f.write(contents) }
  end
end

# vim:set sw=2:
