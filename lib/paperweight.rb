# frozen_string_literal: true

require 'aws-sdk-s3'
require 'open-uri'
require 'net/http'
require 'paperclip'

require 'rails'
require 'active_job/railtie'

require 'paperweight/config'
require 'paperweight/download'
require 'paperweight/hook'
require 'paperweight/image'
require 'paperweight/location'
require 'paperweight/purge_job'
require 'paperweight/storage'
require 'paperweight/thumbnails_job'
require 'paperweight/version'
