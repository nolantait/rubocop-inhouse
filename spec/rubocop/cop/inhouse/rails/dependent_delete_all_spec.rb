# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Inhouse::Rails::DependentDeleteAll, :config do
  it "registers an offense for dependent destroy" do
    expect_offense(<<~RUBY)
      has_many :comments, dependent: :destroy
                                     ^^^^^^^^ Use `dependent: :delete_all` unless the associated records need callbacks.
    RUBY
  end

  it "registers an offense for has_one with dependent destroy" do
    expect_offense(<<~RUBY)
      has_one :profile, dependent: :destroy
                                   ^^^^^^^^ Use `dependent: :delete_all` unless the associated records need callbacks.
    RUBY
  end

  it "autocorrects dependent destroy to delete_all" do
    expect_offense(<<~RUBY)
      has_many :comments, dependent: :destroy
                                     ^^^^^^^^ Use `dependent: :delete_all` unless the associated records need callbacks.
    RUBY

    expect_correction(<<~RUBY)
      has_many :comments, dependent: :delete_all
    RUBY
  end

  it "does not register an offense for dependent delete_all" do
    expect_no_offenses(<<~RUBY)
      has_many :comments, dependent: :delete_all
    RUBY
  end

  it "does not register an offense for other dependent options" do
    expect_no_offenses(<<~RUBY)
      has_many :comments, dependent: :nullify
    RUBY
  end

  it "does not register an offense for non-association calls" do
    expect_no_offenses(<<~RUBY)
      belongs_to :author, dependent: :destroy
    RUBY
  end
end
