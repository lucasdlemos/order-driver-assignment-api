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
  order.created_at = Time.now
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

