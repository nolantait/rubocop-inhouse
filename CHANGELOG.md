## [Unreleased]

## [0.1.0] - 2023-10-28

- Initial release

## [0.1.3] - 2024-03-05

- Removes Style/ConstantVisibility, too verbose

## [0.1.4] - 2024-03-31

- Moves RSpecRails to proper namespace and places in Rails configs

## [0.1.6] - 2024-05-27

- Removes Style/StringHashKeys, it was too annoying to disable in all the
  situations it was needed.
- Adds exclusion for savebangs in configs
- Disables some cops in app/views for better Phlex support

## [0.1.7] - 2024-06-12

- Removes RSpec/SpecFilePath
- Adds rubocop-factory\_bot
- Adds rubocop-rspec\_rails

## [0.1.8] - 2024-07-07

- Adds more liberal block delimiter options for phlex components
- Disables Rails/DeprecatedActiveModelErrorsMethods which conflicts with
  safe_params from `dry-rails`
