# frozen_string_literal: true

module RailsQuery
  # Adapter module to be included in provider classes for defining queries and mutations
  module Adapter
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class methods for defining base URL, client, queries, and mutations
    module ClassMethods
      def base_url(url = nil)
        return @base_url if url.nil?

        @base_url = url
      end

      def client(&block)
        return @client_block if block.nil?

        @client_block = block
      end

      # rubocop:disable Metrics/MethodLength
      def query(name, ttl: nil, &block)
        define_method(name) do |*args, **opts|
          opts_with_context = inject_context(**opts)

          if block
            execute_with_cache(name, ttl, args) do
              instance_exec(*args, **opts_with_context, &block)
            end
          else
            query_class = resolve_query_class(name)
            query_class.call(*args, **opts_with_context)
          end
        end

        define_singleton_method(name) do |*args, **opts|
          instance.public_send(name, *args, **opts)
        end
      end

      def mutation(name, &block)
        define_method(name) do |*args, **opts|
          opts_with_context = inject_context(**opts)

          if block
            instance_exec(*args, **opts_with_context, &block)
          else
            mutation_class = resolve_mutation_class(name)
            mutation_class.call(*args, **opts_with_context)
          end
        end

        define_singleton_method(name) do |*args, **opts|
          instance.public_send(name, *args, **opts)
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def instance
        RailsQuery::Adapter.instance_for(self)
      end
    end

    def self.instance_for(klass)
      @instances ||= {}
      @instances[klass] ||= klass.new
    end

    def base_url
      self.class.base_url
    end

    def client
      @client ||= instance_exec(&self.class.client) if self.class.client
    end

    private

    def execute_with_cache(name, ttl, args, &block)
      return yield unless ttl

      key = RailsQuery::KeyBuilder.build([self.class.name, name, args])

      RailsQuery.client.fetch(key, ttl: ttl, provider: self.class.name, &block)
    end

    def inject_context(**opts)
      {
        client: (respond_to?(:client) ? client : nil),
        base_url: (respond_to?(:base_url) ? base_url : nil),
        provider: self.class.name
      }.merge(opts)
    end

    def resolve_query_class(name)
      provider = self.class.name.sub("Provider", "")
      class_name = "#{name.to_s.camelize}Query"

      "#{provider}::Queries::#{class_name}".constantize
    end

    def resolve_mutation_class(name)
      provider = self.class.name.sub("Provider", "")
      class_name = "#{name.to_s.camelize}Mutation"

      "#{provider}::Mutations::#{class_name}".constantize
    end
  end
end
