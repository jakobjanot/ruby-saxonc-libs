# frozen_string_literal: true

require "net/http"
require "uri"
require "tempfile"
require "digest"

module SaxonC
  module Libs
    # Streams a remote archive to disk and verifies its checksum.
    class Download
      CHUNK_SIZE = 1024 * 1024

      def initialize(url, checksum: nil)
        @url = URI.parse(url)
        @checksum = checksum
      end

      def fetch
        tempfile = Tempfile.new(["saxonc", File.extname(@url.path)])
        tempfile.binmode
        digest = Digest::SHA256.new if @checksum

        Net::HTTP.start(@url.host, @url.port, use_ssl: @url.scheme == "https") do |http|
          request = Net::HTTP::Get.new(@url)
          http.request(request) do |response|
            unless response.is_a?(Net::HTTPSuccess)
              raise "Failed to download #{@url} (#{response.code})"
            end

            response.read_body do |chunk|
              tempfile.write(chunk)
              digest&.update(chunk)
            end
          end
        end

        tempfile.flush
        tempfile.rewind
        verify_checksum(digest)
        path = tempfile.path
        tempfile.close
        path
      ensure
        tempfile&.close unless tempfile.nil? || tempfile.closed?
      end

      private

      def verify_checksum(digest)
        return unless @checksum

        actual = digest.hexdigest
        return if actual == @checksum.downcase

        raise "Checksum mismatch for #{@url}: expected #{@checksum}, got #{actual}"
      end
    end
  end
end
