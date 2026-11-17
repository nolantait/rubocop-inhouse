# frozen_string_literal: true

require "pathname"

require "active_support/core_ext/string/inflections"

module RuboCop
  module Cop
    module Inhouse
      # Builds an index of classes and modules that use `dry-initializer`,
      # either directly or through inheritance or included modules.
      #
      # RuboCop analyzes one file at a time, so a class that inherits from a
      # `dry-initializer` base class in another file would otherwise look like
      # it does not use `dry-initializer` at all.
      # rubocop:disable-next Metrics/ClassLength
      class DryInitializerIndex
        DRY_INITIALIZER_MIXINS = %i[include extend].freeze

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
          @direct = {}
          @includes = Hash.new { |hash, key| hash[key] = [] }
          @superclasses = {}
          @results = {}
          @extra_asts = extra_asts

          build
        end

        def dry_initializer?(name)
          return false unless name
          return false unless @direct.key?(name)

          compute(name, {})
        end

        def name_for(node)
          ancestors = node.each_ancestor(:class, :module).to_a.reverse
          names = ancestors.map do |ancestor|
            ancestor.children.first.source.delete_prefix("::")
          end
          names << node.children.first.source.delete_prefix("::")

          names.join("::")
        end

        private

        def build
          each_source_file do |path|
            source = File.read(path)
            ast = parse(source, path)
            index_ast(ast) if ast
          rescue StandardError
            next
          end

          @extra_asts.each { |ast| index_ast(ast) if ast }
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

        def index_ast(node)
          return unless node.is_a?(RuboCop::AST::Node)

          if node.class_type? || node.module_type?
            record_namespace(name_for(node), node)
          end

          node.children.each { |child| index_ast(child) }
        end

        def record_namespace(name, node)
          @direct[name] ||= false
          @direct[name] ||= uses_dry_initializer?(node)
          @includes[name].concat(included_names(node)).uniq!

          superclass = superclass_name(node)
          @superclasses[name] ||= superclass if superclass
        end

        def uses_dry_initializer?(node)
          own_sends(node).any? do |send_node|
            next false if DRY_INITIALIZER_MIXINS.none?(send_node.method_name)

            send_node.arguments.any? do |argument|
              argument.source.start_with?("Dry::Initializer")
            end
          end
        end

        def included_names(node)
          own_sends(node).flat_map do |send_node|
            next [] unless send_node.method?(:include)

            send_node.arguments.filter_map do |argument|
              constant_path(argument)
            end
          end
        end

        def superclass_name(node)
          return nil unless node.class_type?

          constant_path(node.children[1])
        end

        def constant_path(node)
          return nil unless node

          case node.type
          when :const
            node.source.delete_prefix("::")
          when :send
            receiver = node.receiver
            method_name = node.method_name.to_s
            return nil unless receiver && node.arguments.empty?
            return nil unless method_name.match?(/\A[A-Z]/)

            parent = constant_path(receiver)
            "#{parent}::#{method_name}" if parent
          end
        end

        def own_sends(node)
          node.each_descendant(:send).select do |send_node|
            send_node.each_ancestor(:class, :module).first.equal?(node)
          end
        end

        def compute(name, stack)
          return false if stack[name]
          return @results[name] if @results.key?(name)

          stack[name] = true
          result = @direct[name]
          result ||= inherited_dry_initializer?(name, stack)
          result ||= included_dry_initializer?(name, stack)
          stack.delete(name)

          @results[name] = result
        end

        def inherited_dry_initializer?(name, stack)
          superclass = @superclasses[name]
          return false unless superclass

          resolved = resolve(superclass, name)
          known_dry_initializer?(resolved, stack)
        end

        def included_dry_initializer?(name, stack)
          @includes[name].any? do |include_name|
            resolved = resolve(include_name, name)
            known_dry_initializer?(resolved, stack)
          end
        end

        def known_dry_initializer?(name, stack)
          return false unless name && @direct.key?(name)

          compute(name, stack)
        end

        def resolve(source, context)
          return nil if source.nil?

          source = source.to_s.delete_prefix("::")
          context_parts = context.to_s.split("::")

          context_parts.length.downto(0) do |index|
            candidate = (context_parts[0...index] + [source]).join("::")
            return candidate if known_class?(candidate)
          end

          suffix_matches = @direct.keys.select do |key|
            key == source || key.end_with?("::#{source}")
          end
          suffix_matches.first if suffix_matches.one?
        end

        def known_class?(name)
          return true if @direct.key?(name)

          if name.include?("::")
            index_external_constant(name)
            return @direct.key?(name)
          end

          false
        end

        def index_external_constant(name)
          @external_paths ||= {}
          path = external_source_path(name)
          return if path.nil? || @external_paths[path]

          @external_paths[path] = true
          ast = parse(File.read(path), path)
          index_ast(ast) if ast
        rescue StandardError
          nil
        end

        def external_source_path(name)
          relative_path = "#{name.underscore}.rb"

          $LOAD_PATH.each do |directory|
            path = File.join(directory, relative_path)
            return path if File.file?(path)
          end

          nil
        end
      end
    end
  end
end
