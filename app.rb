require 'bundler'
require 'fileutils'
require 'yaml'

Bundler.require

Dir['./lib/*.rb'].each { |file| require file }

gui = Gui.new
gui.start
=begin
get '/process' do
  @info = apply_rules(@info)
  set_library_path(@info, params[:library])
  rip_disc(@info[:titles])

  slim :search
end

Library.new(@info, title).add
=end
