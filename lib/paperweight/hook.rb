# frozen_string_literal: true

module Paperweight
  module Hook
    class DynamicExtension < Module
      def initialize(styles)
        define_method(:image_styles) { styles }
      end
    end

    module StaticExtension
      def clear_image_url
        @image_url = nil
      end

      def image
        Image.new(self)
      end

      def image?
        image_uuid
      end

      def image_url
        @image_url
      end

      def image_url=(url)
        assign_attributes(
          image_processing: url ? true : false,
          image_uuid: url ? SecureRandom.uuid : nil
        )

        @image_url = url
      end

      def self.included(base)
        base.after_commit do
          PurgeJob.perform_later_for(self, prev_image_uuid) if prev_image_uuid
          ThumbnailsJob.perform_later(self, image_url) if image_url
        end

        base.before_destroy if: :image? do
          PurgeJob.perform_later_for(self)
        end
      end

      private

      def prev_image_uuid
        previous_changes.fetch('image_uuid', [])[0]
      end
    end

    def has_paperweight(styles) # rubocop:disable Naming/PredicateName
      extend DynamicExtension.new(styles)
      include StaticExtension
    end
  end
end
