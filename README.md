# ExGpgme

[![pipeline status](https://gitlab.airatel.com/joshmartin/ex-gpgme/badges/master/pipeline.svg)](https://gitlab.airatel.com/joshmartin/ex-gpgme/commits/master)


## Build Requirements

* `rust` - `brew install rust`
* `gettext` - `brew install gettext`
* `gpgme` deps - `brew install autoconf automake gettext gpgme openssl`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_gpgme` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_gpgme, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_gpgme](https://hexdocs.pm/ex_gpgme).
