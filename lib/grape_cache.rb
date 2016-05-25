# Initialize the module
module GrapeCache
end

# Dependencies
require 'grape'
require 'grape/middleware/formatter'
require 'digest/md5'
require 'oj'
require 'multi_json'

# Modules
require 'grape_cache/middleware'
