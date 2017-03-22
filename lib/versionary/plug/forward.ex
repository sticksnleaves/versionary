defmodule Versionary.Plug.Forward do
  @moduledoc """
  This plug will forward requests with a valid version to the plug provided.

  ### Example

  ```
  plug Versionary.Plug.Forward, to: MyAPI.Router.V1,
                                versions: ["application/vnd.app.v1+json"]
  ```
  """

  import Plug.Conn

  @doc false
  def init(opts) do
    %{
      options: opts[:options] || [],
      to: opts[:to],
      versions: opts[:versions]
    }
  end

  @doc false
  def call(conn, opts) do
    message = conn.private[:validated_version]

    case message do
      {_, :ok} ->
        handle_forward(conn, opts)
      _ ->
        conn
    end
  end

  # private

  defp handle_forward(conn, opts) do
    {version, :ok} = conn.private[:validated_version]
    to_opts = opts[:to]
    versions_opt = opts[:versions]
    options_opt = opts[:options]

    if is_list(versions_opt) && version in versions_opt do
      conn
      |> to_opts.call(to_opts.init(options_opt))
      |> halt
    else
      conn
    end
  end
end
