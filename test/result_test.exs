defmodule Yeelight.ResultTes do
  use ExUnit.Case

  test "handle ok result" do
    assert Yeelight.Result.parse_result({
             :ok,
             """
             {"id": 1, "result": "ok"}
             """
           }) == {:ok, 1}
  end

  test "handle ok result with properties 1" do
    assert Yeelight.Result.parse_result({
             :ok,
             """
             {"id": 2, "result": ["on", "100"]}
             """
           }) == {:ok, 2, ["on", "100"]}
  end

  test "handle ok result with properties 2" do
    # get_rgb result
    assert Yeelight.Result.parse_result({
             :ok,
             """
             {"id": 5, "result": ["on", "245", "344", "123"]}
             """
           }) == {:ok, 5, ["on", "245", "344", "123"]}
  end

  test "handle error result 1" do
    assert Yeelight.Result.parse_result({
             :ok,
             """
             {"id": 3, "error": {"code": -1, "message": "unsupported method"}}
             """
           }) == {:error, 3, "unsupported method"}
  end

  test "handle error result 2" do
    # This error message doens't exist
    assert Yeelight.Result.parse_result({
             :ok,
             """
             {"id": 4,"error": {"code": -10, "message": "Can't do it at this moment"}}
             """
           }) == {:error, 4, "Can't do it at this moment"}
  end
end
