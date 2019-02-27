# frozen_string_literal: true

require 'test_helper'

class PostProcessJobTest < ActiveJob::TestCase
  Paperweight::Download.singleton_class.prepend(
    Module.new do
      def clear
        @downloads = []
      end

      def downloads
        @downloads ||= []
      end

      def download(url)
        downloads << url
        super(url)
      end
    end
  )

  def test_perform
    post = Post.first
    assert_nil post.header_processing

    with_file_server do |address|
      post.update(header_url: "#{address}/large.png")
      Paperweight::PostProcessJob.perform_now(post, 'header')
    end

    assert_nil post.reload.header_processing
    assert post.header.exists?
    assert post.is_downloaded
  end

  def test_perform_with_no_processing
    post = Post.first
    assert_nil post.header_processing

    assert_nothing_raised do
      Paperweight::PostProcessJob.perform_now(post, 'header')
    end
  end

  def test_perform_with_retries
    Paperweight::Download.clear

    post = Post.first
    post.update(header_url: 'http://localhost:8080/foobar.png')

    assert_raises Paperweight::Download::Error do
      perform_enqueued_jobs do
        Paperweight::PostProcessJob.perform_now(post, 'header')
      end
    end

    assert_equal Paperweight.config.download_attempts,
                 Paperweight::Download.downloads.size
  end
end
