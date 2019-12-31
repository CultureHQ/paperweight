# frozen_string_literal: true

require 'open-uri'
require 'net/http'
require 'paperclip'
require 'uri'

module Paperclip
  class UrlGenerator
    # We're overriding this module inside of UrlGenerator in order to get rid
    # of the warning that came in in Ruby 2.7.
    module URI
      def self.escape(url)
        ::URI::DEFAULT_PARSER.escape(url)
      end
    end
  end
end

require 'rails'
require 'active_job'

require 'paperweight/attachment_name'
require 'paperweight/configuration'
require 'paperweight/download'
require 'paperweight/hooks'
require 'paperweight/post_process_job'
require 'paperweight/version'

Paperclip::ClassMethods.prepend(Paperweight::Hooks::RecordHook)
Paperclip::Attachment.prepend(Paperweight::Hooks::AttachmentHook)
