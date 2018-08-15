# frozen_string_literal: true

require 'test_helper'

class HooksTest < ActiveJob::TestCase
  def test_image_url_value
    post = Post.first

    assert_changes -> { post.updated_at } do
      post.image_url = 'example.png'
      assert_equal 'example.png', post.image_url
      refute_nil post.image_processing
    end
  end

  def test_image_url_value_nil
    post = Post.first

    assert_no_changes -> { post.updated_at } do
      post.image_url = nil
      assert_nil post.image_url
      assert_nil post.image_processing
    end
  end

  def test_after_commit
    post = Post.first

    assert_enqueued_jobs 1 do
      post.update!(image_url: 'example.png')
    end
  end

  def test_url_consistency
    post = Post.first

    with_file_server do |address|
      image_url = "#{address}/large.png"

      post.update!(image_url: image_url)
      assert_intermediate_url image_url, post

      flush_enqueued_jobs
      assert_processed_url post
    end
  end

  private

  def assert_intermediate_url(image_url, post)
    image = post.reload.image

    assert_equal image_url, image.url(:thumb)
    assert_equal image_url, image.url(:medium)
  end

  def assert_processed_url(post)
    thumb_url = post.reload.image.url(:thumb)

    assert thumb_url.starts_with?('/system/')
    assert_includes thumb_url, '/thumb/'
  end

  def flush_enqueued_jobs
    enqueued_jobs.map do |payload|
      args = ActiveJob::Arguments.deserialize(payload[:args])
      instantiate_job(payload.merge(args: args)).perform_now
    end
  end
end
