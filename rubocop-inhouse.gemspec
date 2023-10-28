# frozen_string_literal: true

require_relative "lib/rubocop/inhouse/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop-inhouse"
  spec.version = Rubocop::Inhouse::VERSION
  spec.authors = ["Nolan J Tait"]
  spec.email = ["nolanjtait@gmail.com"]

  spec.summary = "Rubocop configuration for InHouse projects"
  spec.description = spec.summary
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
    "STYLEGUIDE.md",
    "LICENSE.txt",
    "config/*.yml",
    "lib/**/*.rb",
  ]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "rubocop"
  spec.add_dependency "rubocop-capybara"
  spec.add_dependency "rubocop-performance"
  spec.add_dependency "rubocop-rails"
  spec.add_dependency "rubocop-rake"
  spec.add_dependency "rubocop-rspec"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
