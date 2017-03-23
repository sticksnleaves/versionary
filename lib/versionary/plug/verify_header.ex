defmodule Versionary.Plug.VerifyHeader do
  @moduledoc """
  Use this plug to verify a version string in the header.

  If multiple versions are passed to this plug and at last one matches the
  version will be considered valid.

  ## Example

  ```
  plug Versionary.Plug.VerifyHeader, versions: ["application/vnd.app.v1+json"]
  ```

  By default, this plug will look at the `Accept` header for the version string
  to verify against. If you'd like to verify against another header specify the
  header you'd like to verify against in the `header` option.

  ## Example

  ```
  plug Versionary.Plug.VerifyHeader, header: "accept",
                                     versions: ["application/vnd.app.v1+json"]
  ```
  """

  import Plug.Conn

  @default_header_opt "accept"

  @doc false
  def init(opts) do
    %{
      header: opts[:header] || @default_header_opt,
      versions: opts[:versions]
    }
  end

  @doc false
  def call(conn, opts) do
    conn
    |> validate_version(opts)
  end

  # private

  defp get_version(conn, opts) do
    case get_req_header(conn, opts[:header]) do
      []        -> nil
      [version] -> version
    end
  end

  defp validate_version(conn, opts) do
    version = get_version(conn, opts)

    case Enum.member?(opts[:versions], version) do
      false -> put_private(conn, :validated_version, {version, :error})
      true  -> put_private(conn, :validated_version, {version, :ok})
    end
  end
end
