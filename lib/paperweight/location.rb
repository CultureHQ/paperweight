# frozen_string_literal: true

module Paperweight
  # The location of the attachment in terms of paths are URLs.
  class Location
    attr_reader :model, :style

    def initialize(model, style = :original)
      @model = model
      @style = style
    end

    def path
      "#{table_name}/#{model.id}-#{style}-#{model.image_uuid}"
    end

    def url
      "#{self.class.prefix}/#{path}"
    end

    def default_url
      "#{self.class.prefix}/#{table_name}/#{style}.png"
    end

    def self.prefix
      @prefix ||=
        if Rails.env.production?
          Paperweight.config.asset_server
        else
          'http://localhost:3000/paperweight'
        end
    end

    private

    def table_name
      model.class.table_name
    end
  end
end
