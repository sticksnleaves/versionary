# Versionary

Add versioning to your Elixir Plug and Phoenix built API's

[![Build Status](https://travis-ci.org/sticksnleaves/versionary.svg?branch=master)](https://travis-ci.org/sticksnleaves/versionary)
[![Coverage Status](https://coveralls.io/repos/github/sticksnleaves/versionary/badge.svg?branch=master)](https://coveralls.io/github/sticksnleaves/versionary?branch=master)

## Installation

The package can be installed by adding `versionary` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [{:versionary, "~> 0.1.0"}]
end
```

## Usage

```elixir
def MyAPI.MyController do
  use MyAPI.Web, :controller

  plug Versionary.Plug.VerifyHeader, versions: ["application/vnd.app.v1+json"]

  plug Versionary.Plug.EnsureVersion, handler: MyAPI.MyErrorHandler
end
```

## Plug API

### [Versionary.Plug.VerifyHeader](https://hexdocs.pm/versionary/Versionary.Plug.VerifyHeader.html)

Verify that the version passed in to the request as a header is valid. If the
version is not valid then the request will be flagged.

This plug will not handle an invalid version.

#### Options

`versions` - a list of strings representing valid versions. If at least one of
the provided versions is valid then the request is considered valid.

`header` - the header used to provide the requested version (Default: `Accept`)

### [Versionary.Plug.EnsureVersion](https://hexdocs.pm/versionary/Versionary.Plug.EnsureVersion.html)

Checks to see if the request has been flagged with a valid version. If the
version is valid, the request continues, otherwise the request will halt and the
handler will be called to process the request.

#### Options

`handler` - the module used handle a request with an invalid version (Default: [Versionary.Plug.ErrorHandler](https://hexdocs.pm/versionary/Versionary.Plug.ErrorHandler.html))

### [Versionary.Plug.Handler](https://hexdocs.pm/versionary/Versionary.Plug.Handler.html)

Behaviour for handling requests with invalid versions. You can create your own
custom handler with this behaviour.
