defmodule Yeelight.FlowExpression.RGB do
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
