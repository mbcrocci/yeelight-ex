defmodule CommandMessage do
  @derive[Poison.Encoder]
  defstruct id: 0, method: "", params: []
end

defmodule Command do
  defguard is_effect(term) when term == "sudden" or term == "smooth"

  def sendTo(command, device) do
    json = Poison.encode!(command)

    uri =
      device.location
      |> String.replace("yeelight", "http")
      |> URI.parse()

    {:ok, socket} =
      :gen_tcp.connect(
        uri.host |> String.to_charlist(),
        uri.port,
        [:binary, {:active, false}]
      )

    :ok = :gen_tcp.send(socket, json <> "\r\n")
    result = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)

    result |> Result.parse_result()
  end

  @spec build_command(integer(), binary(), maybe_improper_list()) :: CommandMessage.t()
  def build_command(id, method, params)
      when is_integer(id) and is_binary(method) and is_list(params) do
    %CommandMessage{id: id, method: method, params: params}
  end

  @spec get_properties(maybe_improper_list()) :: CommandMessage.t()
  def get_properties(properties), do: build_command(1, "get_prop", properties)

  @spec set_temperature(integer(), binary(), integer()) :: CommandMessage.t()
  def set_temperature(temperature, effect, duration) when is_effect(effect) do
    build_command(2, "set_cx_abx", [temperature, effect, duration])
  end

  @spec set_rgb(integer(), integer(), integer(), binary(), integer()) :: CommandMessage.t()
  def set_rgb(r, g, b, effect, duration) when is_effect(effect) do
    rgb = r * (256 * 256) + g * 256 + b
    set_rgb(rgb, effect, duration)
  end

  @spec set_rgb(list(), integer(), integer()) :: CommandMessage.t()
  def set_rgb([r, g, b], effect, duration) when is_effect(effect) do
    set_rgb(r, g, b, effect, duration)
  end

  @spec set_rgb(integer(), binary(), integer()) :: CommandMessage.t()
  def set_rgb(rgb, effect, duration) when is_effect(effect) do
    build_command(3, "set_rgb", [rgb, effect, duration])
  end

  @spec set_hsv(integer(), integer(), binary(), integer()) :: CommandMessage.t()
  def set_hsv(hue, saturation, effect, duration) when is_effect(effect) do
    build_command(4, "set_hsv", [hue, saturation, effect, duration])
  end

  @spec set_brightness(integer(), binary(), integer()) :: CommandMessage.t()
  def set_brightness(brightness, effect, duration) when is_effect(effect) do
    build_command(5, "set_brightness", [brightness, effect, duration])
  end

  @spec set_power(binary(), binary(), integer()) :: CommandMessage.t()
  def set_power(power, effect, duration) when is_effect(effect) do
    build_command(6, "set_power", [power, effect, duration])
  end

  @spec toggle() :: CommandMessage.t()
  def toggle(), do: build_command(7, "toggle", [])

  @spec set_default() :: CommandMessage.t()
  def set_default(), do: build_command(8, "set_default", [])

  @spec start_color_flow(integer(), binary(), binary()) :: CommandMessage.t()
  def start_color_flow(count, action, flowExpression) do
    # TODO: validate flowExpression
    build_command(9, "start_cf", [count, action, flowExpression])
  end

  @spec stop_color_flow() :: CommandMessage.t()
  def stop_color_flow(), do: build_command(10, "stop_cf", [])

  def set_scene(method, val1, val2, val3) when is_binary(method) do
    build_command(11, "set_scene", [val1, val2 | val3])
  end

  @spec start_timer_job(binary(), integer()) :: CommandMessage.t()
  def start_timer_job(job_type, len) do
    build_command(12, "cron_add", [job_type, len])
  end

  @spec get_timer_job(binary()) :: CommandMessage.t()
  def get_timer_job(job_type) when is_binary(job_type) do
    build_command(13, "cron_get", [job_type])
  end

  @spec stop_timer_job(binary()) :: CommandMessage.t()
  def stop_timer_job(job_type) when is_binary(job_type) do
    build_command(13, "cron_stop", [job_type])
  end
end
