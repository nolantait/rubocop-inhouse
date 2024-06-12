# frozen_string_literal: true

require_relative "lib/rubocop/inhouse/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop-inhouse"
  spec.version = Rubocop::Inhouse::VERSION
  spec.authors = ["Nolan J Tait"]
  spec.email = ["nolanjtait@gmail.com"]

  spec.summary = "Rubocop configuration for InHouse projects"
  spec.description = "This is the rubocop configuration we use at " \
                     "inhouse.work for all our projects"
  spec.homepage = "https://github.com/nolantait/rubocop-inhouse"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released. The `git
  # ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir[
    "README.md",
    "LICENSE.txt",
    "config/*.yml",
    "lib/**/*.rb",
  ]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "rubocop", ">= 1.5"
  spec.add_dependency "rubocop-capybara", ">= 2.1"
  spec.add_dependency "rubocop-factory_bot", ">= 2.2"
  spec.add_dependency "rubocop-performance", ">= 1.1"
  spec.add_dependency "rubocop-rails", ">= 2.2"
  spec.add_dependency "rubocop-rake", ">= 0.6"
  spec.add_dependency "rubocop-rspec", ">= 2.2"
  spec.add_dependency "rubocop-rspec_rails", ">= 2.2"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
