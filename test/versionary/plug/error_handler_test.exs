defmodule Versionary.Plug.ErrorHandlerTest do
  use ExUnit.Case
  use Plug.Test

  alias Versionary.Plug.ErrorHandler

  test "respond with a status of 406" do
    conn =
      conn(:get, "/")
      |> ErrorHandler.call

    assert conn.status == 406
  end
end
