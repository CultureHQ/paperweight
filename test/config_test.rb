# frozen_string_literal: true

require 'test_helper'

class ConfigTest < Minitest::Test
  def test_config
    assert_kind_of Paperweight::Config, Paperweight.config
  end

  def test_configure
    Paperweight.configure do |config|
      config.bucket = 'culturehq-uploads'
    end

    assert_equal 'culturehq-uploads', Paperweight.config.bucket
  end
end
