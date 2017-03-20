defmodule Versionary.Plug.EnsureVersionTest do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureLog

  alias Versionary.Plug.EnsureVersion
  alias Versionary.Plug.VerifyHeader

  defmodule TestHandler do
    @moduledoc false

    def call(conn) do
      conn
      |> Plug.Conn.assign(:versionary_spec, :not_supported)
      |> Plug.Conn.send_resp(406, "Not Supported")
    end
  end

  @v1 "application/vnd.app.v1+json"
  @v2 "application/vnd.app.v2+json"

  @opts EnsureVersion.init([handler: TestHandler])

  describe "init/1" do
    test "sets the handler option to the module that's passed in" do
      assert @opts[:handler] == TestHandler
    end

    test "sets the default handler if a value is not passed in" do
      opts = EnsureVersion.init()

      assert opts[:handler] == Versionary.Plug.ErrorHandler
    end
  end

  describe "call/2" do
    test "does not halt if version is valid" do
      conn =
        conn(:get, "/")
        |> Plug.Conn.put_req_header("accept", @v1)
        |> VerifyHeader.call(VerifyHeader.init(versions: [@v1]))
        |> EnsureVersion.call(@opts)

      refute conn.halted
    end

    test "does not halt if validation has not happened" do
      conn =
        conn(:get, "/")
        |> EnsureVersion.call(@opts)

      refute conn.halted
    end

    test "warning is logged if validation has not happened" do
      assert capture_log([level: :warn], fn ->
        conn(:get, "/") |> EnsureVersion.call(@opts)
      end) =~ "Version has not been verified."
    end

    test "does halt if version is invalid" do
      conn =
        conn(:get, "/")
        |> Plug.Conn.put_req_header("accept", @v2)
        |> VerifyHeader.call(VerifyHeader.init(versions: [@v1]))
        |> EnsureVersion.call(@opts)

      assert conn.halted
    end

    test "handler is called when version is not verified" do
      conn =
        conn(:get, "/")
        |> Plug.Conn.put_req_header("accept", @v2)
        |> VerifyHeader.call(VerifyHeader.init(versions: [@v1]))
        |> EnsureVersion.call(@opts)

      assert conn.assigns[:versionary_spec] == :not_supported
    end
  end
end
