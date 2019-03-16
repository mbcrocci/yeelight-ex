defmodule ResultTes do
  use ExUnit.Case

  test "handle ok result" do
    assert Result.parse_result("""
           {"id": 1, "result": "ok"}
           """) ==
             {:ok, 1}
  end

  test "handle ok result with properties 1" do
    assert Result.parse_result("""
           {"id": 2, "result": ["on", "100"]}
           """) ==
             {:ok, 2, ["on", "100"]}
  end

  test "handle ok result with properties 2" do
    # get_rgb result
    assert Result.parse_result("""
           {"id": 5, "result": ["on", "245", "344", "123"]}
           """) ==
             {:ok, 5, ["on", "245", "344", "123"]}
  end

  test "handle error result 1" do
    assert Result.parse_result("""
           {"id": 3, "error": {"code": -1, "message": "unsupported method"}}
           """) == {:err, 3, "unsupported method"}
  end
  test "handle error result 2" do
    # This error message doens't exist
    assert Result.parse_result("""
           {"id": 4,"error": {"code": -10, "message": "Can't do it at this moment"}}
           """) == {:err, 4, "Can't do it at this moment"}
  end
end
