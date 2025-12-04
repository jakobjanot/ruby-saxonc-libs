#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "yaml"
require "digest"
require "net/http"
require "uri"
require "tempfile"

options = {
  releases_path: File.expand_path("../releases.yml", __dir__),
  source_dir: nil,
  quiet: false
}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: script/fill_checksums.rb [options]"
  opts.on("-r", "--releases=PATH", "Path to releases.yml (default: #{options[:releases_path]})") do |path|
    options[:releases_path] = File.expand_path(path)
  end
  opts.on("-d", "--source-dir=DIR", "Directory containing already-downloaded SaxonC archives") do |dir|
    options[:source_dir] = File.expand_path(dir)
  end
  opts.on("-q", "--quiet", "Suppress progress output") do
    options[:quiet] = true
  end
  opts.on("-h", "--help", "Show this help") do
    puts opts
    exit 0
  end
end

# fix openssl certs for net/http

parser.parse!(ARGV)

unless File.exist?(options[:releases_path])
  warn "Cannot find releases file at #{options[:releases_path]}"
  exit 1
end

releases = YAML.load_file(options[:releases_path]) || {}
modified = false

def download_to_tempfile(url)
  uri = URI.parse(url)
  tempfile = Tempfile.new(["saxonc", File.extname(uri.path)])
  tempfile.binmode

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri)
  http.request(request) do |response|
    unless response.is_a?(Net::HTTPSuccess)
      raise "Failed to download #{url} (#{response.code})"
    end

    response.read_body { |chunk| tempfile.write(chunk) }
  end

  tempfile.flush
  tempfile.rewind
  path = tempfile.path
  tempfile.close
  path
end

releases.each do |version, editions|
  editions.each do |edition, platforms|
    platforms.each do |platform, entry|
      next if entry["sha256"] && !entry["sha256"].to_s.empty?

      url = entry.fetch("url")
      path = nil

      downloaded = false

      if options[:source_dir]
        filename = File.basename(URI.parse(url).path)
        candidate = File.join(options[:source_dir], filename)
        unless File.exist?(candidate)
          warn "Skipping #{version} #{edition} #{platform}: missing #{candidate}"
          next
        end
        path = candidate
      else
        puts "Downloading #{url}..." unless options[:quiet]
        path = download_to_tempfile(url)
        downloaded = true
      end

      digest = Digest::SHA256.file(path).hexdigest
      File.delete(path) if downloaded && File.exist?(path)
      entry["sha256"] = digest
      modified = true
      puts "Set #{version} #{edition} #{platform} sha256 to #{digest}" unless options[:quiet]
    end
  end
end

if modified
  File.write(options[:releases_path], releases.to_yaml)
  puts "Updated #{options[:releases_path]}" unless options[:quiet]
else
  puts "No missing checksums" unless options[:quiet]
end
