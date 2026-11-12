# frozen_string_literal: true

module RuboCop
  module Cop
    module Inhouse
      module Rails
        # Checks for `dependent: :destroy` on associations.
        #
        # `:delete_all` and `:delete` skip instantiating and destroying each
        # record, which is faster. Use `:destroy` only when the associated
        # records have callbacks that must run. Disable this cop on the
        # association when those callbacks are needed.
        #
        # @example
        #   # bad, when the associated records have no callbacks
        #   has_many :comments, dependent: :destroy
        #   has_one :profile, dependent: :destroy
        #
        #   # good
        #   has_many :comments, dependent: :delete_all
        #   has_one :profile, dependent: :delete
        #
        #   # good, when the associated records need callbacks
        #   has_many :comments, dependent: :destroy # callbacks are required
        #
        class DependentDeleteAll < Base
          extend AutoCorrector

          MSG = "Use `dependent: :%<replacement>s` unless the associated " \
                "records need callbacks."

          REPLACEMENTS = {
            has_many: :delete_all,
            has_one: :delete
          }.freeze

          RESTRICT_ON_SEND = REPLACEMENTS.keys.freeze

          def on_send(node)
            replacement = REPLACEMENTS[node.method_name]
            return unless replacement

            message = format(MSG, replacement: replacement)
            dependent_destroy_values(node).each do |value|
              add_offense(value, message: message) do |corrector|
                corrector.replace(value, ":#{replacement}")
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
