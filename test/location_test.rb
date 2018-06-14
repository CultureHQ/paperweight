# frozen_string_literal: true

require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  def test_prefix
    Paperweight::Location.instance_variable_set(:@prefix, nil)

    asset_server = 'https://uploads.culturehq.com'
    Paperweight.configure do |config|
      config.asset_server = asset_server
    end

    Rails.env.stub(:production?, true) do
      assert_equal asset_server, Paperweight::Location.prefix
    end
  ensure
    Paperweight::Location.instance_variable_set(:@prefix, nil)
  end
end
