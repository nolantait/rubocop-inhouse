# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Inhouse::DryInitializerParams, :config do
  it "registers an offense for multiple params" do
    expect_offense(<<~RUBY)
      class Move
        extend Dry::Initializer

        param :source
        ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
        param :destination
        ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
      end
    RUBY
  end

  it "registers an offense for multiple params when including Dry::Initializer" do
    expect_offense(<<~RUBY)
      class Move
        include Dry::Initializer

        param :source
        ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
        param :destination
        ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
      end
    RUBY
  end

  it "autocorrects params to options" do
    expect_offense(<<~RUBY)
      class Move
        extend Dry::Initializer

        param :source
        ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
        param :destination
        ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Move
        extend Dry::Initializer

        option :source
        option :destination
      end
    RUBY
  end

  it "does not register an offense for a single param" do
    expect_no_offenses(<<~RUBY)
      class Move
        extend Dry::Initializer

        param :source
        option :destination
      end
    RUBY
  end

  it "does not register an offense for options" do
    expect_no_offenses(<<~RUBY)
      class Move
        extend Dry::Initializer

        option :source
        option :destination
      end
    RUBY
  end

  it "does not register an offense outside a dry-initializer class" do
    expect_no_offenses(<<~RUBY)
      class Move
        param :source
        param :destination
      end
    RUBY
  end

  it "registers an offense when inheriting from a dry-initializer class" do
    expect_offense(<<~RUBY)
      class Base
        extend Dry::Initializer
      end

      class Move < Base
        param :source
        ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
        param :destination
        ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
      end
    RUBY
  end

  it "registers an offense when inheriting from a class including Dry::Initializer" do
    expect_offense(<<~RUBY)
      class Base
        include Dry::Initializer
      end

      class Move < Base
        param :source
        ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
        param :destination
        ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
      end
    RUBY
  end

  it "registers an offense through multiple levels of inheritance" do
    expect_offense(<<~RUBY)
      class Base
        extend Dry::Initializer
      end

      class Middle < Base
      end

      class Move < Middle
        param :source
        ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
        param :destination
        ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
      end
    RUBY
  end

  it "registers an offense for namespaced subclasses" do
    expect_offense(<<~RUBY)
      module Transport
        class Base
          extend Dry::Initializer
        end

        class Move < Base
          param :source
          ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
          param :destination
          ^^^^^ Prefer `option` over `param` when multiple arguments have no natural ordering.
        end
      end
    RUBY
  end

  it "does not register an offense when inheriting from a non-dry-initializer class" do
    expect_no_offenses(<<~RUBY)
      class Base
      end

      class Move < Base
        param :source
        param :destination
      end
    RUBY
  end

  it "does not count params from a nested class" do
    expect_no_offenses(<<~RUBY)
      class Move
        extend Dry::Initializer

        param :source

        class Nested
          extend Dry::Initializer

          param :destination
        end
      end
    RUBY
  end
end
