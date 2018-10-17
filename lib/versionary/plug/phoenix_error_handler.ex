if Code.ensure_loaded?(Phoenix) do
  defmodule Versionary.Plug.PhoenixErrorHandler do
    @moduledoc """
    An error handler for usage with Phoenix.

    When called this handler raise a `Phoenix.NotAcceptableError` triggering the
    `406.json` error view.
    """

    @behaviour Versionary.Plug.Handler

    def call(_conn) do
      raise Phoenix.NotAcceptableError,
        message: "no supported media type in accept header"
    end
  end
end
