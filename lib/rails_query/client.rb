# frozen_string_literal: true

module RailsQuery
  # Internal client class responsible for cache interactions
  class Client
    def initialize(config)
      @cache         = config.cache_store
      @default_ttl   = config.default_ttl
      @default_stale = config.default_stale
      @executor      = config.executor
      @namespace     = config.namespace
      @logger        = config.logger
    end

    def fetch(key, ttl: @default_ttl, stale: @default_stale, provider: nil, &block)
      namespaced = namespaced_key(key)
      entry = @cache.read(namespaced)

      if entry
        age = Time.now - entry[:fetched_at]
        async_refetch(namespaced, ttl, provider, &block) if stale && stale < age
        return entry[:data]
      end

      data = block.call
      write(namespaced, data, ttl, provider: provider)

      data
    end

    def write(key, data, ttl, provider: nil)
      store_index(provider, key) if provider

      @cache.write(key, { data: data, fetched_at: Time.now }, expires_in: ttl)
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

    def in_lock?(key)
      lock_key = "lock:#{key}"
      @cache.exist?(lock_key)
    end

    def write_lock(key)
      lock_key = "lock:#{key}"
      @cache.write(lock_key, true, expires_in: 10.seconds)
    end

    def delete_lock(key)
      lock_key = "lock:#{key}"
      @cache.delete(lock_key)
    end

    def async_refetch(key, ttl, provider, &block)
      return if in_lock?(key)

      write_lock(key)

      @executor.post do
        data = block.call
        write(key, data, ttl, provider: provider)
      rescue StandardError => e
        @logger.error("[RailsQuery] SWR refetch failed: #{e.message}")
      ensure
        delete_lock(key)
      end
    end

    def namespaced_key(key)
      "#{@namespace}:#{Array(key).join(":")}"
    end

    def index_key(provider)
      "#{@namespace}:index:#{provider.to_s.underscore}"
    end
  end
end
