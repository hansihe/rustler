# Rustler

[Documentation](https://docs.rs/crate/rustler) | [Getting Started](https://github.com/hansihe/Rustler/blob/master/README.md#getting-started) | [Example](https://github.com/hansihe/NifIo)

[![Build Status](https://travis-ci.org/hansihe/rustler.svg?branch=master)](https://travis-ci.org/hansihe/rustler)

Rustler is a library for writing Erlang NIFs in safe Rust code. That means
there should be no ways to crash the BEAM (Erlang VM). The library provides
facilities for generating the boilerplate for interacting with the BEAM,
handles encoding and decoding of Erlang terms, and catches rust panics before
they unwind into C.

The library provides functionality for both Erlang and Elixir, however Elixir
is favored as of now.

#### Features:
* Safety - The code you write in a Rust NIF should never be able to crash the BEAM.
* Interop - Decoding and encoding rust values into Erlang terms is as easy as a function call.
* Type composition - Making a Rust struct encodable and decodable to Erlang or Elixir can be done with a single attribute.
* Resource objects - Enables you to safely pass a reference to a Rust struct into Erlang code. The struct will be automatically dropped when it's no longer referenced.

#### Getting started
The easiest way of getting started is the [rustler elixir library](https://hex.pm/packages/rustler).

* Add the [rustler elixir library](https://hex.pm/packages/rustler) as a dependency of your project.
* Run `mix rustler.new` to generate a new NIF in your project. Follow the instructions.

NOTE: If you have previously used Rustler, you need to run `mix archive.uninstall rustler_installer.ez` to remove it before generating the NIF.

#### How it looks like
This is the code for a minimal NIF that adds two numbers and returns the result.
```rust
#[macro_use] extern crate rustler;
#[macro_use] extern crate lazy_static;

use rustler::{Env, Term, NifResult, Encoder};

mod atoms {
    rustler_atoms! {
        atom ok;
    }
}

rustler_export_nifs!(
    "Elixir.TestNifModule",
    [("add", 2, add)],
    None
);

fn add<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let num1: i64 = args[0].decode()?;
    let num2: i64 = args[1].decode()?;

    Ok((atoms::ok(), num1 + num2).encode(env))
}
```

#### Supported nif_version

Rustler uses `erlang:system_info(nif_version)` to detect the supported NIF version of the Erlang/OTP
system for which the NIF is to be compiled. It is possible to restrict the NIF version to an older
version if the NIF is to be compiled for an older version of Erlang. For example, if the target NIF
version should be `2.7` (Erlang/OTP 17.3), this can be defined using an environment variable:

```
RUSTLER_NIF_VERSION=2.7 mix compile
```

#### Building a binary on OSX
When running `cargo build` on OSX you may run into a linker error similar to this [Issue](https://github.com/hansihe/rustler/issues/151).
This linker error is occuring because Erlang has chosen to go with a flat namespace on OSX instead of 
the 2 layer namespace the OSX dynamic linker expects, for more information you read the [this](https://github.com/goertzenator/erlang_nif-sys/issues/3#issuecomment-234609123) comment on a similar issue.
To avoid this you need to pass some arguments to `rustc`. This can be done by adding cargo config.
```
$ mkdir .cargo
$ touch .cargo/config
```
and add the following to the the `config` file
```toml    
[target.x86_64-apple-darwin]
rustflags = [
    "-C", "link-arg=-undefined",
    "-C", "link-arg=dynamic_lookup",

```
#### Community

You can find us in `#rustler` on [freenode](http://freenode.net/) or [the elixir-lang slack](https://elixir-slackin.herokuapp.com/).

#### License

Licensed under either of

 * Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

##### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any
additional terms or conditions.
