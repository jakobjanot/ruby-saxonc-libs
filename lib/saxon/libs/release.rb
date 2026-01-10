# frozen_string_literal: true

require "fileutils"
require "rbconfig"
require "tempfile"
require "open-uri"
require "zip"

module Saxon
  module Libs
    class Release
      attr_reader :edition, :version, :platform, :base_dir

      VERSION_REGEX = /\A(\d+)\.(\d+)\.(\d+)\z/
      def initialize(edition, version: Saxon::Libs::SAXON_VERSION, base_dir: File.join(Dir.home, ".saxonc"), host_cpu: nil, host_os: nil)
        @edition = edition
        @version = version
        @base_dir = base_dir
        @host_cpu = host_cpu
        @host_os = host_os
      end

      def saxonc_home
        File.join(path, edition_full)
      end

      def installed?
        File.exist?(path)
      end

      def ensure_installed!
        install! unless installed?
      end

      def platform
        current = "#{os}-#{arch}"
        
        unless available_platforms.include?(current)
          raise UnsupportedPlatform, "Unsupported platform: #{current || 'unknown'}"
        end

        current
      end
      
      private

      def path
        File.expand_path(File.join(base_dir, version, edition_full, platform))
      end

      def download_url
        "https://downloads.saxonica.com/SaxonC/#{edition.to_s.upcase}/#{version_major}/#{edition_full}-#{platform}-#{version_major}-#{version_minor}-#{version_patch}.zip"
      end

      def install!
        STDERR.puts "SaxonC does not appear to be installed in #{path}, installing!"
        FileUtils.mkdir_p(base_dir)

        temp_dir = Dir.mktmpdir("saxonc")

        begin
          zip_path = File.join(temp_dir, "saxonc.zip")

          begin
            STDERR.puts "Downloading SaxonC from #{download_url}..."
            URI.open(download_url) do |saxon_archive|
              File.binwrite(zip_path, saxon_archive.read)
            end
          rescue OpenURI::HTTPError => e
            raise "Failed to download SaxonC from #{download_url}, perhaps the version or platform is not supported: #{e.message}"
          rescue StandardError => e
            raise "An error occurred while downloading SaxonC: #{e.message}"
          end

          STDERR.puts "Extracting SaxonC..."
          Zip::File.open(zip_path) do |zip|
            zip.each do |entry|
              next if entry.symlink?

              dest = File.join(temp_dir, entry.name)
              FileUtils.mkdir_p(File.dirname(dest))
              entry.extract(dest) { true }
            end
          end

          extracted_dir = Dir.glob(File.join(temp_dir, "*")).find { |p| File.directory?(p) }
          raise "Failed to extract SaxonC archive" unless extracted_dir

          FileUtils.mkdir_p(File.dirname(path))
          FileUtils.rm_rf(path)
          FileUtils.mv(extracted_dir, path)
          STDOUT.puts "\nSuccessfully installed SaxonC to #{path}!\n"
        ensure
          begin
            FileUtils.rm_rf(temp_dir)
          rescue Errno::ENOENT
            # temp_dir may already be gone if moved; ignore
          end
        end

        raise "Failed to install SaxonC. Sorry :(" unless File.exist?(path)
      end

      def normalize_edition(value)
        value.to_s.downcase.to_sym
      end

      def version_major
        version.split(".")[0]
      end

      def version_minor
        version.split(".")[1]
      end

      def version_patch
        version.split(".")[2]
      end

      def edition_full
        "SaxonC#{edition.to_s.upcase}"
      end

      def available_platforms
        [
          "linux-x86_64",
          "linux-aarch64",
          "macos-x86_64",
          "macos-arm64",
          "windows-x86_64"
        ]
      end

      def os
        @host_os || case RbConfig::CONFIG["host_os"]
        when /linux/
          "linux"
        when /darwin/
          "macos"
        when /mswin|mingw|cygwin/
          "windows"
        else
          nil
        end
      end

      def arch
        @host_cpu || RbConfig::CONFIG["host_cpu"]
      end
    end
  end
end
