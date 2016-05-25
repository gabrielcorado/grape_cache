# Grape Cache
```
+-----------+     Cached?
|  Request  +------------------+
+-----------+                  |
                               |
                               |
                               v
+-----------+     No     +-----+-----+
| API Call  +<-----------+   Cache   |
+-----+-----+            +-----+-----+
      |                        |
      |                        |
      v                        |
+-----+-----+     Yes          |
| Response  +<-----------------+
+-----------+
```

## How it works
The module generates a key based on the Grape Route(METHOD + PATH) and the current params
(HTTP BODY + QUERY STRINGS) and set the result of the API Call to this key.
When another request with exacly same attributes that will generate the same key again,
it does not call the API again, it just return the last response.

## Usage
```ruby
# Add the Middleware into your API class
# In the middleware definition you have to specify the
# store used by the middleware, also you could pass the
# params for this store like `:expires_in`
class Application < Grape::API
  use GrapeCache, store: Rails.cache, options: { expires_in: 1.hour }
end

# After this just simply set your routes with a cache flag
get '/hello/cache', cache: true do
  { hello: 'From cache' }
end

# To use it with a shared cache env you could use the flag `:namespace`
# to define it. In this case I'll use the Apartment as example.
use GrapeCache, store: Rails.cache, namespace: -> { Apartment::Tenant.current }
```

## Development
* Building the docker container: `docker build -t grape-cache .`
* Running the tests:
  * With volume: `docker run --rm -it -v (PWD):/app grape-cache bundle exec rspec`
  * Without volume: `docker run --rm -it grape-cache bundle exec rspec`
