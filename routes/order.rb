$LOAD_PATH << File.dirname(__FILE__)

require 'haversine'
require 'driver'

get '/order' do
  content_type :json
  order = Order.all()

  order.to_json
end


post '/order' do
  content_type :json
  param = JSON.parse(request.body.read)
  order = save_order(param)
  order.to_json
end

def save_order(order_param)
  order = Order.new(order_param)
  if order.save
    order
  else
    halt 500
  end
end

post '/orders' do
  content_type :json
  params_json = JSON.parse(request.body.read)
  orders = Array.new 
  params_json.each do | param |
    orders.push(save_order(param))
  end
  orders.to_json
end

get '/order/:id' do
  content_type :json
  order = Order.get(params[:id].to_i)

  if order
    order.to_json
  else
    halt 404
  end
end


put '/order/:id' do
  content_type :json
  params_json = JSON.parse(request.body.read)
  order = Order.get(params[:id].to_i)
  order.update(params_json)

  if order.save
    order.to_json
  else
    halt 500
  end
end

delete '/order/:id' do
  content_type :json
  order = Order.get(params[:id].to_i)

  if order.destroy
    {:success => "ok"}.to_json
  else
    halt 500
  end
end

get '/order/:id/availableDrivers' do
  content_type :json
  order = Order.get(params[:id].to_i)
  validate_available_drivers_request(order)
  drivers = retrieve_not_busy_drivers(order)
  filtered_drivers = filter_drivers_by_distance(order, drivers)
  filtered_drivers.to_json(methods: [ :orders ])
end

def validate_available_drivers_request(order)
  unless order.driver_id.nil?
    halt 412, %q[{"Error" : "Order already has a driver"}]
  end
end

def filter_drivers_by_distance(order, drivers)
  filtered_drivers = Array.new
  drivers.each do |driver|
    unless driver.latitude.nil? || driver.longitude.nil?
      distance = Haversine.distance(order.origin_latitude, order.origin_longitude, driver.latitude, driver.longitude)
      if distance.to_miles <= 5
        puts "Distance From Driver #{driver.name} to Order #{order.name}: #{distance.to_miles} miles"
        filtered_drivers << driver
      end
    end
  end
  filtered_drivers
end

def retrieve_not_busy_drivers(order)
  large_order = Order.new
  large_order.size = 'large'

  if(order.size == large_order.size)
    driver_ids = retrieve_driver_ids_with_no_orders
  else
    driver_ids = retrieve_driver_ids_with_less_than_three_orders_and_no_large_order
  end
  Driver.all(:id => driver_ids)
end

def retrieve_driver_ids_with_no_orders
  repository(:default).adapter.select(%q[
  SELECT distinct(d.id) FROM DRIVERS d
  WHERE (SELECT COUNT(*) FROM ORDERS where driver_id = d.id) = 0])
end

def retrieve_driver_ids_with_less_than_three_orders_and_no_large_order
  repository(:default).adapter.select(%q[
      SELECT distinct(d.id) FROM DRIVERS d
      WHERE (SELECT COUNT(*) FROM ORDERS where driver_id = d.id) < 3 AND
      NOT EXISTS (SELECT * from ORDERS o where driver_id = d.id AND o.size = 2)])
end

