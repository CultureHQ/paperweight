# frozen_string_literal: true

module Paperweight
  # Queues thumbnails for processing.
  class ThumbnailsJob < ActiveJob::Base
    queue_as :default

    discard_on ActiveJob::DeserializationError

    def perform(model, url)
      model.image.update_url(url)
    end
  end
end
