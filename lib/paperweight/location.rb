# frozen_string_literal: true

module Paperweight
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
      "#{self.class.prefix}/assets/#{table_name}/#{style}.gif"
    end

    def self.prefix
      @prefix ||=
        if Rails.env.production?
          Paperweight.config.asset_server
        else
          'http://localhost:3000/uploads'
        end
    end

    private

    def table_name
      model.class.table_name
    end
  end
end
