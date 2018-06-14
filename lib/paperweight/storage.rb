# frozen_string_literal: true

module Paperweight
  # Handles putting and deleting files from different kinds of storage.
  module Storage
    # A storage adapter for Amazon AWS S3.
    class Remote
      attr_reader :client

      def initialize
        @client = ::Aws::S3::Client.new(Paperweight.config.credentials)
      end

      def delete(key)
        client.delete_object(bucket: Paperweight.config.bucket, key: key)
      end

      def put(file, key)
        client.put_object(
          bucket: Paperweight.config.bucket,
          key: key,
          content_type: Paperclip::ContentTypeDetector.new(file.path).detect,
          content_disposition: 'attachment',
          body: file
        )
      end
    end

    # A storage adapter for a local filesystem.
    class Local
      attr_reader :root

      def initialize(root)
        @root = root
      end

      def delete(key)
        FileUtils.rm(File.join(root, key))
      end

      def put(file, key)
        filepath = File.join(root, key)
        FileUtils.mkdir_p(File.dirname(filepath))
        FileUtils.cp(file.path, filepath)
      end
    end

    class << self
      def adapter
        @adapter ||=
          case Rails.env
          when 'production'  then Remote.new
          when 'development' then local_for('public')
          when 'test'        then local_for('tmp')
          end
      end

      private

      def local_for(directory)
        Local.new(Rails.root.join(directory, 'paperweight').to_s.freeze)
      end
    end
  end
end
