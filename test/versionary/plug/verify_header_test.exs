defmodule Versionary.Plug.VerifyHeaderTest do
  use ExUnit.Case
  use Plug.Test

  alias Versionary.Plug.VerifyHeader

  @v1 "application/vnd.app.v1+json"
  @v2 "application/vnd.app.v2+json"

  @opts1 VerifyHeader.init([versions: [@v1]])
  @opts2 VerifyHeader.init([header: "x-version", versions: [@v1]])
  @opts3 VerifyHeader.init([versions: [@v1, @v2]])

  test "init/1 sets the header option to the value passed in" do
    assert @opts2[:header] == "x-version"
  end

  test "init/1 sets the default header if a value is not passed in" do
    assert @opts1[:header] == "accept"
  end

  test "init/1 sets the versions option to the value passed in" do
    assert @opts1[:versions] == [@v1]
  end

  test "verification fails if version is not present" do
    conn = conn(:get, "/") |> VerifyHeader.call(@opts1)

    assert conn.private[:version_verified] == false
  end

  test "verification fails if version is incorrect" do
    conn =
      conn(:get, "/")
      |> put_req_header("accept", @v2)
      |> VerifyHeader.call(@opts1)

    assert conn.private[:version_verified] == false
  end

  test "verification fails if header is incorrect" do
    conn =
      conn(:get, "/")
      |> put_req_header("accept", @v1)
      |> VerifyHeader.call(@opts2)

    assert conn.private[:version_verified] == false
  end

  test "verification succeeds if version matches" do
    conn =
      conn(:get, "/")
      |> put_req_header("accept", @v1)
      |> VerifyHeader.call(@opts1)

      assert conn.private[:version_verified] == true
  end

  test "verification succeeds if header and version match" do
    conn =
      conn(:get, "/")
      |> put_req_header("x-version", @v1)
      |> VerifyHeader.call(@opts2)

      assert conn.private[:version_verified] == true
  end

  test "verification succeeds if at least one version matches" do
    conn =
      conn(:get, "/")
      |> put_req_header("accept", @v1)
      |> VerifyHeader.call(@opts3)

      assert conn.private[:version_verified] == true
  end
end
