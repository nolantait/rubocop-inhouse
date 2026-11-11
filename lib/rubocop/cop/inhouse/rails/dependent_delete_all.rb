# frozen_string_literal: true

module RuboCop
  module Cop
    module Inhouse
      module Rails
        # Checks for `dependent: :destroy` on associations.
        #
        # `:delete_all` skips instantiating and destroying each record, which is
        # faster. Use `:destroy` only when the associated records have
        # callbacks that must run. Disable this cop on the association when
        # those callbacks are needed.
        #
        # @example
        #   # bad, when the associated records have no callbacks
        #   has_many :comments, dependent: :destroy
        #
        #   # good
        #   has_many :comments, dependent: :delete_all
        #
        #   # good, when the associated records need callbacks
        #   has_many :comments, dependent: :destroy # callbacks are required
        #
        class DependentDeleteAll < Base
          extend AutoCorrector

          MSG = "Use `dependent: :delete_all` unless the associated records " \
                "need callbacks."

          RESTRICT_ON_SEND = %i[has_many has_one has_and_belongs_to_many].freeze

          def on_send(node)
            return if RESTRICT_ON_SEND.none?(node.method_name)

            dependent_destroy_values(node).each do |value|
              add_offense(value, message: MSG) do |corrector|
                corrector.replace(value, ":delete_all")
              end
            end
          end

          private

          def dependent_destroy_values(node)
            node.arguments.flat_map do |argument|
              next [] unless argument.hash_type?

              argument.pairs.filter_map do |pair|
                key, value = *pair
                next unless key.sym_type? && key.value == :dependent

                value if value.sym_type? && value.value == :destroy
              end
            end
          end
        end
      end
    end
  end
end
