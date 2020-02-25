defmodule CommandTest do
  use ExUnit.Case
  doctest CommandMessage

  test "builds a command message" do
    got = Command.build_command(1, "test", [])
    want = %CommandMessage{id: 1, method: "test", params: []}

    assert got == want
  end

  test "build a command message with arbitrary params" do
    got = Command.build_command(12, "test", [1, "asd", -1])

    want = %CommandMessage{
      id: 12,
      method: "test",
      params: [1, "asd", -1]
    }

    assert got == want
  end
end
