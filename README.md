# order-driver-assignment-api

This project is a sample RESTful API made with **Ruby** and **Sinatra**. It makes a simple order-driver assignment based on some rules:

```
- The web service accepts lists of driver objects and order objects, in JSON.
- Drivers have a name and a current location.
- Orders have a name, an origin location, a destination location and an indication of size (large or small.)
```

To do the **order-driver mapping** the service follows some rules:

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

This will run a server in your local machine running on port ***9292*** . ```http://localhost:9292```
