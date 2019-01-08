# frozen_string_literal: true

module Paperweight
  # Converts a parent name to its respective component child names.
  class AttachmentName
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def after_download
      :"#{name}_after_download"
    end

    def processing
      :"#{name}_processing"
    end

    def updated_at
      :"#{name}_updated_at"
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
end
