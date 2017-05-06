defmodule Versionary.Plug.PhoenixErrorHandlerTest do
  use ExUnit.Case
  use Plug.Test

  alias Versionary.Plug.PhoenixErrorHandler

  test "respond with a status of 406" do
    conn =
      conn(:get, "/")
      |> PhoenixErrorHandler.call

    assert_raise Phoenix.NotAcceptableError
  end
end
