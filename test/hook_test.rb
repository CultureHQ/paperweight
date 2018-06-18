# frozen_string_literal: true

require 'test_helper'

class HookTest < ActiveJob::TestCase
  def test_image_url
    post = Post.first

    post.image_url = 'example.png'
    assert_equal 'example.png', post.image_url
    assert post.image_processing?

    post.image_url = nil
    assert_nil post.image_url
    refute post.image_processing?
  end

  def test_after_commit
    post = Post.first

    assert_enqueued_jobs 1 do
      post.update!(image_url: 'example.png')
    end
  end
end
