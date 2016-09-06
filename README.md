# order-driver-assignment-api

This project is a sample RESTful API made with **Ruby** and **Sinatra**. It makes a simple order-driver assignment.

```
- The web service accepts lists of driver objects and order objects, in JSON.
- Drivers have a name and a current location.
- Orders have a name, an origin location, a destination location and an indication of size (large or small.)
```

To do the **order-driver mapping** the service must consider the following rules

```
- A driver shouldn’t be paired with any order that is to be picked up more than five miles from their current location.
- If a driver is assigned to a large order, they can carry no additional orders.
- A driver can carry no more than three orders.
```

## Getting Started

Let's make the web service up and running.

1. Clone this repository

  ```
  git clone git@github.com:lucasdlemos/order-driver-assignment-api.git
  ```

2. Install [RVM](https://rvm.io/rvm/install/)

3. Install the gem's . Open you terminal at the repository folder and run:

  ```
  gem install bundler
  bundle install --without production
  ```

4. Get the server up. Run the command

  ```
  bundle exec rackup
  ```

This will run a server in your local machine running on port ***9292*** . `http://localhost:9292`

## Available Calls

This section explains how to use the API describing the available calls and giving some examples of how to use them. The model is composed by two entities: **driver** and **order**.

### Create an Entity

  ```
  http://localhost:9292/{entity}  HTTP Method: POST
  
  The entity's JSON must be at the body.
  ```

### Create a batch of entities
  
  ```
  http://localhost:9292/{entity}s  HTTP Method: POST
  
  The JSON with an Array of entities must be at the body.
  ```
  
### Update an entity

  ```
  http://localhost:9292/{entity}/{entityId}  HTTP Method: PUT
  
  The entire entity's JSON, including it's id, with the changed data must be at the body
  ```
### Delete an entity
  
  ```
  http://localhost:9292/{entity}/{id}  HTTP Method: DELETE
  ```
  
### Get all entities

  ```
  http://localhost:9292/{entity}  HTTP Method: GET
  ```
  
### Get an specific entity

  ```
  http://localhost:9292/{entity}/{entityId}  HTTP Method: GET
  ```
  
### See all the drivers available to pick an specific order, according to the API rules

  ```
  http://localhost:9292/driver/availableForOrder/{orderId}  HTTP Method: GET
  ```
  
### Assign a driver to an order

  ```
  http://localhost:9292/driver/{driverId}/assignOrder/{orderId}  HTTP Method: GET
  ```
  
### Unassign a driver to an order

  ```
  http://localhost:9292/driver/{driverId}/removeOrder/{orderId}  HTTP Method: GET
  ```
  
### Automatically pair driver and orders, according to the API rules

  ```
  http://localhost:9292/driver/pairWithOrders  HTTP Method: GET
  ```
  
## Test Case

Let's see an example of how the API works. We will create some orders, drivers, assign drivers to orders and call the automatic order-driver pairing.

### Creating Orders

Let's create three small orders and one large order:

  ```
  URL: http://localhost:9292/orders  HTTP Method: POST
  
  Body:
  [
    {
      "name": "Two Pizzas",
      "size": "small",
      "origin_latitude": -22.966792,
      "origin_longitude": -43.182993,
      "destination_latitude": -22.956242,
      "destination_longitude": -43.181255
    },
    {
      "name": "One Burguer",
      "size": "small",
      "origin_latitude": -22.958985,
      "origin_longitude": -43.200718,
      "destination_latitude": -22.956242,
      "destination_longitude": -43.181255
    },
    {
      "name": "Ten Pizzas",
      "size": "large",
      "origin_latitude": -22.953623,
      "origin_longitude": -43.183788,
      "destination_latitude": -22.956242,
      "destination_longitude": -43.181255
    },
    {
      "name": "Four Sandwiches",
      "size": "small",
      "origin_latitude": -22.966033,
      "origin_longitude": -43.175427,
      "destination_latitude": -22.956242,
      "destination_longitude": -43.181255
    },
    {
      "name": "Two Salads - Far",
      "size": "small",
      "origin_latitude": -22.895442,
      "origin_longitude": -43.261546,
      "destination_latitude": -22.956242,
      "destination_longitude": -43.181255
    }
  ]
  ```

Try to make this request using curl:

  ```
  echo '[{"name":"Two Pizzas","size":"small","origin_latitude":-22.966792,"origin_longitude":-43.182993,"destination_latitude":-22.956242,"destination_longitude":-43.181255},{"name":"One Burguer","size":"small","origin_latitude":-22.958985,"origin_longitude":-43.200718,"destination_latitude":-22.956242,"destination_longitude":-43.181255},{"name":"Ten Pizzas","size":"large","origin_latitude":-22.953623,"origin_longitude":-43.183788,"destination_latitude":-22.956242,"destination_longitude":-43.181255},{"name":"Four Sandwiches","size":"small","origin_latitude":-22.966033,"origin_longitude":-43.175427,"destination_latitude":-22.956242,"destination_longitude":-43.181255},{"name":"Two Salads","size":"small","origin_latitude":-22.895442,"origin_longitude":-43.261546,"destination_latitude":-22.956242,"destination_longitude":-43.181255}]' | curl -d @- http://localhost:9292/orders --header "Content-Type:application/json"  
  ```
  
### Creating Drivers

Let's create two drivers

  ```
  URL: http://localhost:9292/orders  HTTP Method: POST
  
  Body
  [
    {
      "name" : "Lucas",
      "latitude" : -22.964245,
      "longitude" : -43.177305
    },
    {
      "name" : "John",
      "latitude" : -22.965863,
      "longitude" : -43.183637
    }
  ]
  ```
Try to make this request using curl

  ```
  echo '[{"name":"Lucas","latitude":-22.964245,"longitude":-43.177305},{"name":"John","latitude":-22.965863,"longitude":-43.183637}]' | curl -d @- http://localhost:9292/drivers --header "Content-Type:application/json"
  ```

### Retrieving available drivers for an order

According to the API rules described on the first session there are some rules to consider a **Driver** as available to pick an **Order**. Let's see which drivers are available to pick the first order:

  ```
  URL: http://localhost:9292/driver/availableForOrder/1  HTTP Method: GET
  ```

Try to make this request using curl

  ```
  curl http://localhost:9292/driver/availableForOrder/1
  ```

Based on the order-driver mapping algorithm this call must return both drivers Lucas and John as available do pick the order 1.
  
### Assigning an order to a driver

Now we know that Lucas and John are available to pick the first order, let's assign the driver 'Lucas' to it.

  ```
  URL: http://localhost:9292/driver/1/assignOrder/1  HTTP Method: GET
  ```
Try to make this request using curl

  ```
  curl http://localhost:9292/driver/1/assignOrder/1
  ```
  
### Removing an order from a driver

Imagine the driver Lucas wants to reject the first order, so let's remove it.

  ```
  URL: http://localhost:9292/driver/1/removeOrder/1  HTTP Method: GET
  ```

Try to make this request using curl

  ```
  curl http://localhost:9292/driver/1/removeOrder/1
  ```
  
### Automatically distribute orders to drivers
  
If we want the service to automatically distribute the orders to their available drivers according to it's algorithm, make this call:
  
  ```
  URL: http://localhost:9292/drivers/pairWithOrders  HTTP Method: GET
  ```
Try to make this request using curl

  ```
  curl http://localhost:9292/drivers/pairWithOrders
  ```

The algorithm maps available drivers for each order, prioritizing the oldest.
  
### See the final mapping
  
Now we have asked the service to automatically map drivers and orders, let's see the result:

  ```
  curl http://localhost:9292/driver
  ```

This call must return the driver Lucas paired with the large order (Ten Pizzas) and the driver John paired with the other 3 orders.
