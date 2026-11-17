# frozen_string_literal: true

module RuboCop
  module Cop
    module Inhouse
      module Rails
        # Checks for `class` attribute values built by concatenating string
        # literals.
        #
        # A list of classes reads better as an array of individual class names.
        # It also makes it harder to accidentally drop or duplicate a space
        # when the list is split across lines.
        #
        # @example
        #   # bad
        #   div(
        #     class: "rounded-md border shrink-0 opacity-0 " \
        #            "pointer-events-none transition-opacity"
        #   )
        #
        #   # good
        #   div(class: %w[
        #     rounded-md
        #     border
        #     shrink-0
        #     opacity-0
        #     pointer-events-none
        #     transition-opacity
        #   ])
        #
        class ClassList < Base
          extend AutoCorrector

          MSG = "Use a `%w[]` array for class lists instead of concatenating " \
                "string literals."

          def on_pair(node)
            return unless class_attribute?(node)

            value = node.value
            return unless concatenated_string?(value)
            return unless plain_string_literals?(value)

            add_offense(value, message: MSG) do |corrector|
              corrector.replace(value, class_array(value))
            end
          end

          private

          def class_attribute?(node)
            key = node.key
            key.sym_type? && key.value == :class
          end

          def concatenated_string?(node)
            node.dstr_type? && node.children.size > 1
          end

          def plain_string_literals?(node)
            node.children.all?(&:str_type?)
          end

          def class_array(node)
            tokens = node.children.flat_map { |child| child.value.split }
            indent = line_indentation(node)
            entries = tokens.map { |token| "#{indent}  #{token}" }

            "%w[\n#{entries.join("\n")}\n#{indent}]"
          end

          def line_indentation(node)
            line = processed_source.lines[node.first_line - 1]
            line[/\A[ \t]*/]
          end
        end
      end
    end
  end
end
