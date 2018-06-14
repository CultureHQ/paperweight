# frozen_string_literal: true

module Paperweight
  # The image object attached to the model.
  class Image
    attr_reader :model

    def initialize(model)
      @model = model
    end

    def as_json(*)
      serialized_styles_for(model).merge!(
        is_default: model.image? ? false : true,
        processing: model.image_processing?
      )
    end

    def update_file(file)
      image_styles.each do |style, geometry|
        options = { geometry: geometry, convert_options: '-strip' }
        thumbnail = Paperclip::Thumbnail.new(file, options).make
        Storage.adapter.put(thumbnail, Location.new(model, style).path)
      end

      model.clear_image_url
      model.update!(image_processing: false)
    end

    def update_url(url)
      update_file(Download.download(url))
    end

    def path(style = :original)
      Location.new(model, style).path
    end

    def url(style = :original)
      Location.new(model, style).url
    end

    private

    def image_styles
      model.class.image_styles
    end

    def serialized_styles_for(model)
      url_method = url_method_for(model)

      image_styles.each_key.each_with_object({}) do |style, serialized|
        serialized[:"#{style}_url"] =
          Location.new(model, style).public_send(url_method)
      end
    end

    def url_method_for(model)
      !model.image? || model.image_processing? ? :default_url : :url
    end
  end
end
