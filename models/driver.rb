$LOAD_PATH << File.dirname(__FILE__)

require 'bundler'
require 'order'
require 'dm-validations'
Bundler.require

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite")

class Driver
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :name, String, :length => 255, :required => true
  property :latitude, Float
  property :longitude, Float

  has n, :orders

  validates_with_method :check_orders

  def check_orders
  	saved_orders = self.orders.length
  	puts saved_orders 
  	if saved_orders > 3
  		return [false, "Cannot assign more than 3 orders"]
  	else
  		return true
  	end
  end

end