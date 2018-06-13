# frozen_string_literal: true

module Paperweight
  class ThumbnailsJob < ActiveJob::Base
    queue_as :default

    discard_on ActiveJob::DeserializationError

    def perform(model, url)
      model.image.update_url(url)
    end
  end
end
