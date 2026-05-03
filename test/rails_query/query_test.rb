# frozen_string_literal: true

# test/rails_query/query_test.rb

require "test_helper"
require "minitest/autorun"

module QueryFixtures
  class TestQuery < RailsQuery::Query
    ttl 1.minute
    key { |id, flag: "false"| ["test_query", id, flag] }

    def resolve(id, opts = {})
      { id: id, time: Time.now.to_f, flag: opts[:flag] }
    end
  end
end

class QueryTest < Minitest::Test
  def setup
    RailsQuery.invalidate_provider("TestProvider")
  end

  def test_cache_works
    first = QueryFixtures::TestQuery.call(1, provider: "TestProvider")
    second = QueryFixtures::TestQuery.call(1, provider: "TestProvider")

    assert_equal first, second
  end

  def test_kwargs_affect_cache
    a = QueryFixtures::TestQuery.call(1, flag: true, provider: "TestProvider")
    b = QueryFixtures::TestQuery.call(1, flag: false, provider: "TestProvider")

    refute_equal a, b
  end
end
