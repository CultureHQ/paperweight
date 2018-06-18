# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paperweight/version'

Gem::Specification.new do |spec|
  spec.name          = 'paperweight'
  spec.version       = Paperweight::VERSION
  spec.authors       = ['Kevin Deisz']
  spec.email         = ['kevin.deisz@gmail.com']

  spec.summary       = 'An opinionated Paperclip.'
  spec.homepage      = 'https://github.com/CultureHQ/paperweight'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'paperclip', '~> 6.0'
  spec.add_dependency 'rails', '~> 5.2'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop', '~> 0.57'
  spec.add_development_dependency 'simplecov', '~> 0.16'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
end
