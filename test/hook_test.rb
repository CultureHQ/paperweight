# frozen_string_literal: true

require 'test_helper'

class HookTest < ActiveJob::TestCase
  def test_image_url_value
    post = Post.first

    assert_changes -> { post.updated_at } do
      post.image_url = 'example.png'
      assert_equal 'example.png', post.image_url
      assert post.image_processing?
    end
  end

  def test_image_url_value_nil
    post = Post.first

    assert_no_changes -> { post.updated_at } do
      post.image_url = nil
      assert_nil post.image_url
      refute post.image_processing?
    end
  end

  def test_after_commit
    post = Post.first

    assert_enqueued_jobs 1 do
      post.update!(image_url: 'example.png')
    end
  end
end
