defmodule Yeelight.CommandTest do
  use ExUnit.Case
  alias Yeelight.Command
  alias Yeelight.FlowExpression
  alias Yeelight.Message

  test "builds a command message" do
    got = Command.build_command("test", [])
    want = %Message{id: 0, method: "test", params: []}

    assert got == want
  end

  test "build a command message with arbitrary params" do
    got = Command.build_command("test", [1, "asd", -1])

    want = %Message{
      id: 0,
      method: "test",
      params: [1, "asd", -1]
    }

    assert got == want
  end

  test "flow expression" do
    flow_expressions = [
      %FlowExpression{mode: 1, r: 200, g: 200, b: 200},
      %FlowExpression{mode: 2, ct: 3000}
    ]

    got = Command.start_color_flow(4, 0, flow_expressions)

    want = %Message{
      id: 0,
      method: "start_cf",
      params: [4, 0, "0, 1, 13158600, 100, 0, 2, 3000, 100"]
    }

    assert got == want
  end
end
