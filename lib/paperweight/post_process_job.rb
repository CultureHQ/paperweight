# frozen_string_literal: true

module Paperweight
  # Queues post processing.
  class PostProcessJob < ActiveJob::Base
    queue_as :default

    discard_on ActiveJob::DeserializationError

    def perform(model, name, url)
      tempfile = Download.new.download(url)
      model.update!(name => tempfile, :"#{name}_processing" => nil)
    end
  end
end
