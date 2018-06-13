# frozen_string_literal: true

module Paperweight
  # Adds the `paperweight` hook in ActiveRecord models.
  class Railtie < Rails::Railtie
    # Extensions that need be generated from input.
    class DynamicExtension < Module
      def initialize(styles)
        define_method(:image_styles) { styles }
      end
    end

    # Extensions that are the same for each kind of attachment.
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

    # Provides the `has_paperweight` method to attach to models.
    module Hook
      def has_paperweight(styles) # rubocop:disable Naming/PredicateName
        extend DynamicExtension.new(styles)
        include StaticExtension
      end
    end

    initializer 'paperclip.hook' do
      ActiveSupport.on_load(:active_record) { include Hook }
    end
  end
end
