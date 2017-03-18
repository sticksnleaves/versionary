defmodule Versionary.Plug.VerifyHeader do
  @moduledoc """
  Use this plug to verify a version string in the header.

  ## Example

    plug Versionary.Plug.VerifyHeader, versions: ["application/vnd.app.v1+json"]

  ## Example

    plug Versionary.Plug.VerifyHeader, header: "accept",
                                       versions: ["application/vnd.app.v1+json"]
  """

  import Plug.Conn

  @default_header_opt "accept"

  def init(opts) do
    %{
      header: opts[:header] || @default_header_opt,
      versions: opts[:versions]
    }
  end

  def call(conn, opts) do
    conn
    |> verify_version(opts)
  end

  # private

  defp get_version(conn, opts) do
    case get_req_header(conn, opts[:header]) do
      []        -> nil
      [version] -> version
    end
  end

  defp verify_version(conn, opts) do
    version = get_version(conn, opts)
    verified = Enum.member?(opts[:versions], version)

    put_private(conn, :version_verified, verified)
  end
end
