# frozen_string_literal: true

require 'test_helper'

class PostProcessJobTest < ActiveJob::TestCase
  def test_perform
    post = Post.first

    with_file_server do |address|
      post.update(header_url: "#{address}/large.png")
      Paperweight::PostProcessJob.perform_now(post, :header)
    end

    assert_nil post.reload.header_processing
    assert post.header.exists?
  end
end
