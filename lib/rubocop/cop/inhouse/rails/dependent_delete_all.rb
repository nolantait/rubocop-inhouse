# frozen_string_literal: true

require "pathname"

require_relative "association_callbacks"

module RuboCop
  module Cop
    module Inhouse
      module Rails
        # Checks for `dependent: :destroy` on associations.
        #
        # `:delete_all` and `:delete` skip instantiating and destroying each
        # record, which is faster. Use `:destroy` only when the associated
        # records have callbacks that must run. This cop inspects the
        # associated model and ignores associations whose records have destroy
        # callbacks or their own dependent associations.
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
            return if through_association?(node)
            return if target_callbacks?(node)

            message = format(MSG, replacement: replacement)
            dependent_destroy_values(node).each do |value|
              add_offense(value, message: message) do |corrector|
                corrector.replace(value, ":#{replacement}")
              end
            end
          end

          private

          def callback_index
            @callback_index ||= AssociationCallbacks.new(
              root: project_root,
              ruby_version: target_ruby_version.to_f,
              extra_asts: [processed_source.ast].compact
            )
          end

          def project_root
            @project_root ||= find_project_root
          end

          def find_project_root
            path = processed_source.file_path
            directory = File.directory?(path) ? path : File.dirname(path)
            start = Pathname.new(File.expand_path(directory))

            start.ascend do |candidate|
              return candidate.to_s if candidate.join("Gemfile").exist?
              return candidate.to_s if candidate.join(".git").exist?
            end

            Dir.pwd
          end

          def target_callbacks?(node)
            source = class_name_option(node) || inferred_class_name(node)
            return true unless source

            context = enclosing_class_name(node)
            resolved = callback_index.resolve(source, context)
            callback_index.callbacks?(resolved)
          end

          def class_name_option(node)
            value = option_value(node, :class_name)
            value.value.to_s if value&.str_type? || value&.sym_type?
          end

          def inferred_class_name(node)
            association_name = node.first_argument
            return nil unless association_name
            return nil if %i[sym str].none?(association_name.type)

            association_name.value.to_s.singularize.camelize
          end

          def enclosing_class_name(node)
            names = node.each_ancestor(:class, :module).map do |namespace|
              namespace.children.first.source.delete_prefix("::")
            end

            names.reverse.join("::")
          end

          def through_association?(node)
            !option_value(node, :through).nil?
          end

          def option_value(node, name)
            options = node.arguments.find(&:hash_type?)
            return nil unless options

            pair = options.pairs.find do |candidate|
              key = candidate.children.first
              key.sym_type? && key.value == name
            end
            pair&.children&.last
          end

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
