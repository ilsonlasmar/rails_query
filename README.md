# RailsQuery

[![Gem Version](https://badge.fury.io/rb/rails_query.svg)](http://badge.fury.io/rb/rails_query)
[![Build Status](https://github.com/ilsonlasmar/rails_query/actions/workflows/main.yml/badge.svg)](https://github.com/ilsonlasmar/rails_query/actions/workflows/main.yml)


A lightweight data-fetching and mutation layer for Ruby on Rails.


RailsQuery introduces a clear pattern for handling external APIs using:

- Providers  (configuration + context) - **how to connect**
- Queries (read + cache) - **how to read**
- Mutations (write + invalidate) - **how to write**

---

## Why RailsQuery?

In most Rails projects, external API calls end up:

- scattered across services, models, and controllers
- duplicated HTTP setup (Faraday, headers, auth)
- hard to track and debug
- inconsistent caching strategies
- tightly coupled and difficult to test

RailsQuery solves this by centralizing and standardizing all external interactions.

  architecture:

```
app/providers/
  user_provider.rb
  user/
    queries/
      find_user_query.rb
    mutations/
      create_user_mutation.rb
```

## Index
- [Installation](#installation)
- [Usage](#usage)
  - [Provider](#provider)
  - [Query](#query)
  - [Mutation](#mutation)
- [Generators](#generators)
- [Caching](#caching)
- [Invalidation](#invalidation)



---

## Installation

Add the gem to your project

```ruby
gem "rails_query"
```
Then
```bash
bundle install
```

## Usage

### Install setup
```bash
rails g rails_query:install
```

### Provider
Providers define configuration and and context (HTTP client, base URL, auth)

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
Queries are responsible for reading data and caching results.

```ruby
class User::Queries::FindUserQuery < RailsQuery::Query
  ttl 5.minutes

  key do |id|
    ["users", id]
  end

  def resolve(id, opts = {})
    client = opts.fetch(:client)
    client.get("/users/#{id}").body
  end
end
```
Basic usage:
```ruby
UserProvider.find_user(1)
```

### Mutation
Mutations are responsible for writing data and invalidating cache.

```ruby
class User::Mutations::CreateUserMutation < RailsQuery::Mutation
  invalidates "UserProvider"

  def resolve(params, opts = {})
    client = opts.fetch(:client)
    client.post("/users", params).body
  end
end
```

## Generators
Generate queries:

```bash
rails g rails_query:query User list_users
```

Generate mutations:

```bash
rails g rails_query:mutation User update_user
```

## Caching
Queries are cached automatically based on:

- class name
- arguments
- keyword arguments (kwargs)

```ruby
UserProvider.find_user(1)
UserProvider.find_user(1) # cached
```

You can configure TTL:

```ruby
ttl 5.minutes
```

## Invalidation

Mutations invalidate cache after execution.

```ruby
invalidates "UserProvider"
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ilsonlasmar/rails_query. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ilsonlasmar/rails_query/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RailsQuery project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ilsonlasmar/rails_query/blob/main/CODE_OF_CONDUCT.md).
