defmodule Versionary.Plug.VerifyHeader do
  @moduledoc """
  Use this plug to verify a version string in the header.

  This plug will add a `:version_verified` private key to the conn. This value
  will be `true` if the version has been verified. Otherwise, it will be
  `false`.

  Note that this plug will only flag the conn as having a valid or invalid
  version. If you would like to halt the request and handle an invalid version
  please see `Versionary.Plug.EnsureVersion`.

  ## Options

  * `:versions` - a list of strings representing valid versions. If at least one
                  of the provided versions is valid then the request is
                  considered valid.
  * `:accepts` - a list of strings or atoms representing versions registered as
                 MIME types. If at least one of the registered versions is valid
                 then the request is considered valid.
  * `:header` - the header used to provide the requested version (Default:
                `Accept`)

  ## Usage

  ```
  plug Versionary.Plug.VerifyHeader, versions: ["application/vnd.app.v1+json"]
  ```

  ## Multiple Versions

  You may pass multiple version strings to the `:versions` option. If at least
  one version matches the request will be considered valid.

  ```
  plug Versionary.Plug.VerifyHeader, versions: ["application/vnd.app.v1+json",
                                                "application/vnd.app.v2+json"]
  ```

  ## MIME Support

  It's also possible to verify versions against configured MIME types. If
  multiple MIME types are passed and at least one matches the version will be
  considered valid.

  ```
  config :mime, :types, %{
    "application/vnd.app.v1+json" => [:v1]
  }
  ```

  ```
  plug Versionary.Plug.VerifyHeader, accepts: [:v1]
  ```

  Please note that whenever you change media type configurations you must
  recompile the `mime` library.

  To force `mime` to recompile run `mix deps.clean --build mime`.

  ## Identifying Versions

  When a version has been verified this plug will add `:version` and
  `:raw_version` private keys to the conn. These keys will contain version that
  has been verified.

  The `:version` key may contain either the string version provided by the
  request or, if configured, the MIME extension. The `:raw_version` key will
  always contain the string version provided by the request.
  """

  import Plug.Conn

  @default_header_opt "accept"

  @doc false
  def init(opts) do
    %{
      accepts: Keyword.get(opts, :accepts, []),
      header: Keyword.get(opts, :header, @default_header_opt),
      versions: Keyword.get(opts, :versions, [])
    }
  end

  @doc false
  def call(conn, opts) do
    conn
    |> verify_version(opts)
    |> put_version(opts)
  end

  #
  # private
  #

  defp verify_version(conn, opts) do
    verified = Enum.member?(get_valid_versions(opts), get_req_version(conn, opts))

    put_private(conn, :version_verified, verified)
  end

  defp put_version(%{private: %{version_verified: true}} = conn, opts) do
    raw_version = get_req_version(conn, opts)

    version = Map.get(MIME.compiled_custom_types(), raw_version, raw_version)

    conn
    |> put_private(:version, version)
    |> put_private(:raw_version, raw_version)
  end

  defp put_version(conn, _opts) do
    conn
  end

  #
  # helpers
  #

  defp get_valid_versions(opts) do
    opts[:versions] ++ get_mime_versions(opts)
  end

  defp get_mime_versions(%{accepts: accepts}), do: do_get_mime_versions(accepts)
  defp get_mime_versions(_opts), do: []

  defp do_get_mime_versions([h|t]), do: [MIME.type(h)] ++ get_mime_versions(t)
  defp do_get_mime_versions([]), do: []
  defp do_get_mime_versions(nil), do: []

  defp get_req_version(conn, opts) do
    case get_req_header(conn, opts[:header]) do
      []        -> nil
      [version] -> version
    end
  end
end
