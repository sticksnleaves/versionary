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

  def init(opts), do: opts

  def call(conn, opts) do
    conn
    |> verify_version(opts)
  end

  # private

  defp get_header_opt(opts) do
    opts[:header]
    || Application.get_env(:versionary, :header, @default_header_opt)
  end

  defp get_version(conn, opts) do
    header_opt = get_header_opt(opts)

    case get_req_header(conn, header_opt) do
      []        -> nil
      [version] -> version
    end
  end

  defp get_versions_opt(opts) do
    opts[:versions]
    || Application.get_env(:versionary, :versions)
  end

  defp verify_version(conn, opts) do
    version = get_version(conn, opts)
    verified = Enum.member?(get_versions_opt(opts), version)

    put_private(conn, :version_verified, verified)
  end
end
