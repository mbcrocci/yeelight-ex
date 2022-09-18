defmodule FlowExpression do
  defstruct duration: 0, mode: 1, ct: 0, brightness: 100, r: 0, g: 0, b: 0

  def to_string(%FlowExpression{mode: 1} = expression) do
    value = Command.calculate_rgb(expression.r, expression.g, expression.b)
    "#{expression.duration}, 1, #{value}, #{expression.brightness}"
  end

  def to_string(%FlowExpression{mode: 2} = expression) do
    "#{expression.duration}, 2, #{expression.ct}, #{expression.brightness}"
  end

  def to_string(%FlowExpression{mode: 7} = expression) do
    "#{expression.duration}, 7, 0, 0"
  end
end
