# ExGpgme

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/jshmrtn/ex-gpgme/master/LICENSE)
[![Build Status](https://travis-ci.org/jshmrtn/ex-gpgme.svg?branch=master)](https://travis-ci.org/jshmrtn/ex-gpgme)
[![Hex.pm Version](https://img.shields.io/hexpm/v/ex_gpgme.svg?style=flat)](https://hex.pm/packages/ex_gpgme)
[![InchCI](https://inch-ci.org/github/jshmrtn/ex-gpgme.svg?branch=master)](https://inch-ci.org/github/jshmrtn/ex-gpgme)

## Build Requirements

* `rust` - `brew install rust`
* `gettext` - `brew install gettext`
* `gpgme` deps - `brew install autoconf automake gettext gpgme openssl`

## Installation

The package can be installed by adding `ex_gpgme` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_gpgme, "~> 0.1.2"}
  ]
end
```
The docs can be found at [https://hexdocs.pm/ex_gpgme](https://hexdocs.pm/ex_gpgme).
