# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

See [`UPGRADE.md`](./UPGRADE.md) for additional help when upgrading to newer versions.

## [unreleased]

### Changed

* Use `impl Encoder` on more functions (in particular on `send`) (#572)

## [0.30.0] - 2023-10-11

### Added

* Return `Result<(), SendError>` from all `send` functions (#239, #563)

### Changed

* Drop support for `RUSTLER_NIF_VERSION`
* Deprecate `:rustler_crates` project configuration
* Mark `use Rustler` module configuration as compile-time
* Bump Rust edition to 2021
* Make `:rustler` a compile-time-only dependency (#516, #559)
* Use `enif_term_type` to implement `Term::get_type` (#538). Please check the
  `UPGRADE` documentation for necessary code changes.
* Raise default NIF version to 2.15

## [0.29.1] - 2023-06-30

### Fixed

* Exclude directories from external resources for compatibility with Elixir 1.15
  (#548, thanks @adrienmo)
* Fix `NifTaggedEnum` derived `Encoder` impl for named-field variants (#547,
  thanks @dylanburati)
* Remove `cfg!` directives in build.rs causing cross-compilation to fail (#555,
  thanks @fabriziosestito)

## [0.29.0] - 2023-06-22

### Added

* `ErlOption<T>` to provide an ergonomic option type for Erlang (#507, thanks @tatsuya6502)

### Changed

* Use Cargo features to define the NIF version level (#537), deprecating
  `RUSTLER_NIF_VERSION`

## [0.28.0] - 2023-04-24

### Added

* Support OTP 26 (#526, thanks @philss)
* Support tuples in NIF macro (#520, #527, thanks @denumerate and @philss)
* Support for `load_data_fun` to compute `load_data` at runtime (#413, thanks @kaaboaye)

### Changed

* Enhanced NIF macro error messages for invalid attributes (#525, thanks @philss)

## [0.27.0] - 2023-01-17

### BREAKING

* `MIX_ENV` is no longer considered for determining the build profile. Now, the
  profile defaults to `:release`. Use the `:mode` option to pick another
  profile explicitly. (#496)

### Added

* `ResourceArc::make_binary` for safe use of `enif_make_resource_binary` (#487)
* `OwnedBinary` is now `Sync` (#493)
* Specified MSRV to be 1.56.1.

### Fixed

* Documentation for `load` (#501, thanks @ishitatsuyuki)

### Changed

* Edition 2021 for the rustler mix template (#512, thanks @ayrat555)

## [0.26.0] - 2022-09-02

### Highlight

#### TaggedEnum

We added `TaggedEnum`, which is a generalized enum type (#440, thanks to @SeokminHong!). Example:

```rust
#[derive(NifTaggedEnum)]
pub enum TaggedEnum1 {
    Named { x: i32, y: i32 },
    String1(String),
    String2(String),
    Untagged,
}
```

On the Elixir side, the variants are represented as two-tuples `{tag::atom(),
inner::term()} | atom()`, where the `inner` term is

* a map for the variant `Named` in the example above
* a binary for the `String1` and `String2` variants

The `Untagged` variant is represented as the atom `:untagged` in Elixir.

### Added

* Added `Clone` and `Copy` for `TermType` (#476, thanks @dvic)
* Added `Env.whereis_pid()` (#456, thanks @Qqwy)

### Improved

* Use `&[impl Encoder]` for keys and values in `map_from_arrays()` to improve ergonomics (#453, thanks @SeokminHong)
* Improved encode/decode performance of TaggedEnum considerably (#482, thanks @cleaton)
* Test on OTP 25 (#455)

### Fixed

* Lifetime handling in `rustler_codegen` (#483, thanks @turion @SeokminHong and @neosimsim)
* Support multiple variants with same field names in TaggedEnum (#482, thanks @cleaton)
* Support .toml file extension for cargo config (#468, thanks @joshuataylor for the report in #467)
* Disambiguate `encode`/`decode` in generated code (#466, thanks @SeokminHong)
* Migrate CI to `erlef/setup-beam` (#457, thanks @SeokminHong)
* Documentation of the `schedule` flag for `nif` macro (#444)
* Improve documentation (#429, thanks @turion)

## [0.25.0] - 2022-04-11

### Added

* `NewBinary` now also available as `rustler::NewBinary` (thanks @ayrat555)
* `Term::map_from_pairs()` to conveniently build a map from a list -of pairs (thanks @philss)
* CI now also tests against macos

### Fixed

* Snake-case warening for auto-generated `RUSTLER_{}_field_{}` variables (renamed to `rustler_{}_field_{}`)

### Changed

* Abort compilation on macos if macos target configuration is missing

## [0.24.0] - 2022-02-24

### Added

* A `NewBinary` type to create binaries in Rust without going through
  `OwnedBinary`. This can improve performance. Thanks @dlesl!
* `TermType` derives `Eq` and `PartialEq`.

### Updated

* `rustler_mix`: Bumped required toml dependency to 0.6
* Bumped `rustler_sys` dependency to `~2.2`.

### Changed

* Rustler supports the latest 3 versions of Elixir and OTP. Currently, those
  are Elixir => 1.11 and OTP >= 22.

### Fixed

* Set library file extension based on the compile target, thanks @cocoa-xu!
* Relaxed Jason version requirement to ~> 1.0
* Various typos in the documentation, thanks @kianmeng!

## [0.23.0] - 2021-12-22

### Added

- `NifException` for using Elixir exception structs
- Hashing for term
- Hash and Equality for `Binary` and `OwnedBinary`

### Changed

- Rustler changed its supported range of OTP and Elixir versions. We aim to support the three newest versions of OTP and Elixir.
- The decoder for `Range` requires that `:step` equals `1`. The `:step` field was introduced with
  Elixir v1.12 and cannot be represented with Rust's `RangeInclusive`.
- NIF API bindings are generated using Rust

## Fixed

- `mix rustler.new` with Elixir v1.13
- Template config for `macos`
- Crash if metadata cannot be retrieved while compiling (#398)

## [0.22.2] - 2021-10-07

### Fixed

- Fixed a regression introduced with #386: `Rustler.Compiler.Config` called into `cargo` when `skip_compilation?` was set, breaking setups where cargo is not installed. Fixed with #389, thanks @karolsluszniak

## [0.22.1] - 2021-10-05

### Fixed

- [Breaking change] codegen-generated decoders always raise an error instead of
  causing the calling NIF to return an atom in some cases
- Fix codegen problem for untagged enums (#370)
- Fix handling local dependencies with `@external_resources` (#381)

## [0.22.0] - 2021-06-22

### Added

- Simple `Debug` impl for `rustler::Error`
- Support newtype and tuple structs for `NifTuple` and `NifRecord`
- `rustler::Error::Term` encoding an arbitrary boxed encoder, returning `{:error, term}`
- Generic encoder/decoder for `HashMap<T, U>`, where `T: Decoder` and `U: Decoder`

### Fixed

- Compilation time of generated decoders has been reduced significantly.
- Fixed a segfault caused by `OwnedEnv::send_and_clear`

### Changes

- Renamed `Pid` to `LocalPid` to clarify that it can't point to a remote process
- Dependencies have been updated.
- Derive macros have been refactored.
- Macros have been renamed and old ones have been deprecated:
  - `rustler_export_nifs!` is now `rustler::init!`
  - `rustler_atoms!` is now `rustler::atoms!`
  - `resource_struct_init!` is now `rustler::resource!`
- New `rustler::atoms!` macro removed the `atom` prefix from the name:

```rust
//
// Before
//
rustler::rustler_atoms! {
    atom ok;
    atom error;
    atom renamed_atom = "Renamed";
}

//
// After
//
rustler::atoms! {
    ok,
    error,
    renamed_atom = "Renamed",
}
```

- NIF functions can be initialized with a simplified syntax:

```rust
//
// Before
//
rustler::rustler_export_nifs! {
    "Elixir.Math",
    [
        ("add", 2, add)
    ],
    None
}

//
// After
//
rustler::init!("Elixir.Math", [add]);
```

- NIFs can be derived from regular functions, if the arguments implement `Decoder` and the return type implements `Encoder`:

```rust
//
// Before
//
fn add<'a>(env: Env<'a>, args: &[Term<'a>]) -> Result<Term<'a>, Error> {
    let num1: i64 = args[0].decode()?;
    let num2: i64 = args[1].decode()?;

    Ok((atoms::ok(), num1 + num2).encode(env))
}

//
// After
//
#[rustler::nif]
fn add(a: i64, b: i64) -> i64 {
  a + b
}
```

- `rustler::nif` exposes more options to configure a NIF were the NIF is defined:

```rust

#[rustler::nif(schedule = "DirtyCpu")]
pub fn dirty_cpu() -> Atom {
    let duration = Duration::from_millis(100);
    std::thread::sleep(duration);

    atoms::ok()
}

#[rustler::nif(name = "my_add")]
fn add(a: i64, b: i64) -> i64 {
  a + b
}
```

### Deprecations

The rustler compiler has been deprecated and will be removed with v1.0. NIFs
are no longer defined in `mix.exs`, but are configured with `use Rustler`.  See
the documentation for the `Rustler` module. To migrate to the new
configuration:

* Drop `:rustler` from the `:compilers` key in your `mix.exs` `project/0` function
* Drop `:rustler_crates` from `project/0` and move the configurations into the `use Rustler`
  of your NIF module or application config:

  ```elixir
  # config/dev.exs
  config :my_app, MyApp.Native,
    mode: :debug
  ```

For more information, see [the documentation](https://hexdocs.pm/rustler/0.22.0-rc.1/Rustler.html#module-configuration-options).

## [0.21.0] - 2019-09-07

### Added

- Support for OTP22.
- Rust linting with [clippy](https://github.com/rust-lang/rust-clippy).
- Support for decoding IOLists as binaries, `Term::decode_as_binary`.

### Changes

- `rustler_codegen` is now reexported by the `rustler` crate. Depending on the `rustler_codegen` crate is deprecated.
- `erlang_nif-sys` has been renamed to `rustler_sys` and vendored into the rustler repo.
- Replaced the hand-rolled TOML parser in `rustler_mix` with the `toml-elixir` package.
- Improve error messages for derived encoders/decoders.
- Rust `bool` now corresponds only to booleans (`false`, `true`) in Elixir. Previously, `nil` and `false` were both decodable to
  `bool`. To use the previous behaviour, a `Truthy` newtype was introduced.
