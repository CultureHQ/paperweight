# frozen_string_literal: true

module Paperweight
  class Config
    attr_accessor :asset_server, :bucket, :credentials
  end

  class << self
    def config
      @config ||= new
    end

    def configure
      yield config
    end
  end
end
