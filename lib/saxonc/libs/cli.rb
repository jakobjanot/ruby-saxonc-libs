# frozen_string_literal: true

require "optparse"

module SaxonC
  module Libs
    # Very small command-line interface that exposes the installer.
    class CLI
      def self.start(argv)
        new(argv).run
      end

      def initialize(argv)
        @argv = argv.dup
        @options = { target: Installer.default_installation_dir, edition: :he, force: false }
      end

      def run
        parser.parse!(@argv)
        command = @argv.shift || "install"

        case command
        when "install"
          Installer.new(target: @options[:target], edition: @options[:edition]).install(force: @options[:force])
        else
          warn "Unknown command: #{command}"
          warn parser
          exit 1
        end
      end

      private

      def parser
        @parser ||= OptionParser.new do |opts|
          opts.banner = "Usage: saxonc-libs [install] [options]"
          opts.on("-t", "--target=DIR", "Directory to extract the runtime into") do |dir|
            @options[:target] = File.expand_path(dir)
          end
          opts.on("-e", "--edition=EDITION", "Saxon edition to install (he, pe, ee)") do |value|
            @options[:edition] = value.downcase.to_sym
          end
          opts.on("-f", "--force", "Re-download even if already installed") do
            @options[:force] = true
          end
        end
      end
    end
  end
end
