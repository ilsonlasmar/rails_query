# test/rails_query/mutation_test.rb

require "test_helper"

module MutationFixtures
  class TestQuery < RailsQuery::Query
    key { |id| "test_query:#{id}" }

    def resolve(id, _opts = {})
      { id: id, time: Time.now.to_f }
    end
  end

  class TestQuery < RailsQuery::Query
    key { |id| "test_query:#{id}" }

    def resolve(id, _opts = {})
      { id: id, time: Time.now.to_f }
    end
  end
end

class TestMutation < RailsQuery::Mutation
  invalidates "TestProvider"

  def resolve(*)
    true
  end
end

class MutationTest < Minitest::Test
  def setup
    RailsQuery.invalidate_provider("TestProvider")
    # RailsQuery.client.instance_variable_get(:@cache).clear
  end

  def test_invalidation
    first = MutationFixtures::TestQuery.call(1, provider: "TestProvider")
    TestMutation.call({ id: 1 })
    second = MutationFixtures::TestQuery.call(1, provider: "TestProvider")


    refute_equal first, second
  end
end
