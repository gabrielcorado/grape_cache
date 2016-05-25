# Ruby image
FROM ruby

# Install bundler
RUN gem install bundler --no-ri --no-rdoc

# Make app folder
RUN mkdir app/

# Set as workdir
WORKDIR app/

# Add the full source
ADD . .

# Install!
RUN bundle install
