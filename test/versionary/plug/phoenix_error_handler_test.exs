defmodule Versionary.Plug.PhoenixErrorHandlerTest do
  use ExUnit.Case
  use Plug.Test

  alias Versionary.Plug.PhoenixErrorHandler

  test "respond with a status of 406" do
    assert_raise(Phoenix.NotAcceptableError, fn() ->
      conn(:get, "/")
      |> PhoenixErrorHandler.call
    end)
  end
end
