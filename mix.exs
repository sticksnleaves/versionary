defmodule Versionary.Mixfile do
  use Mix.Project

  @source_url "https://github.com/sticksnleaves/versionary"
  @version "0.4.0"

  def project do
    [
      app: :versionary,
      name: "Versionary",
      version: @version,
      elixir: "~> 1.9",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mime, :phoenix, :plug]],
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.post": :test,
        "coveralls.travis": :test
      ],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:mime, "~>1.0 or ~> 2.0"},
      {:plug, "~> 1.3"},
      # dev
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      # test
      {:excoveralls, "~> 0.11", only: :test, runtime: false},
      {:phoenix, ">= 1.2.0", only: :test},
      # dev/test
      {:dialyxir, "~> 1.1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      description: "Elixir plug for handling API versioning",
      maintainers: ["Anthony Smith"],
      licenses: ["MIT"],
      links: %{
        GitHub: @source_url
      }
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "#v{@version}",
      formatters: ["html"]
    ]
  end
end
