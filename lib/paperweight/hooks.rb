# frozen_string_literal: true

module Paperweight
  # Overrides that hook into `paperclip` to add functionality.
  module Hooks
    # Overrides the `has_attached_file` method from `paperclip` so that
    # `paperweight` can add extras when the macro is called.
    module RecordHook
      # rubocop:disable Naming/PredicateName
      def has_attached_file(name, options = {})
        after_download = options.delete(:after_download)
        super

        name = AttachmentName.new(name)
        attr_reader name.url

        define_paperweight_setter_for(name)
        define_paperweight_after_commit_for(name)
        define_method(name.after_download, &after_download) if after_download
      end
      # rubocop:enable Naming/PredicateName

      private

      def define_paperweight_setter_for(name)
        define_method(name.url_eq) do |value|
          instance_variable_set(name.url_attr, value)
          self[name.processing] = value

          return unless value

          self[name.updated_at] = Time.now
          self.updated_at = Time.now
        end
      end

      def define_paperweight_after_commit_for(name)
        after_commit if: name.url do
          PostProcessJob.perform_later(self, name.name.to_s)
        end
      end
    end

    # Overrides the `url` method from `paperclip` so that `paperweight` can
    # check the `image_processing` field and use that if it's still processing.
    module AttachmentHook
      def url(*)
        processing_url || super
      end

      private

      def processing_url
        attribute = :"#{name}_processing"
        instance.has_attribute?(attribute) && instance.public_send(attribute)
      end
    end
  end
end
