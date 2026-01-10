# frozen_string_literal: true

require "minitest/autorun"
require "fileutils"
require "tmpdir"
require_relative "../lib/saxon/libs/release"

class ReleaseInstallWithRealArchiveTest < Minitest::Test
  def setup
    @archive = File.expand_path("fixtures/SaxonCEE-linux-x86_64-12-9-0.zip", __dir__)
    @platform = "linux-x86_64"
    @edition = :ee
  end

  def test_installs_from_real_archive_fixture
    skip "Set SAXONC_TEST_ARCHIVE to a SaxonC zip before running" unless @archive && File.exist?(@archive)

    base_dir = Dir.mktmpdir("saxonc-test")

    release = Saxon::Libs::Release.new(@edition, host_cpu: "x86_64", host_os: "linux", base_dir: base_dir)
      
    stubbed_open = lambda do |_url, &blk|
      File.open(@archive, "rb") do |file|
        file.rewind
        blk ? blk.call(file) : file
      end
    end

    URI.stub(:open, stubbed_open) do
      release.ensure_installed!
    end

    home = release.saxonc_home

    lib_ext = case @platform
              when /linux/ then ".so"
              when /macos/ then ".dylib"
              when /windows/ then ".dll"
              else raise "Unknown platform for test expectations: #{@platform}"
              end

    libsaxonc_file = File.join(home, "lib", "libsaxonc-#{@edition}#{lib_ext}.#{release.version}")
    libsaxonc_core_file = File.join(home, "lib", "libsaxonc-core-#{@edition}#{lib_ext}.#{release.version}")
    #binding.irb
    assert File.exist?(libsaxonc_file), "missing libsaxonc-* in #{home}/lib"
    assert File.exist?(libsaxonc_core_file), "missing libsaxonc-core-* in #{home}/lib"
  ensure
    FileUtils.rm_rf(base_dir) if base_dir && Dir.exist?(base_dir)
  end
end
