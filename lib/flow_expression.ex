defmodule Yeelight.FlowExpression.RGB do
  @moduledoc """
  ```elixir
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
  ]

  Yeelight.Command.start_color_flow(6, 0, color_flow)
  |> Yeelight.Command.send_to(hd(devices))
  ```
  """
  @type t :: %__MODULE__{
          duration: integer,
          brightness: integer,
          r: integer,
          g: integer,
          b: integer
        }
  defstruct duration: 0, brightness: 100, r: 0, g: 0, b: 0

  defimpl String.Chars, for: __MODULE__ do
    def to_string(expression) do
      value = Yeelight.Command.calculate_rgb(expression.r, expression.g, expression.b)
      "#{expression.duration}, 1, #{value}, #{expression.brightness}"
    end
  end
end

defmodule Yeelight.FlowExpression.ColorTemperature do
  @moduledoc """
  ```
  color_flow = [
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
  """
  @type t :: %__MODULE__{
          duration: integer,
          temperature: integer,
          brightness: integer
        }
  defstruct duration: 0, temperature: 0, brightness: 100

  defimpl String.Chars, for: __MODULE__ do
    def to_string(expression) do
      "#{expression.duration}, 2, #{expression.temperature}, #{expression.brightness}"
    end
  end
end

defmodule Yeelight.FlowExpression.Sleep do
  @moduledoc """
  ```
  color_flow = [
    %Yeelight.FlowExpression.Sleep{
      duration: 1000
    }
  ]

  Yeelight.Command.start_color_flow(6, 0, color_flow)
  |> Yeelight.Command.send_to(hd(devices))

  ```
  """
  @type t :: %__MODULE__{
          duration: integer
        }
  defstruct duration: 0

  defimpl String.Chars, for: __MODULE__ do
    def to_string(expression) do
      "#{expression.duration}, 7, 0, 0"
    end
  end
end
