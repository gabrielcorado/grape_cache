# Helper
require 'spec_helper'

# Create a Grape API application
class Application < Grape::API
  # Add the Middleware
  # insert_after Grape::Middleware::Formatter, GrapeCache::Middleware, store: CacheStore.new
  use GrapeCache::Middleware, store: CacheStore.new

  # Set the format
  format :json

  # Simple Route
  params do
    optional :break, default: true
  end
  get '/simple', cache: true do
    { hello: 'Route', time: Time.now }
  end

  #
  resource :sub do
    get '/simple', cache: true do
      { hello: 'Sub', time: Time.now }
    end
  end

  # Post request
  post '/post', cache: true do
    { hello: 'Sub', time: Time.now }
  end
end

# Class test
describe GrapeCache::Middleware do
  # Create a Grape app
  let(:app) { Application.new }

  #
  it 'should generate the cache for a simple text view' do
    # Execute the route
    get '/simple'

    # Get it infos
    first = MultiJson.load last_response.body
    expect(first['time']).to eq(Time.now.to_s)

    # Sleep...
    sleep 2

    # Sub Route
    get '/sub/simple', hello: 'Test'
    expect(MultiJson.load(last_response.body)['time']).to eq(Time.now.to_s)

    # Sleep...
    sleep 2

    # Cached response
    get '/simple'
    expect(MultiJson.load(last_response.body)['time']).to eq(first['time'])

    # Sleep...
    sleep 2

    # Test a Post request
    post '/post', {hello: 'Test'}.to_json, 'CONTENT_TYPE' => 'application/json'
    first_post = MultiJson.load(last_response.body)
    expect(first_post['time']).to eq(Time.now.to_s)

    # Sleep...
    sleep 2

    # Test a Post request
    post '/post', {hello: 'Test'}.to_json, 'CONTENT_TYPE' => 'application/json'
    expect(MultiJson.load(last_response.body)['time']).to eq(first_post['time'])

    # Sleep...
    sleep 2

    # Execute the route
    get '/simple', break: true

    # Get it infos
    expect(MultiJson.load(last_response.body)['time']).to eq(Time.now.to_s)
  end
end
