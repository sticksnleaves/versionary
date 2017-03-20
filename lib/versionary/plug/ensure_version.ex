defmodule Versionary.Plug.EnsureVersion do
  @moduledoc """
  This plug ensures that a valid version was provided and has been verified
  on the request.

  If the version provided is not valid then the request will be halted and the
  module provied to `:handler` will be called. From there the handler can decide
  how to finish the request.

  If a handler isn't provided `Versionary.Plug.ErrorHandler.call/1` will be used
  as a default.

  ### Example

  ```
  plug Versionary.Plug.EnsureVersion, handler: SomeModule
  ```

  ## Handling specific versions

  If necessary you can tell the handler to only process the request for a
  specific version. If, for example, version 1 of your API has been
  decomissioned you may want to provide an error that is specific to that
  version.

  ### Example

  ```
  plug Versionary.Plug.VerifyHeader, versions: ["application/vnd.app.v2+json"]

  plug Versionary.Plug.EnsureVersion, handler: V1DecomissionedHandler,
                                      versions: ["application/vnd.app.v1+json"]
  ```

  The above example would halt and then handle the request by displaying a
  message informing the user that version 1 of the API has been decomissioned.

  As a rule of thumb, you should always provide a default handler. A default
  handler will process requests when no version or an unrecognized version
  has been supplied by the client. Default handlers provide no versions and
  are the last handler supplied.

  ### Example

  ```
  plug Versionary.Plug.VerifyHeader, versions: ["application/vnd.app.v2+json"]

  plug Versionary.Plug.EnsureVersion, handler: V1DecomissionedHandler,
                                      versions: ["application/vnd.app.v1+json"]

  # default handler
  plug Versionary.Plug.EnsureVersion, handler: DefaultHandler
  ```
  """

  require Logger

  import Plug.Conn

  @doc false
  def init(opts \\ []) do
    %{
      handler: opts[:handler] || Versionary.Plug.ErrorHandler,
      versions: opts[:versions]
    }
  end

  @doc false
  def call(conn, opts) do
    message = conn.private[:validated_version]

    case message do
      nil ->
        Logger.warn("Version has not been verified. Make sure Versionary.Plug.VerifyHeader has been called.")
        conn
      {_, :error} ->
        handle_error(conn, opts)
      {_, :ok} ->
        conn
    end
  end

  # private

  defp handle_error(conn, opts) do
    {version, :error} = conn.private[:validated_version]
    versions_opt = opts[:versions]

    if !is_list(versions_opt) || version in versions_opt do
      handler_opt = opts[:handler]

      conn = conn |> halt

      apply(handler_opt, :call, [conn])
    else
      conn
    end
  end
end
