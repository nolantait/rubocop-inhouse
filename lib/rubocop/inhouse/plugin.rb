# frozen_string_literal: true

require "lint_roller"
require "pathname"

require_relative "version"

module RuboCop
  module Inhouse
    # Integrates rubocop-inhouse with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: "rubocop-inhouse",
          version: Rubocop::Inhouse::VERSION,
          homepage: "https://github.com/nolantait/rubocop-inhouse",
          description: "RuboCop configuration and cops for InHouse projects."
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join("../../../config/default.yml")
        )
      end
    end
  end
end
