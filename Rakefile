# frozen_string_literal: true

require "rake"

GEM_SPECS = %w[
  saxonc-libs-he.gemspec
  saxonc-libs-pe.gemspec
  saxonc-libs-ee.gemspec
].freeze

def build_task_name(gemspec)
  "build:#{File.basename(gemspec, ".gemspec")}"
end

GEM_SPECS.each do |gemspec|
  desc "Build #{gemspec}"
  task build_task_name(gemspec) do
    sh "gem build #{gemspec}"
  end
end

desc "Build all saxonc-libs gems"
task build: GEM_SPECS.map { |g| build_task_name(g) }

task default: :build
