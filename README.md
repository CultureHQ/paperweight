# Paperweight

[![Build Status](https://travis-ci.com/CultureHQ/paperweight.svg?branch=master)](https://travis-ci.com/CultureHQ/paperweight)

An opinionated Paperclip for a specific workflow. Only accepts image URLs instead of uploaded files. The image URLs are then queued for downloading, converting, and generating thumbnails in the background using `ActiveJob`.

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

Then, create and run a migration to add the `image_uuid` and `image_processing` columns to your model:

```ruby
class AddImageToPost < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :image_uuid, :string
    add_column :posts, :image_processing, :boolean, default: false, null: false
  end
end
```

Next, add the class macro to the model:

```ruby
class Post < ApplicationRecord
  has_image thumb: '100x100>'
end
```

Finally, add the ability to update the `image_url` attribute from the controller:

```ruby
class PostsController < ApplicationController
  # PUT|PATCH /posts/:id
  def update
    post = Post.find(params[:id])

    if post.update(post_params)
      render json: post
    else
      render error: post.error, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.permit(:image_url)
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CultureHQ/paperweight.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
