defmodule Versionary.Plug.EnsureVersion do
  @moduledoc """
  This plug ensures that a valid version was provided and has been verified
  on the request.

  ## Example

    plug Versionary.Plug.EnsureVersion, handler: SomeModule
  """

  require Logger

  import Plug.Conn

  def init(opts \\ []) do
    %{
      handler: opts[:handler] || Versionary.Plug.ErrorHandler
    }
  end

  def call(conn, opts) do
    case conn.private[:version_verified] do
      true ->
        conn
      false ->
        handle_error(conn, opts)
      nil ->
        Logger.warn("Version has not been verified. Make sure Versionary.Plug.VerifyHeader has been called.")
        conn
    end
  end

  # private

  defp handle_error(conn, opts) do
    handler_opt = opts[:handler]

    conn = conn |> halt

    apply(handler_opt, :call, [conn])
  end
end
