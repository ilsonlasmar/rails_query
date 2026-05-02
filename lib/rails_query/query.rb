# frozen_string_literal: true

module RailsQuery
  class Query
    class << self
      def call(*args, **opts)
        new.call(*args, **opts)
      end

      def ttl(value = nil)
        @ttl = value if value
        @ttl
      end

      def key(&block)
        @key_block = block if block
        @key_block
      end
    end

    def call(*args, **opts)
      key = build_key(*args, **opts)
      provider_class = opts[:provider] || self.class.name
      RailsQuery.client.fetch(key, ttl: ttl, provider: provider_class) do
        kwargs? ? resolve(*args, **opts) : resolve(*args)
      end
    end

    def ttl
      self.class.ttl || RailsQuery.configuration.default_ttl
    end

    def build_key(*args, **opts)
      opts = opts.select { |k, _| self.class.key.parameters.map(&:last).include?(k) }
      return instance_exec(*args, **opts, &self.class.key) if self.class.key

      [self.class.name, args]
    end

    def kwargs?
      method(:resolve).parameters.any? { |type, _| %i[keyrest opt].include?(type) }
    end

    def resolve(*)
      raise NotImplementedError
    end
  end
end
