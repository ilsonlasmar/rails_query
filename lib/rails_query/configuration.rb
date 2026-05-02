# frozen_string_literal: true

module RailsQuery
  # Configuration class for RailsQuery
  class Configuration
    attr_accessor :cache_store, :default_ttl, :namespace, :logger

    def initialize
      @cache_store = default_cache_store
      @default_ttl = 30.seconds
      @namespace = "rails_query"
      @logger = default_logger
    end

    private

    def default_cache_store
      if defined?(Rails) && Rails.respond_to?(:cache)
        Rails.cache
      else
        ActiveSupport::Cache::MemoryStore.new
      end
    end

    def default_logger
      if defined?(Rails) && Rails.respond_to?(:logger)
        Rails.logger
      else
        Logger.new($stdout)
      end
    end
  end
end
