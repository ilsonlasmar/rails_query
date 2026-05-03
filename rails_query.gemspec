# frozen_string_literal: true

require_relative "lib/rails_query/version"

Gem::Specification.new do |spec|
  spec.name = "rails_query"
  spec.version = RailsQuery::VERSION
  spec.authors = ["Ilson Lasmar"]
  spec.email = ["ilson.lasmar@gmail.com"]

  spec.summary = "Declarative query caching layer with lifecycle management for Rails"
  spec.description = <<~DESC
    RailsQuery provides a declarative abstraction for fetching, caching, and
    managing remote or expensive data in Rails applications.

    Inspired by modern data-fetching patterns, it introduces query lifecycle
    concepts such as caching, stale-while-revalidate, automatic invalidation,
    and request deduplication, while remaining idiomatic to the Rails ecosystem.
  DESC
  spec.homepage = "https://github.com/ilsonlasmar/rails_query"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ilsonlasmar/rails_query"
  spec.metadata["changelog_uri"] = "https://github.com/ilsonlasmar/rails_query/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby", "~> 1.3"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "mocha", "~> 3.1"
  spec.add_development_dependency "pry", "~> 0.14"
  spec.add_development_dependency "simplecov", "~> 0.22"
end
