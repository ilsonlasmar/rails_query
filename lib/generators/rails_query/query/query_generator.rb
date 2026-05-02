# frozen_string_literal: true

require "rails/generators"

module RailsQuery
  module Generators
    # Generator that creates a provider and queries based on the provided name and query list.
    class QueryGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :queries, type: :array, default: []

      def create_provider_directory
        empty_directory "app/providers"
      end

      def create_queries_directory
        empty_directory "app/providers/#{file_name}/queries"
      end

      def create_provider_file
        @provider_module = class_name
        template "provider.rb.tt", "app/providers/#{file_name}_provider.rb"
      end

      def create_query_files
        queries.each do |query|
          @query_name = query
          @provider_module = class_name

          template(
            "query.rb.tt",
            "app/providers/#{file_name}/queries/#{query}_query.rb"
          )
        end
      end

      def add_queries_to_provider
        provider_path = "app/providers/#{file_name}_provider.rb"
        return unless File.exist?(provider_path)

        content = File.read(provider_path)

        pending_queries = queries.reject do |query|
          content.match?(/^\s*query\s+:#{Regexp.escape(query)}\b/)
        end

        return if pending_queries.empty?

        inject_into_file provider_path, after: "include RailsQuery::DSL\n" do
          pending_queries.map { |query| "\n  query :#{query}\n" }.join
        end
      end

      def show_usage
        say "\nQueries created successfully!", :green
      end
    end
  end
end
