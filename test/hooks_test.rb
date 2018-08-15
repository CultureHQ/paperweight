# frozen_string_literal: true

require 'test_helper'

class HooksTest < ActiveJob::TestCase
  def test_header_url_value
    post = Post.first

    assert_changes -> { post.updated_at } do
      post.header_url = 'example.png'
      assert_equal 'example.png', post.header_url
      refute_nil post.header_processing
    end
  end

  def test_header_url_value_nil
    post = Post.first

    assert_no_changes -> { post.updated_at } do
      post.header_url = nil
      assert_nil post.header_url
      assert_nil post.header_processing
    end
  end

  def test_after_commit
    post = Post.first

    assert_enqueued_jobs 1 do
      post.update!(header_url: 'example.png')
    end
  end

  def test_url_consistency
    post = Post.first

    with_file_server do |address|
      header_url = "#{address}/large.png"

      post.update!(header_url: header_url)
      assert_intermediate_url header_url, post.reload.header

      flush_enqueued_jobs
      assert_processed_url post.reload.header
    end
  end

  def test_still_functions_without_processing_column
    comment = Comment.first
    filepath = File.expand_path(File.join('files', 'small.png'), __dir__)

    File.open(filepath, 'r') { |file| comment.update!(image: file) }

    assert_processed_url comment.reload.image
  end

  private

  def assert_intermediate_url(expected, attachment)
    assert_equal expected, attachment.url(:thumb)
    assert_equal expected, attachment.url(:medium)
  end

  def assert_processed_url(attachment)
    thumb_url = attachment.url(:thumb)

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
