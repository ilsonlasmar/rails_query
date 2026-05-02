# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

require "minitest/autorun"
require "mocha/minitest"

require "rails_query"

# cache store configuration for testing
RailsQuery.configure do |config|
  config.cache_store = ActiveSupport::Cache::MemoryStore.new
end
