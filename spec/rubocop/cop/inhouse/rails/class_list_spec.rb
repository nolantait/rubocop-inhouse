# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Inhouse::Rails::ClassList, :config do
  it "registers an offense for a class list split with line endings" do
    expect_offense(<<~RUBY)
      div(
        class: "rounded-md border shrink-0 opacity-0 " \\
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a `%w[]` array for class lists instead of concatenating string literals.
               "pointer-events-none transition-opacity"
      )
    RUBY

    expect_correction(<<~RUBY)
      div(
        class: %w[
          rounded-md
          border
          shrink-0
          opacity-0
          pointer-events-none
          transition-opacity
        ]
      )
    RUBY
  end

  it "registers an offense for implicit string concatenation" do
    expect_offense(<<~RUBY)
      div(class: "rounded-md border " "shrink-0")
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use a `%w[]` array for class lists instead of concatenating string literals.
    RUBY

    expect_correction(<<~RUBY)
      div(class: %w[
        rounded-md
        border
        shrink-0
      ])
    RUBY
  end

  it "registers an offense for a class key in a hash" do
    expect_offense(<<~RUBY)
      attrs = { class: "rounded-md " \\
                       ^^^^^^^^^^^^^^^ Use a `%w[]` array for class lists instead of concatenating string literals.
                       "border" }
    RUBY

    expect_correction(<<~RUBY)
      attrs = { class: %w[
        rounded-md
        border
      ] }
    RUBY
  end

  it "does not register an offense for an array of classes" do
    expect_no_offenses(<<~RUBY)
      div(class: %w[rounded-md border shrink-0])
      div(class: ["rounded-md", "border"])
    RUBY
  end

  it "does not register an offense for a single string" do
    expect_no_offenses(<<~RUBY)
      div(class: "rounded-md border shrink-0")
    RUBY
  end

  it "does not register an offense for interpolated strings" do
    expect_no_offenses(<<~RUBY)
      div(class: "rounded-md \#{active? ? "active" : ""}")
    RUBY
  end

  it "does not register an offense for other attributes" do
    expect_no_offenses(<<~RUBY)
      div(id: "item-1 " \\
              "item-2")
    RUBY
  end
end
