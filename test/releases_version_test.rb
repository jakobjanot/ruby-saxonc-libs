# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "../lib/saxonc/libs/version"

class ReleasesVersionTest < Minitest::Test
  def test_releases_version_matches_constant
    releases_path = File.expand_path("../releases.yml", __dir__)
    assert File.exist?(releases_path), "releases.yml is missing"

    releases_version = YAML.load_file(releases_path).fetch("version").to_s
    assert_equal releases_version, SaxonC::Libs::SAXON_VERSION,
                 "releases.yml version (#{releases_version}) must match SaxonC::Libs::SAXON_VERSION"
  end
end
