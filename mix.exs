defmodule ExSnappy.MixProject do
  use Mix.Project
  @source_url "https://github.com/get-snappy/ex_snappy"

  def project do
    [
      app: :ex_snappy,
      description:
        "Phoenix and LiveView visual regression testing tool for the GetSnappy platform ",
      version: "0.4.2",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExSnappy",
      source_url: @source_url,
      docs: &docs/0,
      package: package()
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
    [
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Martin Feckie"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_uuid, "~> 1.2.1"},
      {:ex_doc, "> 0.0.0", only: :dev, runtime: false},
      {:floki, "> 0.0.0"},
      {:jason, "~> 1.4"},
      {:req, "~> 0.5"},
      {:plug, "~> 1.17", optional: true}
    ]
  end
end
