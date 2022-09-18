defmodule Yeelight.FlowExpression do
  @type t :: %__MODULE__{
    duration: integer,
    mode: :rgb | :ct | :sleep,
    ct: integer,
    brightness: integer,
    r: integer,
    g: integer,
    b: integer
   }
  defstruct duration: 0, mode: :rgb, ct: 0, brightness: 100, r: 0, g: 0, b: 0

  def to_string(%__MODULE__{mode: :rgb} = expression) do
    value = Yeelight.Command.calculate_rgb(expression.r, expression.g, expression.b)
    "#{expression.duration}, 1, #{value}, #{expression.brightness}"
  end

  def to_string(%__MODULE__{mode: :ct} = expression) do
    "#{expression.duration}, 2, #{expression.ct}, #{expression.brightness}"
  end

  def to_string(%__MODULE__{mode: :sleep} = expression) do
    "#{expression.duration}, 7, 0, 0"
  end
end
