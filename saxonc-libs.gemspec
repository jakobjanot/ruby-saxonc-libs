# frozen_string_literal: true
# 
require_relative "lib/saxonc/libs/version"

Gem::Specification.new do |spec|
  spec.name          = "saxonc-libs"
  spec.version       = SaxonC::Libs::VERSION
  spec.authors       = ["SaxonC Ruby Contributors"]
  spec.email         = ["oss@example.com"]

  spec.summary       = "Platform-specific SaxonC binaries for Ruby projects"
  spec.description   = "Downloads and installs the official SaxonC runtime files so other Ruby gems can link against them."
  spec.homepage      = "https://github.com/jakobjanot/ruby-saxonc"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/saxonc-libs/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["lib/**/*", "exe/*", "README.md", "LICENSE.txt", "Rakefile", "data/**/*"]
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rubyzip", "~> 2.4"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
