# Spec dependencies
require 'grape_cache'
require 'grape'
require 'rack/test'

# Configure the RSpec
RSpec.configure do |config|
  config.order = 'random'
  config.seed = '12345'
  config.include Rack::Test::Methods
end

# Define a Store
class CacheStore
  # Storage
  attr_reader :storage

  # Initialize
  def initialize
    @storage = {}
  end

  #
  def write(key, value, options)
    @storage[key] = value
  end

  #
  def read(key)
    @storage[key]
  end

  # Exist?
  def exist?(key)
    @storage.key?(key)
  end
end
