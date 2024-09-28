## [Unreleased]

## [0.2.1] - 2024-09-27

- Fixes some indentation rules from 0.2.0
- Adds new `queue_migrate` folder to ignore

## [0.2.0] - 2024-08-22

- Adds cops from `rails-omasake-rubocop` that were good to better match Rails
  default
- Adds inherit: Exclude
- Removes suggesting extensions by default
- Removes requiring the gem from the rubocop file

## [0.1.9] - 2024-08-04

- Changes paths to allow for nested sub-apps such as
  `packages/accounts/app/views` for engines inside a rails root folder

## [0.1.8] - 2024-07-07

- Adds more liberal block delimiter options for phlex components
- Disables `Rails/DeprecatedActiveModelErrorsMethods` which conflicts with
  safe_params from `dry-rails`

## [0.1.7] - 2024-06-12

- Removes `RSpec/SpecFilePath`
- Adds `rubocop-factory_bot`
- Adds `rubocop-rspec_rails`

## [0.1.6] - 2024-05-27

- Removes `Style/StringHashKeys`, it was too annoying to disable in all the
  situations it was needed.
- Adds exclusion for `Rails/SaveBang` in configs
- Disables some cops in app/views for better Phlex support

## [0.1.4] - 2024-03-31

- Moves RSpecRails to proper namespace and places in Rails configs

## [0.1.3] - 2024-03-05

- Removes `Style/ConstantVisibility`, too verbose

## [0.1.0] - 2023-10-28

- Initial release


