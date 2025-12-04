# frozen_string_literal: true
require_relative "releases"

module SaxonC
  module Libs
    PATCH = "0"
    VERSION = "#{Releases.new.version}.#{PATCH}"
  end
end
