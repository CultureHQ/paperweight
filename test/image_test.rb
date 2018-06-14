# frozen_string_literal: true

require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def test_serialization
    post = Post.first
    assert_default post

    with_file_server do |address|
      perform_enqueued_jobs { post.update!(image_url: "#{address}/large.png") }
      assert_non_default post.reload
    end
  end

  def test_location
    post = Post.first

    image_uuid = '0000-aaaa-1111-bbbb'
    post.image_uuid = image_uuid

    path = post.image.path(:thumb)
    url = post.image.url(:thumb)

    assert_includes path, image_uuid
    assert_includes path, "#{post.id}-"

    assert_includes url, path
    assert_includes url, 'localhost'
  end

  private

  def assert_default(post)
    serialized = post.image.as_json

    assert serialized[:is_default]
    assert_styles_include serialized, 'assets'
  end

  def assert_non_default(post)
    serialized = post.image.as_json

    refute serialized[:is_default]
    assert_styles_include serialized, post.image_uuid
  end

  def assert_styles_include(serialized, needle)
    style_keys = serialized.keys.grep(/_url/)
    assert_equal Post.image_styles.size, style_keys.size

    urls = serialized.values_at(*style_keys)
    assert(urls.all? { |url| url.include?(needle) })
  end
end
