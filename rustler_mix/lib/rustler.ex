defmodule Rustler do
  @moduledoc """
  Provides compile-time configuration for a NIF module.

  When used, Rustler expects the `:otp_app` as option.
  The `:otp_app` should point to the OTP application that
  the dynamic library can be loaded from.

  For example:

      defmodule MyNIF do
        use Rustler, otp_app: :my_nif
      end

  This allows the module to be configured like so:

      config :my_nif, MyNIF,
        crate: :my_nif,
        load_data: [1, 2, 3]

  ## Configuration options

    * `:cargo` - Specify how to envoke the rust compiler. Options are:
        - `:system` (default) - use `cargo` from the system (must be in `$PATH`)
        - `{:system, <channel>}` - use `cargo` from the system with the given channel.
          Specified as a string, passed directly to `cargo` (e.g. "+nightly").
        - `{:rustup, <version>}` - use `rustup` to specify which channel to use.
          Available options include: `:stable`, `:beta`, `:nightly`, or a string
          which specifies a specific version (e.g. `"1.39.0"`).
        - `{:bin, "/path/to/binary"}` - provide a specific path to `cargo`.

    * `:crate` - the name of the Rust crate, if different from your `otp_app`
      value. If you have more than one crate in your project, you will need to
      be explicit about which crate you intend to use.

    * `:env` - Specify a list of environment variables when envoking the compiler.

    * `:load_data` - Any valid term. This value is passed into the NIF when it is
      loaded (default: `0`)

    * `:load_from` - This option allows control over where the final artifact should be
      loaded from at runtime. By default the compiled artifact is loaded from the
      owning `:otp_app`'s `priv/native` directory. This option comes in handy in
      combination with the `:skip_compilation?` option in order to load pre-compiled
      artifacts. To override the default behaviour specify a tuple:
      `{:my_app, "priv/native/<artifact>"}`. Due to the way `:erlang.load_nif/2`
      works, the artifact should not include the file extension (i.e. `.so`, `.dll`).

    * `:mode` - Specify which mode to compile the crate with. If you do not specify
      this option, a default will be provide based on the `Mix.env()`:
      - When `Mix.env()` is `:dev` or `:test`, the crate will be compiled in `:debug` mode.
      - When `Mix.env()` is `:prod` or `:bench`, the crate will be compiled in `:release` mode.

    * `:target` - Specify a compile [target] triple.

    * `:target_dir`: Override the compiler output directory.

  Any of the above options can be passed directly into the `use` macro like so:

      defmodule MyNIF do
        use Rustler,
          otp_app: :my_nif,
          crate: :some_other_crate,
          load_data: :something
      end

  [target]: https://forge.rust-lang.org/release/platform-support.html
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      config = Rustler.Compiler.compile_crate(__MODULE__, opts)

      @load_from {config.otp_app, config.load_path}

      if config.lib do
        @load_data config.load_data
        @before_compile {Rustler, :__before_compile_nif__}
      else
        @before_compile Rustler
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def rustler_path do
        {otp_app, path} = @load_from
        Path.join(:code.priv_dir(otp_app), path)
      end
    end
  end

  defmacro __before_compile_nif__(_env) do
    quote do
      @on_load :rustler_init

      def rustler_path do
        # TODO: Parametrise, and keep all crates in the list
        {otp_app, path} = @load_from
        Path.join(:code.priv_dir(otp_app), path)
      end

      @doc false
      def rustler_init do
        # Remove any old modules that may be loaded so we don't get
        # {:error, {:upgrade, 'Upgrade not supported by this NIF library.'}}
        :code.purge(__MODULE__)
        load_path = String.to_charlist(rustler_path())
        data = @load_data
        :erlang.load_nif(load_path, data)
      end
    end
  end

  @doc false
  @spec rustler_version() :: binary()
  def rustler_version, do: "0.22.0"

  @doc """
  Supported NIF API versions.
  """
  def nif_versions,
    do: [
      '2.7',
      '2.8',
      '2.9',
      '2.10',
      '2.11',
      '2.12',
      '2.13',
      '2.14',
      '2.15',
      '2.16'
    ]
end
