# frozen_string_literal: true

module RailsQuery
  class Railtie < Rails::Railtie
    initializer "rails_query.setup" do
      RailsQuery.configure do |config|
        config.cache_store = Rails.cache if defined?(Rails.cache)
      end
    end
  end
end
