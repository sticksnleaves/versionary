defmodule Versionary.Plug.ForwardTest do
  use ExUnit.Case
  use Plug.Test

  alias Versionary.Plug.Forward
  alias Versionary.Plug.VerifyHeader

  defmodule TestRouter1 do
    @moduledoc false

    use Plug.Router

    plug Versionary.Plug.VerifyHeader, versions: ["application/vnd.app.v1+json"]

    plug Versionary.Plug.Forward, to: Versionary.Plug.ForwardTest.TestRouter2,
                                  versions: ["application/vnd.app.v1+json"]

    plug :match
    plug :dispatch

    get "/" do
      conn
      |> assign(:versionary_spec, :test_router_1)
      |> send_resp(200, "OK")
    end

    match _, do: send_resp(conn, 404, "Not Found")
  end

  defmodule TestRouter2 do
    @moduledoc false

    use Plug.Router

    plug :match
    plug :dispatch

    get "/" do
      conn
      |> assign(:versionary_spec, :test_router_2)
      |> send_resp(200, "OK")
    end

    match _, do: send_resp(conn, 404, "Not Found")
  end

  @v1 "application/vnd.app.v1+json"
  @v2 "application/vnd.app.v2+json"

  describe "call/2" do
    test "forwards request to provieded plug" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", @v1)
        |> TestRouter1.call(TestRouter1.init([]))

      assert conn.assigns[:versionary_spec] == :test_router_2
    end

    test "prevents the original router from finishing" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", @v1)
        |> TestRouter1.call(TestRouter1.init([]))

      refute conn.assigns[:versionary_spec] == :test_router_1
    end

    test "forwards if header is validated" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", @v1)
        |> VerifyHeader.call(VerifyHeader.init([versions: [@v1]]))
        |> Forward.call(Forward.init([to: TestRouter2, versions: [@v1]]))

      assert conn.assigns[:versionary_spec] == :test_router_2
    end

    test "does not forward if header is not valid" do
      conn =
        conn(:get, "/")
        |> put_req_header("accept", @v2)
        |> VerifyHeader.call(VerifyHeader.init([versions: [@v1]]))
        |> Forward.call(Forward.init([to: TestRouter2, versions: [@v1]]))

      assert conn.assigns[:versionary_spec] == nil
    end
  end

  test "forwards if versions match" do
    conn =
      conn(:get, "/")
      |> put_req_header("accept", @v1)
      |> VerifyHeader.call(VerifyHeader.init([versions: [@v1]]))
      |> Forward.call(Forward.init([to: TestRouter2, versions: [@v1]]))

    assert conn.assigns[:versionary_spec] == :test_router_2
  end

  test "does not forward if versions do not match" do
    conn =
      conn(:get, "/")
      |> put_req_header("accept", @v1)
      |> VerifyHeader.call(VerifyHeader.init([versions: [@v1]]))
      |> Forward.call(Forward.init([to: TestRouter2, versions: [@v2]]))

    assert conn.assigns[:versionary_spec] == nil
  end
end
