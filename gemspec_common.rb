# frozen_string_literal: true

require_relative "lib/saxon/libs/version"

def build_saxonc_gemspec(spec, name:, summary:, description:)
  spec.name          = name
  spec.version       = Saxon::Libs::VERSION
  spec.authors       = ["Jakob Kofoed Janot"]
  spec.email         = ["jakob@janot.dk"]

  spec.summary       = summary
  spec.description   = description
  spec.homepage      = "https://github.com/jakobjanot/ruby-saxonc-libs"
  spec.license       = "MIT"

  spec.files         = Dir.glob("lib/**/*") + Dir.glob("ext/**/*") + [
    "README.md",
    "LICENSE.txt",
    "#{name}.gemspec"
  ]
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/#{name.split('-').last}/extconf.rb"]

  spec.add_dependency "rubyzip", "~> 2.3"

  spec.metadata["source_code_uri"] = spec.homepage

  spec.required_ruby_version = ">= 2.6"
end
