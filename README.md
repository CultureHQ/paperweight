# Paperweight

[![Build Status](https://travis-ci.com/CultureHQ/paperweight.svg?branch=master)](https://travis-ci.com/CultureHQ/paperweight)

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

Configure `Paperclip` as you normally would, according to their docs. Then, add the ability to update the `*_url` attribute from the controller, where the `*` is the name of the attachment that you specified in your model's call to `has_attached_file`.

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/CultureHQ/paperweight.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
