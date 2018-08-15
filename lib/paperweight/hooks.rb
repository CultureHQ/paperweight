# frozen_string_literal: true

module Paperweight
  # Overrides that hook into `paperclip` to add functionality.
  module Hooks
    # Overrides the `has_attached_file` method from `paperclip` so that
    # `paperweight` can add extras when the macro is called.
    module RecordHook
      # Converts a parent name to its respective component child names.
      class AttachmentName
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def processing
          :"#{name}_processing"
        end

        def url
          :"#{name}_url"
        end

        def url_eq
          :"#{name}_url="
        end

        def url_attr
          :"@#{name}_url"
        end
      end

      def has_attached_file(name, *) # rubocop:disable Naming/PredicateName
        super

        name = AttachmentName.new(name)
        attr_reader name.url

        define_paperweight_setter_for(name)
        define_paperweight_after_commit_for(name)
      end

      private

      def define_paperweight_setter_for(name)
        define_method(name.url_eq) do |value|
          instance_variable_set(name.url_attr, value)
          self[name.processing] = value
          self.updated_at = Time.now if value
        end
      end

      def define_paperweight_after_commit_for(name)
        after_commit if: name.url do
          attachment_url = public_send(name.url)
          PostProcessJob.perform_later(self, name.name.to_s, attachment_url)
        end
      end
    end

    # Overrides the `url` method from `paperclip` so that `paperweight` can
    # check the `image_processing` field and use that if it's still processing.
    module AttachmentHook
      def url(*)
        instance.public_send(:"#{name}_processing") || super
      end
    end
  end
end
