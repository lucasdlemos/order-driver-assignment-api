$LOAD_PATH << File.dirname(__FILE__)
# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.
require 'bundler'
# require 'models/driver'
Bundler.require

class MyApp < Sinatra::Application
  enable :sessions

  configure :production do
    set :haml, { :ugly=>true }
    set :clean_trace, true
  end

  configure :development do
    # ...
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
end

require_relative 'models/init'
require_relative 'routes/init'

  get '/' do
    "Order Driver Assignment API"
  end