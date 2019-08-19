# Paperweight

[![Build Status](https://github.com/CultureHQ/paperweight/workflows/Push/badge.svg)](https://github.com/CultureHQ/paperweight/actions)
[![Gem Version](https://img.shields.io/gem/v/paperweight.svg)](https://github.com/CultureHQ/paperweight)

Handles `Paperclip` attachments on the backend in a delayed process.

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

Configure `Paperclip` as you normally would, according to their docs. Then, add an additional `*_processing` string field to the model for which you want to process attachments in the background, where `*` is the name of the attachment that you specified in your model's call to `has_attached_file`.

```ruby
class AddImageProcessingToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :image_processing, :string
  end
end
```

This column will be used to hold the temporary URL of the image that needs to be processed. It will override all calls to the `#url` method on `Paperclip` attachments until the processing is done so that there's no break in the visibility of the image.

Then, add the ability to update the `*_url` attribute from the controller.

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

From now on, updating this attribute will queue a job in the background to update the image later.

### Configuration

You can provide additional configuration options through the `Paperweight.configure` method, as in:

```ruby
Paperweight.configure do |config|
  config.download_attempts = 10
  config.max_size = 20 * 1024 * 1024
end
```

The current configuration options include:

* `download_attempts` - defaults to 1
* `max_size` - defaults to 10 MB

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CultureHQ/paperweight.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
