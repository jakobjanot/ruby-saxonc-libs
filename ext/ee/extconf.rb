# frozen_string_literal: true

require "mkmf"
require_relative "../../lib/saxon/libs"

Saxon::Libs.release = Saxon::Libs::Release.new(:ee)
Saxon::Libs.ensure_installed!

# Dummy makefile to satisfy RubyGems build pipeline
create_makefile("saxon/libs/install_ee")