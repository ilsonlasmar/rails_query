# frozen_string_literal: true

module RailsQuery
  # Configuration class for RailsQuery
  class Configuration
    attr_accessor :cache_store, :default_ttl, :default_stale, :namespace, :executor, :logger

    def initialize
      @cache_store = default_cache_store
      @executor = default_executor
      @default_ttl = 0
      @default_stale = nil
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

    def default_executor
      Concurrent::ThreadPoolExecutor.new(
        min_threads: 2,
        max_threads: Concurrent.processor_count * 2,
        max_queue: 100,
        fallback_policy: :discard
      )
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
