# RuboCop Inhouse

This repository provides recommended RuboCop configuration and additional Cops
for use on [InHouse](https://inhouse.work) open source and internal Ruby
projects, and is the home of [InHouse's Ruby Style Guide](./STYLEGUIDE.md).

We set this repository up with inspiration from 
[Github's rubocop config](https://github.com/github/rubocop-github/tree/main).

## Usage

Add `rubocop-inhouse` to your Gemfile, along with its dependencies:

  ```ruby
  gem "rubocop-inhouse", require: false
  ```

Register the plugin in your `.rubocop.yml`. The generic Ruby rules are loaded
automatically; Rails projects should also inherit `config/rails.yml`:

  ```yaml
  plugins:
    - rubocop-inhouse

  inherit_gem:
    rubocop-inhouse:
      - config/rails.yml # Rails-specific rules and cops

  AllCops:
    NewCops: enable

  # The rest of your overrides here
  ```

On older RuboCop versions you can load the gem with `require:
rubocop-inhouse` instead of `plugins`.

For more granular control over which of RuboCop's rules are enabled for your
project, both from this gem and your own configs, consider using the
`DisabledByDefault: true` option under `AllCops` in your project's
`.rubocop.yml` file. This will disable all cops by default, and you can then
explicitly enable the ones you want by setting `Enabled: true`. See [the RuboCop
docs](https://docs.rubocop.org/rubocop/configuration.html#enabled) for more
information.

## InHouse rules and cops

| Rule | Cop |
| --- | --- |
| Do not use instance variables inside RSpec tests | `RSpec/InstanceVariable` |
| Prefer keyword arguments when multiple arguments have no natural ordering | `Inhouse/DryInitializerParams` |
| Use positive names | `Inhouse/PositiveNaming` |
| Use `dependent: :delete_all` when no callbacks are needed | `Inhouse/Rails/DependentDeleteAll` |

`Inhouse/DryInitializerParams` reports classes using `dry-initializer` that
declare more than one `param`. Its autocorrect changes `param` to `option` and
is marked unsafe because it changes the call signature.

`Inhouse/PositiveNaming` checks method names, variables, arguments, and
attribute declarations against the configurable `ForbiddenPrefixes` list.

`Inhouse/Rails/DependentDeleteAll` is enabled by `config/rails.yml`. Disable it
for an association when the associated records need callbacks:

  ```ruby
  has_many :comments, dependent: :destroy # rubocop:disable Inhouse/Rails/DependentDeleteAll
  ```
