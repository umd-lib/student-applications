# syntax = docker/dockerfile:1

# UMD Customization
# This Dockerfile is designed for production, not development.
#
# Dockerfile for the generating student-applications Rails application Docker
# image for use with Kubernetes.
# End UMD Customization

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
# UMD Customization
ARG RUBY_VERSION=3.4.7
# End UMD Customization
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libyaml-dev node-gyp pkg-config python-is-python3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# UMD Customization
# Student Applications still uses the "Sprockets" asset pipeline, so Node and
# Yarn are not needed.
# Install JavaScript dependencies
#ARG NODE_VERSION=18.20.5
#ARG YARN_VERSION=1.22.22
#ENV PATH=/usr/local/node/bin:$PATH
#RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
#    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
#    npm install -g yarn@$YARN_VERSION && \
#    rm -rf /tmp/node-build-master
# End UMD Customization

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# UMD Customization
# Install node modules
#COPY package.json yarn.lock ./
#RUN yarn install --frozen-lockfile
# End UMD Customization

# Copy application code
COPY . .

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# UMD Customization
RUN PROD_DATABASE_ADAPTER=postgresql SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile
# End UMD Customization


RUN rm -rf node_modules


# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# UMD Customization
# Copy Rails application start script
COPY --chown=rails:rails docker_config/student-applications/rails_start.sh .
# End UMD Customization

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000

# UMD Customization
# The main command to run when the container starts.
CMD ["./rails_start.sh"]
# End UMD Customization
