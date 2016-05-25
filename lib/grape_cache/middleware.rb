#
module GrapeCache
  # Middleware Class
  class Middleware < Grape::Middleware::Base
    # Overwriting the method call! from Grape::Middleware::Base
    # Reason: Make the :before call to return the whole stack
		def call!(env)
			@env = env
      # Just here is moving!
      before_res = before
      return before_res unless before_res.nil?
      # end the overwrite
			begin
				@app_response = @app.call(@env)
			ensure
				begin
					after_response = after
				rescue StandardError => e
					warn "caught error of type #{e.class} in after callback inside #{self.class.name} : #{e.message}"
					raise e
				end
			end

			response = after_response || @app_response
			merge_headers response
			response
		end

    #
    def after
      # Check if cache is enabled in this route
      return unless cache?

      # Cache its output
      store.write key(@params), response, @options.fetch(:options, {}).merge(endpoint.options.fetch(:options, {}))

      # Do not change the return
      return
    end

    # Generate the cache if its necessary
    def before
      # Check if cache is enabled in this route
      return unless cache?

      # Generate the cache key
      k = key(params)

      # Check the current key exists in the cache
      return unless store.exist?(k)

      # Get to the response it
      res = MultiJson.load store.read(k)

      # Return in the Rack Formatt
      [res['status'], res['headers'], res['body']]
    end

    private

    # Check if the current route has cache
    def cache?
      endpoint.options.fetch(:route_options, {}).fetch(:cache, false)
    end

    # Cache store
    def store
      # Check if Store was defined
      raise 'Cache Store have to be defined' if @options[:store].nil?

      # Return it
      @options[:store]
    end

    # Cache key
    def key(opts)
      # Get the namespace
      ns = namespace

      # Default prefix: `grape_cache`
      res = "grape_cache/#{digest(route)}/#{digest(opts)}"

      # Add the namespace (if its necessary)
      "#{ns}/#{res}" if ns.nil?

      # Return the result
      res
    end

    # Get the namespace
    def namespace
      # Check if its nil
      return nil if @options[:namespace].nil?

      # Call it if it's a Proc
      @options[:namespace].proc? ? @options[:namespace].call : @options[:namespace]
    end

    # Route
    def route
      "#{endpoint.route.options[:method]} #{endpoint.route.pattern.path}"
    end

    # Transform the reponse into JSON
    def response
      # Dump it to JSON
      MultiJson.dump({
        status: @app_response.status,
        headers: @app_response.headers,
        body: @app_response.body
      })
    end

    # Digest the params
    def digest(params)
      # Dump the params
      dump = Marshal::dump(params)

      # Disgest the params
      Digest::MD5.hexdigest dump
    end

    # Endpoint params
    # Get the input passed and the QueryString
    def params
      # endpoint.declared(endpoint.params)
      @params = "#{env['QUERY_STRING']}_#{env[Grape::Env::RACK_INPUT].read}"
    end

    # Request
    def request
      @request ||= Rack::Request.new(env)
    end

    # Access the endpoint
    def endpoint
      env['api.endpoint']
    end
  end
end
