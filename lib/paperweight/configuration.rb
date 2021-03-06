# frozen_string_literal: true

# Handles `Paperclip` attachments on the backend in a delayed process.
module Paperweight
  # Allows configuring certain attributes about how to process attachments.
  class Configuration
    attr_accessor :download_attempts, :max_size

    def initialize
      @download_attempts = 1
      @max_size = 10 * 1024 * 1024
    end
  end

  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end
  end
end
