# frozen_string_literal: true

require 'test_helper'

class RailtieTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def test_image_styles
    assert_kind_of Hash, Post.image_styles
    assert_equal 3, Post.image_styles.size
  end

  def test_image
    assert_kind_of Paperweight::Image, Post.first.image
  end

  def test_image_url
    post = Post.first

    post.image_url = 'example.png'
    assert_equal 'example.png', post.image_url

    assert post.image_processing?
    refute_nil post.image_uuid

    post.image_url = nil
    assert_nil post.image_url

    refute post.image_processing?
    assert_nil post.image_uuid
  end

  def test_clear_image_url
    post = Post.first

    post.image_url = 'example.png'
    post.clear_image_url

    assert_nil post.image_url
    refute_nil post.image_uuid
  end

  def test_image?
    post = Post.first
    refute post.image?

    post.image_uuid = '0000-aaaa-1111-bbbb'
    assert post.image?
  end

  def test_after_commit
    post = Post.first

    assert_enqueued_jobs 1 do
      post.update!(image_url: 'example.png')
    end

    assert_enqueued_jobs 2 do
      post.update(image_url: 'example.png')
    end
  end

  def test_before_destroy
    post = Post.first
    files = -> { Dir[File.join('tmp', 'paperweight', '**', '*')].size }

    with_file_server do |address|
      assert_no_difference files do
        image_url = "#{address}/large.png"
        perform_enqueued_jobs { post.update!(image_url: image_url) }
        perform_enqueued_jobs { post.destroy }
      end
    end
  end
end
