# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.2] - 2018-09-04
### Changed
- Handle the case where an image has been removed or cleared before the post process job executes. In this case the job should bail out before attempting to download the file.

## [1.0.1] - 2018-08-15
### Changed
- Fixed `paperweight` to not break `paperclip` functionality when a record does not contain the `#*_processing` column.
- Simplified the post processing job to not require sending the URL manually, instead we can just use the record itself. This guaruntees that if the URL changes between the time the job is enqueued and the time the job is completed we don't end up with race conditions.

## [1.0.0] - 2018-08-15
### Changed
- Changed the expected column type of `#*_processing` from a boolean to string. This allows us to use it to store the URL from the `#*_url=` method so that it can be used in the meantime before the job finishes processing.

## [0.2.0] - 2018-08-15
### Added
- The ability to configure the `max_size` value (the maximum download size) using the `Paperweight.configure` method.

[Unreleased]: https://github.com/CultureHQ/paperweight/compare/1.0.2...HEAD
[1.0.2]: https://github.com/CultureHQ/paperweight/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/CultureHQ/paperweight/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/CultureHQ/paperweight/compare/v0.2.0...v1.0.0
[0.2.0]: https://github.com/CultureHQ/paperweight/compare/v0.1.2...v0.2.0
