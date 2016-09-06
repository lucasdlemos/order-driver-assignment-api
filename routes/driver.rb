require 'order'

get '/driver' do
  content_type :json
  driver = Driver.all()

  driver.to_json(methods: [ :orders ])
end

post '/driver' do
  content_type :json
  param = JSON.parse(request.body.read)
  driver = save_driver(param)
  driver.to_json(methods: [ :orders ])
end

def save_driver(driver_param)
  driver = Driver.new(driver_param)
  if driver.save
    driver
  else
    halt 500
  end
end

post '/drivers' do
  content_type :json
  params_json = JSON.parse(request.body.read)
  drivers = Array.new 
  params_json.each do | param |
    drivers.push(save_driver(param))
  end
  drivers.to_json(methods: [ :orders ])
end

get '/driver/:id' do
  content_type :json
  driver = Driver.get(params[:id].to_i)

  if driver
    driver.to_json(methods: [ :orders ])
  else
    halt 404
  end
end

put '/driver/:id' do
  content_type :json
  params_json = JSON.parse(request.body.read)
  driver = Driver.get(params[:id].to_i)
  driver.update(params_json)

  if driver.save
    driver.to_json(methods: [ :orders ])
  else
    halt 500
  end
end

delete '/driver/:id' do
  content_type :json
  driver = Driver.get(params[:id].to_i)

  if driver.destroy
    {:success => "ok"}.to_json
  else
    halt 500
  end
end

get '/driver/:driverId/assignOrder/:orderId' do
  content_type :json
  driver = Driver.get(params[:driverId].to_i)
  order = Order.get(params[:orderId].to_i)

  if assign_order(driver, order)
    driver.to_json(methods: [ :orders ])
  else
    halt 500
  end
end

def assign_order(driver, order)
  order.driver_id = driver.id
  driver.orders << order
  order.save
end

get '/driver/:driverId/removeOrder/:orderId' do
  content_type :json
  driver = Driver.get(params[:driverId].to_i)
  order = Order.get(params[:orderId].to_i)
  driver.orders.delete(order)
  order.driver_id = nil

  if order.save
    driver.to_json(methods: [ :orders ])
  else
    halt 500
  end
end

get '/driver/availableForOrder/:order_id' do
  content_type :json
  order = Order.get(params[:order_id].to_i)
  validate_available_drivers_request(order)
  drivers = retrieve_not_busy_drivers(order)
  filtered_drivers = filter_drivers_by_distance(order, drivers)
  filtered_drivers.to_json(methods: [ :orders ])
end

get '/drivers/pairWithOrders' do
  content_type :json
  orders = Order.all(:driver_id => nil, :order => [ :created_at.asc ])
  orders.each do |order|
    drivers = retrieve_not_busy_drivers(order)
    filtered_drivers = filter_drivers_by_distance(order, drivers)
    unless drivers.empty?
      assign_nearest(order, filtered_drivers)
    end
  end
  {:success => "ok"}.to_json
end


def assign_nearest(order, drivers)
  nearest_driver = get_nearest_driver(order, drivers)
  assign_order(nearest_driver, order)
end

def get_nearest_driver(order,drivers)
  nearest_distance = 5
  nearest_driver = Driver.new
  drivers.each do |driver|
    distance = Haversine.distance(order.origin_latitude, order.origin_longitude, driver.latitude, driver.longitude)
    if(distance.to_miles < nearest_distance)
      nearest_distance = distance.to_miles
      nearest_driver = driver
    end
  end
  nearest_driver
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


