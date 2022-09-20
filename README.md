# Yeelight

This is a library to comunicate with yeelight lamps using Elixir.

For discovering the lights it uses a UPnP server that should be started using `Discover.start`"


```elixir

# start the discovery server
Yeelight.Discover.start

# Get the device list
devices = Yeelight.Discover.devices

# Send a command
Yeelight.Command.toggle |> Yeelight.Command.send_to(device)
```

set color flow sequence
```elirix
color_flow = [
  %Yeelight.FlowExpression.RGB{
    duration: 1000,
    r: 255,
    brightness: 100
  },
  %Yeelight.FlowExpression.RGB{
    duration: 1000,
    g: 255,
    brightness: 100
  },
  %Yeelight.FlowExpression.RGB{
    duration: 1000,
    b: 255,
    brightness: 100
  },
  %Yeelight.FlowExpression.ColorTemperature{
    duration: 1000,
    temperature: 6500,
    brightness: 100
  },
  %Yeelight.FlowExpression.ColorTemperature{
    duration: 1000,
    temperature: 1800,
    brightness: 100
  }
]

Yeelight.Command.start_color_flow(6, 0, color_flow)
|> Yeelight.Command.send_to(hd(devices))
```

## Installation

The package can be installed
by adding `yeelight` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:yeelight, "~> 0.2.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/yeelight](https://hexdocs.pm/yeelight).

## TODO
- Finish all possible commands
