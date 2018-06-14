# frozen_string_literal: true

require 'test_helper'

class DownloadTest < ActiveSupport::TestCase
  def test_small
    with_file_server do |address|
      assert_kind_of Tempfile, download("#{address}/small.png")
    end
  end

  def test_large
    with_file_server do |address|
      assert_kind_of Tempfile, download("#{address}/large.png")
    end
  end

  def test_too_large
    with_file_server do |address|
      with_tiny_max_size do
        assert_raises Paperweight::Download::Error do
          download("#{address}/large.png")
        end
      end
    end
  end

  def test_class_download_swallows_errors
    with_file_server do |address|
      with_tiny_max_size do
        assert_nil Paperweight::Download.download("#{address}/large.png")
      end
    end
  end

  private

  def download(url)
    Paperweight::Download.new.download(url)
  end

  def with_tiny_max_size
    previous = Paperweight::Download::MAX_SIZE
    Paperweight::Download.send(:remove_const, :MAX_SIZE)
    Paperweight::Download.const_set(:MAX_SIZE, 1)

    yield
  ensure
    Paperweight::Download.send(:remove_const, :MAX_SIZE)
    Paperweight::Download.const_set(:MAX_SIZE, previous)
  end
end
