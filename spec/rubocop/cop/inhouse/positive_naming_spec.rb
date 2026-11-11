# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Inhouse::PositiveNaming, :config do
  it "registers an offense for a negatively named method" do
    expect_offense(<<~RUBY)
      def not_deleted?
          ^^^^^^^^^^^^ Avoid negative naming for `not_deleted?`; use a positive name instead.
      end
    RUBY
  end

  it "registers an offense for a negatively named singleton method" do
    expect_offense(<<~RUBY)
      def self.not_ready?
               ^^^^^^^^^^ Avoid negative naming for `not_ready?`; use a positive name instead.
      end
    RUBY
  end

  it "registers an offense for a negatively named local variable" do
    expect_offense(<<~RUBY)
      not_ready = true
      ^^^^^^^^^ Avoid negative naming for `not_ready`; use a positive name instead.
    RUBY
  end

  it "registers an offense for a negatively named instance variable" do
    expect_offense(<<~RUBY)
      @not_ready = true
      ^^^^^^^^^^ Avoid negative naming for `not_ready`; use a positive name instead.
    RUBY
  end

  it "registers an offense for a negatively named attribute" do
    expect_offense(<<~RUBY)
      attr_reader :not_ready
                  ^^^^^^^^^^ Avoid negative naming for `not_ready`; use a positive name instead.
    RUBY
  end

  it "registers an offense for a negatively named method argument" do
    expect_offense(<<~RUBY)
      def ready?(not_ready)
                 ^^^^^^^^^ Avoid negative naming for `not_ready`; use a positive name instead.
      end
    RUBY
  end

  it "does not register an offense for a positive name" do
    expect_no_offenses(<<~RUBY)
      def active?
        true
      end

      attr_reader :unpopped

      def pop(popped)
        popped
      end

      notify = true
    RUBY
  end

  context "with custom forbidden prefixes" do
    let(:cop_config) { { "ForbiddenPrefixes" => ["missing_"] } }

    it "uses the configured prefixes" do
      expect_offense(<<~RUBY)
        def missing_avatar?
            ^^^^^^^^^^^^^^^ Avoid negative naming for `missing_avatar?`; use a positive name instead.
        end

        def not_deleted?
          true
        end
      RUBY
    end
  end
end
