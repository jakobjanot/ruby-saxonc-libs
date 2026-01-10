# frozen_string_literal: true

require_relative "gemspec_common"

Gem::Specification.new do |spec|
  build_saxonc_gemspec(
    spec,
    name: "saxonc-libs-ee",
    summary: "SaxonC EE native libs downloader",
    description: "Downloads and caches the SaxonC Enterprise Edition native libraries under ~/.saxonc for use by saxonc or other consumers."
  )
end
