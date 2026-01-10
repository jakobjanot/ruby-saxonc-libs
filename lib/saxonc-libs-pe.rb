# frozen_string_literal: true
require "saxon/libs"
Saxon::Libs.release = Saxon::Libs::Release.new(:pe)
Saxon::Libs.ensure_installed!