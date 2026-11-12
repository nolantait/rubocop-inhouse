# frozen_string_literal: true

require "pathname"

require "active_support/core_ext/string/inflections"

module RuboCop
  module Cop
    module Inhouse
      module Rails
        # Builds an index of model classes that have callbacks which run when
        # their records are destroyed.
        #
        # The index is used to avoid suggesting a callback-free `dependent`
        # option when the associated records actually need their callbacks.
        # rubocop:disable-next Metrics/ClassLength
        class AssociationCallbacks
          DESTROY_CALLBACKS = %i[
            before_destroy
            after_destroy
            around_destroy
            after_destroy_commit
            after_commit
            after_rollback
          ].freeze

          ASSOCIATION_MACROS = %i[
            has_many
            has_one
            has_and_belongs_to_many
            belongs_to
          ].freeze

          SCAN_PATTERNS = [
            "**/app/**/*.rb",
            "**/lib/**/*.rb"
          ].freeze

          EXCLUDED_DIRECTORIES = %w[
            .git
            node_modules
            spec
            test
            tmp
            vendor
          ].freeze

          def initialize(root:, ruby_version:, extra_asts: [])
            @root = root
            @ruby_version = ruby_version
            @callbacks = {}
            @includes = Hash.new { |hash, key| hash[key] = [] }
            @superclasses = {}
            @results = {}
            @extra_asts = extra_asts

            build
          end

          # Returns true when the class is unknown or when destroying its
          # records runs callbacks. In both cases the cop should not suggest a
          # callback-free dependent option.
          def callbacks?(class_name)
            return true unless @callbacks.key?(class_name)

            compute_callbacks(class_name, {})
          end

          def resolve(source, context)
            return nil if source.nil?

            source = source.to_s.delete_prefix("::")
            context_parts = context.to_s.split("::")

            context_parts.length.downto(0) do |index|
              candidate = (context_parts[0...index] + [source]).join("::")
              return candidate if @callbacks.key?(candidate)
            end

            suffix_matches = @callbacks.keys.select do |key|
              key == source || key.end_with?("::#{source}")
            end
            suffix_matches.first if suffix_matches.one?
          end

          private

          def build
            each_source_file do |path|
              source = File.read(path)
              ast = parse(source, path)
              index_ast(ast, []) if ast
            rescue StandardError
              next
            end

            @extra_asts.each { |ast| index_ast(ast, []) if ast }
          end

          def each_source_file
            paths = SCAN_PATTERNS.flat_map do |pattern|
              Dir.glob(File.join(@root, pattern))
            end

            paths.uniq.sort.each do |path|
              relative_path = Pathname.new(path).relative_path_from(
                Pathname.new(@root)
              )
              next if relative_path.each_filename.any? do |part|
                EXCLUDED_DIRECTORIES.include?(part)
              end

              yield path
            end
          end

          def parse(source, path)
            processed = RuboCop::ProcessedSource.new(
              source,
              @ruby_version,
              path
            )
            processed.ast
          end

          def index_ast(node, namespace)
            return unless node.is_a?(RuboCop::AST::Node)

            if node.class_type? || node.module_type?
              name = qualified_name(node, namespace)
              record_class(name, node)
              namespace = name.split("::")
            end

            node.children.each do |child|
              index_ast(child, namespace)
            end
          end

          def record_class(name, node)
            @callbacks[name] = false unless @callbacks.key?(name)
            @callbacks[name] ||= destroy_callbacks?(node)

            includes = includes_in(node)
            @includes[name].concat(includes)
            @includes[name].uniq!

            superclass = superclass_source(node)
            @superclasses[name] ||= superclass if superclass
          end

          def qualified_name(node, namespace)
            source = node.children.first.source.delete_prefix("::")

            return source if source.include?("::") || namespace.empty?

            "#{namespace.join("::")}::#{source}"
          end

          def destroy_callbacks?(node)
            own_sends(node).any? do |send_node|
              DESTROY_CALLBACKS.include?(send_node.method_name) ||
                association_with_dependent?(send_node)
            end
          end

          def own_sends(node)
            node.each_descendant(:send).select do |send_node|
              send_node.each_ancestor(:class, :module).first.equal?(node)
            end
          end

          def association_with_dependent?(node)
            return false if ASSOCIATION_MACROS.none?(node.method_name)

            !dependent_value(node).nil?
          end

          def dependent_value(node)
            options = node.arguments.find(&:hash_type?)
            return nil unless options

            pair = options.pairs.find do |candidate|
              key = candidate.children.first
              key.sym_type? && key.value == :dependent
            end
            return nil unless pair

            value = pair.children.last
            return nil if value.nil_type? || value.false_type?

            value
          end

          def includes_in(node)
            own_sends(node).flat_map do |send_node|
              next [] unless send_node.method?(:include)

              send_node.arguments.filter_map do |argument|
                argument.source if argument.const_type?
              end
            end
          end

          def superclass_source(node)
            return nil unless node.class_type?

            superclass = node.children[1]
            superclass.source if superclass&.const_type?
          end

          def compute_callbacks(name, stack)
            return false if stack[name]
            return @results[name] if @results.key?(name)

            stack[name] = true
            result = @callbacks[name]
            result ||= superclass_callbacks?(name, stack)
            result ||= included_callbacks?(name, stack)
            stack.delete(name)

            @results[name] = result
          end

          def superclass_callbacks?(name, stack)
            superclass = @superclasses[name]
            return false unless superclass

            resolved = resolve(superclass, name)
            known_callbacks?(resolved, stack)
          end

          def included_callbacks?(name, stack)
            @includes[name].any? do |include_name|
              resolved = resolve(include_name, name)
              known_callbacks?(resolved, stack)
            end
          end

          def known_callbacks?(name, stack)
            return false unless name && @callbacks.key?(name)

            compute_callbacks(name, stack)
          end
        end
      end
    end
  end
end
