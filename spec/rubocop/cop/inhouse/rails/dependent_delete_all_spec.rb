# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Inhouse::Rails::DependentDeleteAll, :config do
  it "registers an offense for dependent destroy" do
    expect_offense(<<~RUBY)
      class Comment < ApplicationRecord
      end

      has_many :comments, dependent: :destroy
                                     ^^^^^^^^ Use `dependent: :delete_all` unless the associated records need callbacks.
    RUBY
  end

  it "registers an offense for has_one with dependent destroy" do
    expect_offense(<<~RUBY)
      class Profile < ApplicationRecord
      end

      has_one :profile, dependent: :destroy
                                   ^^^^^^^^ Use `dependent: :delete` unless the associated records need callbacks.
    RUBY
  end

  it "autocorrects has_many dependent destroy to delete_all" do
    expect_offense(<<~RUBY)
      class Comment < ApplicationRecord
      end

      has_many :comments, dependent: :destroy
                                     ^^^^^^^^ Use `dependent: :delete_all` unless the associated records need callbacks.
    RUBY

    expect_correction(<<~RUBY)
      class Comment < ApplicationRecord
      end

      has_many :comments, dependent: :delete_all
    RUBY
  end

  it "autocorrects has_one dependent destroy to delete" do
    expect_offense(<<~RUBY)
      class Profile < ApplicationRecord
      end

      has_one :profile, dependent: :destroy
                                   ^^^^^^^^ Use `dependent: :delete` unless the associated records need callbacks.
    RUBY

    expect_correction(<<~RUBY)
      class Profile < ApplicationRecord
      end

      has_one :profile, dependent: :delete
    RUBY
  end

  it "does not register an offense when the associated model has a destroy callback" do
    expect_no_offenses(<<~RUBY)
      class Comment < ApplicationRecord
        after_destroy :cleanup
      end

      has_many :comments, dependent: :destroy
    RUBY
  end

  it "does not register an offense when the associated model has dependent associations" do
    expect_no_offenses(<<~RUBY)
      class Comment < ApplicationRecord
        has_many :replies, dependent: :delete_all
      end

      has_many :comments, dependent: :destroy
    RUBY
  end

  it "does not register an offense when a callback comes from an included concern" do
    expect_no_offenses(<<~RUBY)
      module Cleanupable
        extend ActiveSupport::Concern

        included do
          after_destroy :cleanup
        end
      end

      class Comment < ApplicationRecord
        include Cleanupable
      end

      has_many :comments, dependent: :destroy
    RUBY
  end

  it "does not register an offense when a callback comes from a superclass" do
    expect_no_offenses(<<~RUBY)
      class ApplicationRecord
        after_destroy :cleanup
      end

      class Comment < ApplicationRecord
      end

      has_many :comments, dependent: :destroy
    RUBY
  end

  it "resolves an explicit class_name" do
    expect_no_offenses(<<~RUBY)
      class SpecialComment < ApplicationRecord
        before_destroy :cleanup
      end

      has_many :comments, class_name: "SpecialComment", dependent: :destroy
    RUBY
  end

  it "does not register an offense when the associated model is unknown" do
    expect_no_offenses(<<~RUBY)
      has_many :unknown_records, dependent: :destroy
    RUBY
  end

  it "does not register an offense for through associations" do
    expect_no_offenses(<<~RUBY)
      class Comment < ApplicationRecord
      end

      has_many :comments, through: :posts, dependent: :destroy
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

  it "does not register an offense for has_and_belongs_to_many" do
    expect_no_offenses(<<~RUBY)
      has_and_belongs_to_many :categories, dependent: :destroy
    RUBY
  end
end
