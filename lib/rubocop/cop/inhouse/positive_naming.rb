# frozen_string_literal: true

module RuboCop
  module Cop
    module Inhouse
      # Checks for names that describe the absence of a state instead of the
      # state itself.
      #
      # Positive names are usually easier to read and avoid double negatives
      # such as `!not_deleted?`.
      #
      # @example
      #   # bad
      #   def not_deleted?
      #     deleted_at.nil?
      #   end
      #
      #   # good
      #   def active?
      #     deleted_at.nil?
      #   end
      #
      class PositiveNaming < Base
        MSG = "Avoid negative naming for `%<name>s`; use a positive name " \
              "instead."

        DEFAULT_FORBIDDEN_PREFIXES = %w[
          not_ no_ non_ is_not_ has_no_ without_
        ].freeze

        ATTRIBUTE_MACROS = %i[
          attr_reader
          attr_writer
          attr_accessor
          attribute
          field
          option
          param
          define_method
          define_singleton_method
        ].freeze

        def on_def(node)
          check_name(node.loc.name, node.method_name)
        end

        def on_defs(node)
          check_name(node.loc.name, node.method_name)
        end

        def on_lvasgn(node)
          on_variable(node)
        end

        def on_ivasgn(node)
          on_variable(node)
        end

        def on_cvasgn(node)
          on_variable(node)
        end

        def on_gvasgn(node)
          on_variable(node)
        end

        def on_arg(node)
          on_variable(node)
        end

        def on_optarg(node)
          on_variable(node)
        end

        def on_restarg(node)
          on_variable(node)
        end

        def on_kwarg(node)
          on_variable(node)
        end

        def on_kwoptarg(node)
          on_variable(node)
        end

        def on_kwrestarg(node)
          on_variable(node)
        end

        def on_blockarg(node)
          on_variable(node)
        end

        def on_send(node)
          return if ATTRIBUTE_MACROS.none?(node.method_name)

          node.arguments.each do |argument|
            next unless argument.sym_type? || argument.str_type?

            check_name(argument.source_range, argument.value)
          end
        end

        private

        def on_variable(node)
          check_name(node.loc.name, node.name) if node.loc.respond_to?(:name)
        end

        def check_name(range, name)
          name = normalized_name(name)
          return unless negative_name?(name)

          add_offense(range, message: format(MSG, name: name))
        end

        def normalized_name(name)
          name.to_s.sub(/\A@{1,2}|\A\$/, "")
        end

        def negative_name?(name)
          return false if name.nil?

          name = name.to_s
          forbidden_prefixes.any? { |prefix| name.start_with?(prefix) }
        end

        def forbidden_prefixes
          cop_config.fetch("ForbiddenPrefixes", DEFAULT_FORBIDDEN_PREFIXES)
        end
      end
    end
  end
end
