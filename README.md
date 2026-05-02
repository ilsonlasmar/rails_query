# RailsQuery

[![Gem Version](https://badge.fury.io/rb/rails_query.svg)](http://badge.fury.io/rb/rails_query)
[![Build Status](https://github.com/ilsonlasmar/rails_query/actions/workflows/main.yml/badge.svg)](https://github.com/ilsonlasmar/rails_query/actions/workflows/main.yml)


A lightweight data-fetching and mutation layer for Ruby on Rails.


RailsQuery introduces a clear pattern for handling external APIs using:

- Providers  (configuration + context) - **how to connect**
- Queries (read + cache) - **how to read**
- Mutations (write + invalidate) - **how to write**

---


- [Installation](#installation)
- [Usage](#usage)
  - [Provider](#provider)
  - [Query](#query)
  - [Mutation](#mutation)


---

## Installation

Add the gem to your project

```ruby
gem "rails_query"
```
Then
```bash
bundle install
rails generate rails_query:install
```

## Usage

### Provider
Providers define configuration and act as the entry point.

```ruby
class UserProvider
  include RailsQuery::Adapter

  base_url ENV["USER_API_URL"]

  client do
    Faraday.new(url: base_url) do |f|
      f.request :json
      f.response :json
    end
  end

  query :find_user
  mutation :create_user
end
```

### Query

### Mutation

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ilsonlasmar/rails_query. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ilsonlasmar/rails_query/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RailsQuery project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ilsonlasmar/rails_query/blob/main/CODE_OF_CONDUCT.md).
