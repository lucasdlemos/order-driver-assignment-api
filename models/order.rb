$LOAD_PATH << File.dirname(__FILE__)

require 'bundler'
require 'driver'
Bundler.require

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite")

class Order
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :name, String, :length => 255, :required => true
  property :origin_latitude, Float
  property :origin_longitude, Float
  property :destination_latitude, Float
  property :destination_longitude, Float
  property :size, Enum[ :small, :large], :default => :small
  property :created_at, Time, :required => true

  belongs_to :driver, :required => false
end