# Yeelight

This is a library to comunicate with yeelight lamps using Elixir.

For discovering the lights it uses a UPnP server that should be started using `Discover.start`"


```elixir

# start the discovery server
Discover.start

# Get the device list
devices = Discover.devices

# Send a command
Command.toggle |> Command.sendTo(device)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `yeelight` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:yeelight, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/yeelight](https://hexdocs.pm/yeelight).

