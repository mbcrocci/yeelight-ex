defmodule CommandMessage do
  @derive[Poison.Encoder]
  defstruct id: 0, method: "", params: []
end

defmodule Command do
  def sendTo(command, device) do
    json = Poison.encode!(command)

    HTTPoison.post(device."Location", json, [{"Content-Type", "application/json"}])
    |> Result.parse_result()
  end

  @spec build_command(integer(), binary(), maybe_improper_list()) :: CommandMessage.t()
  def build_command(id, method, params)
      when is_integer(id) and is_binary(method) and is_list(params) do
    %CommandMessage{id: id, method: method, params: params}
  end

  @spec get_properties(maybe_improper_list()) :: CommandMessage.t()
  def get_properties(properties), do: build_command(1, "get_prop", properties)

  @spec set_temperature(integer(), integer(), integer()) :: CommandMessage.t()
  def set_temperature(temperature, effect, duration) do
    build_command(2, "set_cx_abx", [temperature, effect, duration])
  end

  @spec set_rgb(integer(), integer(), integer(), integer(), integer()) :: CommandMessage.t()
  def set_rgb(r, g, b, effect, duration) do
    # TODO: Correct this
    rgb = r + g + b
    set_rgb(rgb, effect, duration)
  end

  @spec set_rgb(list(), integer(), integer()) :: CommandMessage.t()
  def set_rgb([r, g, b], effect, duration) do
    set_rgb(r, g, b, effect, duration)
  end

  @spec set_rgb(integer(), integer(), integer()) :: CommandMessage.t()
  def set_rgb(rgb, effect, duration) do
    build_command(3, "set_rgb", [rgb, effect, duration])
  end

  def set_hsv(hue, saturation, effect, duration) do
    build_command(4, "set_hsv", [hue, saturation, effect, duration])
  end

  def set_brightness(brightness, effect, duration)
      when is_integer(brightness) and is_integer(effect) and is_integer(duration) do
    build_command(5, "set_brightness", [brightness, effect, duration])
  end

  def set_power(power, effect, duration) do
    build_command(6, "set_power", [power, effect, duration])
  end

  def toggle(), do: build_command(7, "toggle", [])

  def set_default(), do: build_command(8, "set_default", [])

  def start_color_flow(count, action, flowExpression)
      when is_integer(count) and is_binary(action) and is_binary(flowExpression) do
    # TODO: validate flowExpression
    build_command(9, "start_cf", [count, action, flowExpression])
  end

  def stop_color_flow(), do: build_command(10, "stop_cf", [])

  def set_scene(method, val1, val2, val3) when is_binary(method) do
    build_command(11, "set_scene", [val1, val2 | val3])
  end

  def start_timer_job(job_type, len) when is_binary(job_type) and is_integer(len) do
    build_command(12, "cron_add", [job_type, len])
  end

  def get_timer_job(job_type) when is_binary(job_type) do
    build_command(13, "cron_get", [job_type])
  end

  def stop_timer_job(job_type) when is_binary(job_type) do
    build_command(13, "cron_stop", [job_type])
  end
end
