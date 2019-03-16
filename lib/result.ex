# If the command is sucessfull the result pair
# will have the value "ok" or the value of properties
# for methods get_xx
# Example => {"id": 1, "result": "ok"}
#            {"id": 2, "result": ["on", "100"]}
#
# If the command failed the result pair will be an "error" object
# with the corresponding description
# Example => {"id": 3, "error": {"code": -1, "message": "unsupported method"}}
# -----------------------------------------------------------------------------------------

defmodule Result do
  def parse_result({:ok, response}) do
    response
    |> handle_result()
  end

  def parse_result({:error, reason}) do
    IO.inspect(reason)
    {:error, reason}
  end

  def handle_result(%{"id" => id, "result" => "ok"}), do: {:ok, id}
  def handle_result(%{"id" => id, "result" => properties}), do: {:ok, id, properties}
  def handle_result(%{"id" => id, "error" => error}), do: {:error, id, error["message"]}
end
