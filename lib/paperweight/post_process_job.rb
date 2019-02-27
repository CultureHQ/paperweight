# frozen_string_literal: true

module Paperweight
  # Queues post processing.
  class PostProcessJob < ActiveJob::Base
    queue_as :default

    discard_on ActiveJob::DeserializationError

    rescue_from Download::Error do |error|
      raise error if executions >= Paperweight.config.download_attempts

      retry_job(wait: (executions**4) + 2)
    end

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
