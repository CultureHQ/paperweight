# Paperweight

[![Build Status](https://travis-ci.com/CultureHQ/paperweight.svg?branch=master)](https://travis-ci.com/CultureHQ/paperweight)

An opinionated Paperclip. Works only for the direct image upload to S3 -> send image URL to server -> process thumbnails using ActiveJob workflow.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paperweight'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paperweight

## Usage

First, configure `paperweight` in an initializer, e.g., `config/initializers/paperweight.rb`:

```ruby
Paperweight.configure do |config|
  # your asset server (preferably a CDN)
  config.asset_server = 'https://uploads.culturehq.com'

  # the S3 bucket to which to uploads images
  config.bucket = 'culturehq-uploads'

  # the AWS credentials used with permission to S3
  config.credentials = {
    access_key_id: Rails.application.credentials.aws_access_key_id,
    secret_access_key: Rails.application.credentials.aws_secret_access_key,
    region: 'us-west-2'
  }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CultureHQ/paperweight.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
