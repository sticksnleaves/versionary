defmodule Versionary.Plug.ErrorHandler do
  @moduledoc """
  A default error handler that can be used for failed version verification.
  """

  import Plug.Conn

  @callback call(Plug.Conn.t) :: Plug.Conn.t

  def call(conn) do
    conn
    |> send_resp(406, "Not Acceptable")
  end
end
