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
    assert post.is_downloaded
  end

  def test_perform_with_no_processing
    post = Post.first
    assert_nil post.header_processing

    assert_nothing_raised do
      Paperweight::PostProcessJob.perform_now(post, :header)
    end
  end
end
