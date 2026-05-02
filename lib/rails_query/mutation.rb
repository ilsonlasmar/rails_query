# frozen_string_literal: true

module RailsQuery
  # Base class for mutations
  class Mutation
    class << self
      def call(*args, **opts)
        new.call(*args, **opts)
      end

      def invalidates(*providers)
        @invalidates = providers
      end

      def invalidation_targets
        @invalidates || []
      end
    end

    def call(*args, **opts)
      result = kwargs? ? resolve(*args, **opts) : resolve(*args)
      invalidate!

      result
    end

    def kwargs?
      method(:resolve).parameters.any? { |type, _| %i[keyrest opt].include?(type) }
    end

    def resolve(*)
      raise NotImplementedError
    end

    private

    def invalidate!
      self.class.invalidation_targets.each do |provider|
        RailsQuery.invalidate_provider(provider)
      end
    end
  end
end
