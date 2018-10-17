defmodule Versionary.Mixfile do
  use Mix.Project

  def project do
    [app: :versionary,
     name: "Versionary",
     description: "Elixir plug for handling API versioning",
     version: "0.2.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
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
      {:excoveralls, "~> 0.6.0", only: :test, runtime: false},
      {:phoenix, ">= 1.2.0 and < 1.4.0", only: :test}
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
