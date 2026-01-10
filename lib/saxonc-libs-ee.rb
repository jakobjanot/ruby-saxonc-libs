# frozen_string_literal: true
require "saxon/libs"
Saxon::Libs.release = Saxon::Libs::Release.new(:ee)
Saxon::Libs.ensure_installed!