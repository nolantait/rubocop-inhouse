# frozen_string_literal: true

require "pathname"

require_relative "dry_initializer_index"

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
          dry_initializer_index.dry_initializer?(
            dry_initializer_index.name_for(namespace)
          )
        end

        def dry_initializer_index
          @dry_initializer_index ||= DryInitializerIndex.new(
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
