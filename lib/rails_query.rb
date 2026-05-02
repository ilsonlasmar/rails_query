# frozen_string_literal: true

require "active_support"
require "active_support/cache"
require "active_support/core_ext/numeric/time"

require_relative "rails_query/version"
require_relative "rails_query/configuration"
require_relative "rails_query/client"
require_relative "rails_query/query"
require_relative "rails_query/mutation"
require_relative "rails_query/dsl"

module RailsQuery
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end

    def reset_configuration!
      @_configuration = nil
    end

    def client
      @client ||= Client.new(configuration)
    end

    def invalidate_provider(provider)
      client.invalidate_provider(provider)
    end
  end
end

require_relative "rails_query/railtie" if defined?(Rails)
