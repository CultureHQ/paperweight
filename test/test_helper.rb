# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'paperweight'

require 'minitest/autorun'
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

require 'active_record'
require 'active_job/railtie'
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

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
    t.string :image_uuid
    t.boolean :image_processing, default: false, null: false
    t.timestamps
  end
end

class Post < ActiveRecord::Base
  has_image thumb: '100x100>', medium: '500x500>'

  create! [{ title: 'One' }, { title: 'Two' }, { title: 'Three' }]
end

module ActiveSupport
  class TestHelper
    def with_fixture_server
      port = 8080
      server = fixture_server_on(port)
      thread = Thread.new { server.start }

      yield "http://localhost:#{port}"

      server.stop
      thread.join
    end

    private

    def fixture_server_on(port)
      require 'webrick'

      WEBrick::HTTPServer.new(
        Port: port,
        DocumentRoot: Rails.root.join('test', 'fixtures', 'files').to_s,
        Logger: WEBrick::Log.new('/dev/null'),
        AccessLog: []
      )
    end
  end
end
