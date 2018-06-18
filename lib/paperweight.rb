# frozen_string_literal: true

require 'open-uri'
require 'net/http'
require 'paperclip'
require 'rails'

require 'active_job'

require 'paperweight/download'
require 'paperweight/hook'
require 'paperweight/post_process_job'
require 'paperweight/version'

Paperclip::ClassMethods.prepend(Paperweight::Hook)
