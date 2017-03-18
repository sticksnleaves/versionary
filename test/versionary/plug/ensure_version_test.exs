defmodule Versionary.Plug.EnsureVersionTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureLog

  alias Versionary.Plug.EnsureVersion

  defmodule TestHandler do
    @moduledoc false

    def call(conn) do
      conn
      |> Plug.Conn.assign(:versionary_spec, :not_supported)
      |> Plug.Conn.send_resp(406, "Not Supported")
    end
  end

  @opts EnsureVersion.init([handler: TestHandler])

  test "init/1 sets the handler option to the module that's passed in" do
    assert @opts[:handler] == TestHandler
  end

  test "init/1 sets the default handler is a module is not passed in" do
    opts = EnsureVersion.init()

    assert opts[:handler] == Versionary.Plug.ErrorHandler
  end

  test "request does not halt if version is verified" do
    conn =
      conn(:get, "/")
      |> put_private(:version_verified, true)
      |> EnsureVersion.call(@opts)

    refute conn.halted
  end

  test "request does not halt of verification has not happened" do
    conn =
      conn(:get, "/")
      |> EnsureVersion.call(@opts)

    refute conn.halted
  end

  test "warning is logged if verification has not happened" do
    assert capture_log([level: :warn], fn ->
      conn(:get, "/") |> EnsureVersion.call(@opts)
    end) =~ "Version has not been verified."
  end

  test "request does halt if version is not verified" do
    conn =
      conn(:get, "/")
      |> put_private(:version_verified, false)
      |> EnsureVersion.call(@opts)

    assert conn.halted
  end

  test "handler is called when version is not verified" do
    conn =
      conn(:get, "/")
      |> put_private(:version_verified, false)
      |> EnsureVersion.call(@opts)

    assert conn.assigns[:versionary_spec] == :not_supported
  end
end
