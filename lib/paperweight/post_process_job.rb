# frozen_string_literal: true

module Paperweight
  # Queues post processing.
  class PostProcessJob < ActiveJob::Base
    queue_as :default

    discard_on ActiveJob::DeserializationError

    def perform(model, name)
      name = AttachmentName.new(name)
      image_url = model.public_send(name.processing)

      return unless image_url

      model.update!(
        name.name => Download.download(image_url),
        name.processing => nil
      )

      return unless model.respond_to?(name.after_download)

      model.public_send(name.after_download)
    end
  end
end
