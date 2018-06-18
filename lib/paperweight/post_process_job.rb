# frozen_string_literal: true

module Paperweight
  # Queues post processing.
  class PostProcessJob < ActiveJob::Base
    queue_as :default

    discard_on ActiveJob::DeserializationError

    def perform(model, name, url)
      model.update!(
        name => Download.new.download(url),
        :"#{name}_processing" => false
      )
    end
  end
end
