# encoding: UTF-8
require 'spec_helper'
require 'pp'


RSpec.describe "check dependencies are loaded", :deps do
  let (:filename) { "test.py" }

  before :each do
    vim.command('filetype plugin on')
    vim.command("file #{filename}")
    vim.set('expandtab')
    vim.set('sw=4')
    clear_buffer
  end

  it "has loaded MuT plugin" do
    # pp vim.echo('&rtp')
    # pp vim.command(':scriptnames')
    expect(/plugin.mu-template\.vim/).to be_sourced
    # expect(/ftplugin.cpp.cpp_snippets\.vim/).to be_sourced
    vim.command('call lh#mut#dirs#update()')
    # pp vim.echo('g:lh#mut#dirs#cache')
  end

end
