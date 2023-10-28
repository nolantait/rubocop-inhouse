# frozen_string_literal: true

require_relative "inhouse/version"

module Rubocop
  module Inhouse
    PROJECT_ROOT   = Pathname.new(__dir__).parent.parent.expand_path.freeze
    CONFIG_DEFAULT = PROJECT_ROOT.join("config", "default.yml").freeze
    CONFIG_RAILS = PROJECT_ROOT.join("config", "rails.yml").freeze

    private_constant :PROJECT_ROOT
    private_constant :CONFIG_DEFAULT
    private_constant :CONFIG_RAILS
  end
end
