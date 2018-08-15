# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'paperweight'
require 'minitest/autorun'

require 'active_record'
require 'active_job/railtie'
require 'paperclip/railtie'
require 'rails/test_help'

module Paperweight
  class Application < Rails::Application
    config.load_defaults 5.2
    config.cache_classes = true
    config.eager_load = false
  end
end

Rails.application.initialize!

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

Paperclip.logger.level = Logger::FATAL

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :header_file_name
    t.string :header_content_type
    t.integer :header_file_size
    t.datetime :header_updated_at
    t.string :header_processing
    t.timestamps
  end
end

class Post < ActiveRecord::Base
  has_attached_file(
    :header,
    styles: { thumb: '100x100>', medium: '500x500>', original: '' }
  )

  validates_attachment(
    :header,
    size: { in: 0..10.megabytes },
    content_type: { content_type: %r{\Aimage/.*\z} }
  )

  create!
end

module FileServer
  ROOT = -File.join('test', 'files')

  def self.next_port
    @next_port = (@next_port || 8080) + 1
  end

  def with_file_server
    port = FileServer.next_port
    server = file_server_on(port)
    thread = Thread.new { server.start }

    yield "http://localhost:#{port}"

    server.stop
    thread.join
  end

  private

  def file_server_on(port)
    require 'webrick'

    WEBrick::HTTPServer.new(
      Port: port,
      DocumentRoot: ROOT,
      Logger: WEBrick::Log.new('/dev/null'),
      AccessLog: []
    )
  end
end

ActiveSupport::TestCase.include(FileServer)
