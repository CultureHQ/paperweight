# frozen_string_literal: true

module Paperweight
  # Queues post processing.
  class PostProcessJob < ActiveJob::Base
    queue_as :default

    discard_on ActiveJob::DeserializationError

    def perform(model, name)
      processing = :"#{name}_processing"
      image_url = model.public_send(processing)

      return unless image_url
      model.update!(name => Download.download(image_url), processing => nil)
    end
  end
end
