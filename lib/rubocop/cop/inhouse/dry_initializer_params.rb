# frozen_string_literal: true

module RuboCop
  module Cop
    module Inhouse
      # Checks classes using `dry-initializer` for multiple `param`
      # declarations.
      #
      # Multiple positional arguments are only a good fit when the arguments
      # have a natural ordering. Otherwise keyword arguments, declared with
      # `option`, are easier to read at the call site.
      #
      # @example
      #   # bad
      #   class Move
      #     extend Dry::Initializer
      #
      #     param :source
      #     param :destination
      #   end
      #
      #   # good
      #   class Move
      #     extend Dry::Initializer
      #
      #     option :source
      #     option :destination
      #   end
      #
      # Natural orderings are not inferred. Disable this cop on classes where
      # the positional arguments have a natural ordering.
      #
      class DryInitializerParams < Base
        extend AutoCorrector

        MSG = "Prefer `option` over `param` when multiple arguments have no " \
              "natural ordering."

        DRY_INITIALIZER_MIXINS = %i[include extend].freeze

        def on_send(node)
          return unless node.method?(:param)

          owner = nearest_namespace(node)
          return unless owner
          return unless dry_initializer?(owner)
          return if own_params(owner).one?

          add_offense(node.loc.selector, message: MSG) do |corrector|
            corrector.replace(node.loc.selector, "option")
          end
        end

        private

        def nearest_namespace(node)
          node.each_ancestor(:class, :module).first
        end

        def dry_initializer?(namespace)
          own_sends(namespace).any? do |send_node|
            next false if DRY_INITIALIZER_MIXINS.none?(send_node.method_name)

            send_node.arguments.any? do |argument|
              argument.source.start_with?("Dry::Initializer")
            end
          end
        end

        def own_params(namespace)
          own_sends(namespace).select { |send_node| send_node.method?(:param) }
        end

        def own_sends(namespace)
          namespace.each_descendant(:send).select do |send_node|
            nearest_namespace(send_node) == namespace
          end
        end
      end
    end
  end
end
