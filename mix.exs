defmodule ExGpgme.Mixfile do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :ex_gpgme,
      version: "0.1.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      compilers: [:rustler] ++ Mix.compilers,
      rustler_crates: rustler_crates(),
      dialyzer: [ignore_warnings: "dialyzer.ignore-warnings"],
    ]
  end

  defp description do
    """
    Elixir NIF wrapper for `gpgme`.
    """
  end

  defp package do
    [
      name: :ex_gpgme,
      files: ["lib", "mix.exs", "README*", "LICENSE", "native"],
      maintainers: ["airatel Inc.", "Jonatan Männchen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jshmrtn/ex-gpgme"}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.10.1"},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:inch_ex, only: :docs, runtime: false},
      {:credo, "~> 0.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.4", only: [:dev, :test], runtime: false},
    ]
  end

  defp rustler_crates do
    [
      exgpgme: [
        path: "native/exgpgme",
        mode: (if Mix.env == :prod, do: :release, else: :debug),
      ],
    ]
  end
end
