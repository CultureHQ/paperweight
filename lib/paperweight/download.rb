# frozen_string_literal: true

module Paperweight
  # Most of this from https://gist.github.com/janko-m/7cd94b8b4dd113c2c193
  class Download
    Error = Class.new(StandardError)

    DOWNLOAD_ERRORS = [
      SocketError,          # domain not found
      OpenURI::HTTPError,   # response status 4xx or 5xx
      RuntimeError,         # redirection errors (e.g. redirection loop)
      URI::InvalidURIError, # invalid URL
      Error                 # our errors
    ].freeze

    MAX_SIZE = 10 * 1024 * 1024

    def download(url)
      # Finally we download the file. Here we mustn't use simple #open that
      # open-uri overrides, because this is vulnerable to shell execution
      # attack (if #open method detects a starting pipe (e.g. "| ls"), it will
      # execute the following as a shell command).
      normalize_download(uri_from(url).open(open_options))
    rescue *DOWNLOAD_ERRORS => error
      message = error.message

      # open-uri will throw a RuntimeError when it detects a redirection loop,
      # so we want to reraise the exception if it was some other RuntimeError
      raise if error.is_a?(RuntimeError) && message !~ /redirection/

      # We raise our unified Error class
      raise Error, "download failed (#{url}): #{message}"
    end

    def self.download(url)
      new.download(url)
    rescue Error
      nil
    end

    private

    # open-uri will return a StringIO instead of a Tempfile if the filesize
    # is less than 10 KB, so we patch this behaviour by converting it into a
    # Tempfile.
    def normalize_download(downloaded_file)
      return downloaded_file unless downloaded_file.is_a?(StringIO)

      # We need to open it in binary mode for Windows users.
      tempfile = Tempfile.new('download-', binmode: true)

      # IO.copy_stream is the most efficient way of data transfer.
      IO.copy_stream(downloaded_file, tempfile.path)
      downloaded_file = tempfile

      # We add the metadata that open-uri puts on the file
      # (e.g. #content_type)
      OpenURI::Meta.init(downloaded_file)
    end

    def open_options
      {}.tap do |options|
        # It was shown that in a random sample approximately 20% of websites
        # will simply refuse a request which doesn't have a valid User-Agent.
        options['User-Agent'] = 'Paperweight'

        # It's good to shield ourselves from files that are too big. open-uri
        # will call this block as soon as it gets the "Content-Length" header,
        # which means that we can bail out before we download the file.
        options[:content_length_proc] = lambda { |size|
          if size && size > MAX_SIZE
            raise Error, "file is too big (max is #{MAX_SIZE})"
          end
        }
      end
    end

    # Disabling :reek:ManualDispatch here because we don't control the URI API
    def uri_from(url)
      # This will raise an InvalidURIError if the URL is very wrong. It will
      # still pass for strings like "foo", though.
      url = URI(url)

      # We need to check if the URL was either http://, https:// or ftp://,
      # because these are the only ones we can download from. open-uri will add
      # the #open method only to these ones, so this is a good check.
      raise Error, 'url was invalid' unless url.respond_to?(:open)

      url
    end
  end
end
