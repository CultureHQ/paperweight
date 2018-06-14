# frozen_string_literal: true

# An opinionated Paperclip
module Paperweight
  # Stores various metadata about the configuration of `paperweight`.
  class Config
    attr_accessor :asset_server, :bucket, :credentials

    def initialize
      @credentials = { region: 'us-east-1' }
    end
  end

  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end
end
