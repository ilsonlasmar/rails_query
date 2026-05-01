# frozen_string_literal: true

require "rails/generators"

module RailsQuery
  module Generators
    # Generator that creates a provider and mutations based on the provided name and mutation list.
    class MutationGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :mutations, type: :array, default: []

      def create_provider_directory
        empty_directory "app/providers"
      end

      def create_mutations_directory
        empty_directory "app/providers/#{file_name}/mutations"
      end

      def create_provider_file
        @provider_module = class_name
        template "provider.rb.tt", "app/providers/#{file_name}_provider.rb"
      end

      def create_mutation_files
        mutations.each do |mutation|
          @mutation_name = mutation
          @provider_module = class_name

          template(
            "mutation.rb.tt",
            "app/providers/#{file_name}/mutations/#{mutation}_mutation.rb"
          )
        end
      end

      def add_mutations_to_provider
        provider_path = "app/providers/#{file_name}_provider.rb"
        return unless File.exist?(provider_path)

        content = File.read(provider_path)

        pending_mutations = mutations.reject do |mutation|
          content.match?(/^\s*mutation\s+:#{Regexp.escape(mutation)}\b/)
        end

        return if pending_mutations.empty?

        inject_into_file provider_path, after: "include RailsQuery::DSL\n" do
          pending_mutations.map { |mutation| "\n  mutation :#{mutation}\n" }.join
        end
      end

      def show_usage
        say "\nMutations created successfully!", :green
      end
    end
  end
end
