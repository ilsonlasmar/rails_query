# frozen_string_literal: true

require "rails/generators"

module RailsQuery
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Install RailsQuery with provider + example query"

      def create_initializer
        if File.exist?("config/initializers/rails_query.rb")
          say_status("skipped", "Initializer already exists", :yellow)
        else
          @query_namespace = app_name.underscore
          template "rails_query.rb.tt", "config/initializers/rails_query.rb"
        end
      end

      def create_directories
        empty_directory "app/providers"
        empty_directory "app/providers/user"
        empty_directory "app/providers/user/queries"
      end

      def create_provider
        template "user_provider.rb.tt", "app/providers/user_provider.rb"
      end

      def create_example_query
        template(
          "find_user_query.rb.tt",
          "app/providers/user/queries/find_user_query.rb"
        )
      end

      def add_autoload_path
        inject_into_file "config/application.rb",
          after: "class Application < Rails::Application\n" do
          "    config.autoload_paths << Rails.root.join('app/providers')\n"
        end
      end

      def show_readme
        say "\nRailsQuery installed successfully!", :green
      end

      private

      def app_name
        Rails.application.class.module_parent_name
      end
    end
  end
end
