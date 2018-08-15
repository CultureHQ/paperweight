# frozen_string_literal: true

module Paperweight
  # Queues post processing.
  class PostProcessJob < ActiveJob::Base
    queue_as :default

    discard_on ActiveJob::DeserializationError

    def perform(model, name)
      processing = :"#{name}_processing"

      tempfile = Download.new.download(model.public_send(processing))
      model.update!(name => tempfile, processing => nil)
    end
  end
end
