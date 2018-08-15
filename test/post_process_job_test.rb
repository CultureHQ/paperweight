# frozen_string_literal: true

require 'test_helper'

class PostProcessJobTest < ActiveJob::TestCase
  def test_perform
    post = Post.first

    with_file_server do |address|
      image_url = "#{address}/large.png"
      Paperweight::PostProcessJob.perform_now(post, :image, image_url)
    end

    assert_nil post.reload.image_processing
    assert post.image.exists?
  end
end
