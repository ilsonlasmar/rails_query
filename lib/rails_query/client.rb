# frozen_string_literal: true

module RailsQuery
  # Internal client class responsible for cache interactions
  class Client
    def initialize(config)
      @cache       = config.cache_store
      @default_ttl = config.default_ttl
      @namespace   = config.namespace
      @logger      = config.logger
    end

    def fetch(key, ttl: @default_ttl, provider: nil, &block)
      store_index(provider, key) if provider
      namespaced = namespaced_key(key)
      @cache.fetch(namespaced, expires_in: ttl, &block)
    end

    def store_index(provider, key)
      return unless provider

      idx_key = index_key(provider)

      keys = @cache.read(idx_key) || []
      keys << key

      @cache.write(idx_key, keys.uniq)
    end

    def invalidate_provider(provider)
      index_key = index_key(provider)

      keys = @cache.read(index_key) || []

      keys.each do |digest|
        @cache.delete(namespaced_key(digest))
      end

      @cache.delete(index_key)
    end

    def invalidate(key)
      @cache.delete(namespaced_key(key))
    end

    private

    def namespaced_key(key)
      "#{@namespace}:#{Array(key).join(":")}"
    end

    def index_key(provider)
      "#{@namespace}:index:#{provider.to_s.underscore}"
    end
  end
end
