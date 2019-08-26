# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :mime, :types, %{
  "application/vnd.app.v1+json" => [:v1],
  "application/vnd.app.v2+json" => [:v2]
}
