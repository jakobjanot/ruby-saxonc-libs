# frozen_string_literal: true

require_relative "gemspec_common"

Gem::Specification.new do |spec|
  build_saxonc_gemspec(
    spec,
    name: "saxonc-libs-he",
    summary: "SaxonC HE native libs downloader",
    description: "Downloads and caches the SaxonC Home Edition native libraries under ~/.saxonc for use by saxonc or other consumers."
  )
end
