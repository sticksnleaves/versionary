defmodule Versionary.Mixfile do
  use Mix.Project

  def project do
    [app: :versionary,
     name: "Versionary",
     description: "Elixir plug for handling API versioning",
     version: "0.3.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     dialyzer: [plt_add_apps: [:mime, :phoenix, :plug]],
     package: package(),
     preferred_cli_env: [
       coveralls: :test,
       "coveralls.detail": :test,
       "coveralls.html": :test,
       "coveralls.post": :test,
       "coveralls.travis": :test
      ],
     test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:mime, "~> 1.3"},
      {:plug, "~> 1.3"},
      # dev
      {:ex_doc, ">= 0.0.0", only: :dev},
      # test
      {:excoveralls, "~> 0.11", only: :test, runtime: false},
      {:phoenix,     ">= 1.2.0", only: :test},
      # dev/test
      {:dialyxir, "~> 1.0.0-rc", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [maintainers: ["Anthony Smith"],
     licenses: ["MIT"],
     links: %{
       GitHub: "https://github.com/sticksnleaves/versionary"
      }]
  end
end
