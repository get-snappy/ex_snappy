defmodule ExSnappy.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_snappy,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExSnappy",
      source_url: "",
      docs: &docs/0
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExSnappy.Application, []}
    ]
  end

  defp docs do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_uuid, "~> 1.2.1"},
      {:ex_doc, "0.37.3", only: :dev, runtime: false},
      {:floki, "0.37.1"},
      {:jason, "~> 1.4"},
      {:req, "~> 0.5"},
      {:plug, "~> 1.17", optional: true}
    ]
  end
end
