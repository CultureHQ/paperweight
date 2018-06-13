# frozen_string_literal: true

module Paperweight
  # Removes all previous image files matching the given pattern.
  class PurgeJob < ActiveJob::Base
    PLACEHOLDER = ':style'

    queue_as :default

    def perform(pattern, styles)
      styles.each do |style|
        Storage.adapter.delete(pattern.gsub(PLACEHOLDER, style))
      end
    end

    def self.perform_later_for(model, image_uuid = nil)
      model.image_uuid = image_uuid if image_uuid

      perform_later(
        Location.new(model, PLACEHOLDER).path,
        model.class.image_styles.keys.map(&:to_s)
      )
    end
  end
end
