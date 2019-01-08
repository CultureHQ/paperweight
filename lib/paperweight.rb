# frozen_string_literal: true

require 'open-uri'
require 'net/http'
require 'paperclip'
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
