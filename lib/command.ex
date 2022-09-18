defmodule CommandMessage do
  defstruct id: 0, method: "", params: []
end

defmodule Command do
  defguard is_effect(term) when term in [:sudden, :smooth]
  @type effect :: :sudden | :smooth
  @type duration :: non_neg_integer()
  @power_on_mode %{normal: 0, ct: 1, rgb: 2, hsv: 3, cf: 4, night: 5}

  def send_to(command, device) do
    json =
      command
      |> Map.from_struct()
      |> Map.put(:id, device.command_id)
      |> Jason.encode!()

    {:ok, socket} =
      :gen_tcp.connect(
        String.to_charlist(device.host),
        device.port,
        [:binary, {:active, false}]
      )

    :ok = :gen_tcp.send(socket, json <> "\r\n")
    result = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)

    Result.parse_result(result)
  end

  @spec build_command(binary(), list()) :: CommandMessage.t()
  def build_command(method, params)
      when is_binary(method) and is_list(params) do
    %CommandMessage{method: method, params: params}
  end

  @spec get_properties(list()) :: CommandMessage.t()
  def get_properties(properties) do
    build_command("get_prop", properties)
  end

  @spec set_temperature(1700..6500, effect(), duration()) :: CommandMessage.t()
  def set_temperature(temperature, effect, duration) when is_effect(effect) do
    build_command("set_ct_abx", [temperature, effect, duration])
  end

  @spec set_rgb(0..255, 0..255, 0..255, effect(), duration()) :: CommandMessage.t()
  def set_rgb(r, g, b, effect, duration) when is_effect(effect) do
    calculate_rgb(r, g, b)
    |> set_rgb(effect, duration)
  end

  @spec set_rgb(list(0..255), effect(), duration()) :: CommandMessage.t()
  def set_rgb([r, g, b], effect, duration) when is_effect(effect) do
    set_rgb(r, g, b, effect, duration)
  end

  @spec set_rgb(0..16_777_215, effect(), duration()) :: CommandMessage.t()
  def set_rgb(rgb, effect, duration) when is_effect(effect) do
    build_command("set_rgb", [rgb, effect, duration])
  end

  @spec set_hsv(0..359, 0..100, effect(), duration()) :: CommandMessage.t()
  def set_hsv(hue, saturation, effect, duration) when is_effect(effect) do
    build_command("set_hsv", [hue, saturation, effect, duration])
  end

  @spec set_bright(1..100, effect(), duration()) :: CommandMessage.t()
  def set_bright(brightness, effect, duration) when is_effect(effect) do
    build_command("set_bright", [brightness, effect, duration])
  end

  @spec set_power_on(effect(), duration(), atom()) :: CommandMessage.t()
  def set_power_on(effect, duration, mode \\ :normal) when is_effect(effect) do
    build_command("set_power", ["on", effect, duration, Map.get(@power_on_mode, mode)])
  end

  @spec set_power_off(effect(), duration()) :: CommandMessage.t()
  def set_power_off(effect, duration) when is_effect(effect) do
    build_command("set_power", ["off", effect, duration])
  end

  @spec toggle() :: CommandMessage.t()
  def toggle(), do: build_command("toggle", [])

  @spec set_default() :: CommandMessage.t()
  def set_default(), do: build_command("set_default", [])

  @spec start_color_flow(non_neg_integer(), 0..2, list(FlowExpression.t())) :: CommandMessage.t()
  def start_color_flow(count, action, flow_expressions) do
    flow_expression_string =
      flow_expressions
      |> Enum.map(&FlowExpression.to_string/1)
      |> Enum.join(", ")

    build_command("start_cf", [count, action, flow_expression_string])
  end

  @spec stop_color_flow() :: CommandMessage.t()
  def stop_color_flow(), do: build_command("stop_cf", [])

  def set_scene(method, val1, val2, val3) when is_binary(method) do
    build_command("set_scene", [val1, val2 | val3])
  end

  @spec start_timer_job(integer()) :: CommandMessage.t()
  def start_timer_job(minutes) do
    build_command("cron_add", [0, minutes])
  end

  @spec get_timer_job() :: CommandMessage.t()
  def get_timer_job() do
    build_command("cron_get", [0])
  end

  @spec stop_timer_job() :: CommandMessage.t()
  def stop_timer_job() do
    build_command("cron_del", [0])
  end

  @spec set_name(binary()) :: CommandMessage.t()
  def set_name(name), do: build_command("set_name", [name])

  @spec set_adjust(atom, atom) :: CommandMessage.t()
  def set_adjust(action, prop) when action == :circle and prop == :color do
    build_command("set_adjust", [action, prop])
  end

  def set_adjust(action, prop)
      when action in [:increase, :decrease, :circle] and prop in [:bright, :ct] do
    build_command("set_adjust", [action, prop])
  end

  def set_adjust(action, prop) do
    IO.puts("unsupported property: #{prop} for action: #{action}")
  end

  @spec adjust_brightness(-100..100, non_neg_integer()) :: CommandMessage.t()
  def adjust_brightness(percentage, duration) do
    build_command("adjust_bright", [percentage, duration])
  end

  @spec adjust_color_temperature(-100..100, non_neg_integer()) :: CommandMessage.t()
  def adjust_color_temperature(percentage, duration) do
    build_command("adjust_ct", [percentage, duration])
  end

  @spec adjust_color(-100..100, non_neg_integer()) :: CommandMessage.t()
  def adjust_color(percentage, duration) do
    build_command("adjust_color", [percentage, duration])
  end

  @spec set_music_on(String.t(), integer) :: CommandMessage.t()
  def set_music_on(host, port) do
    build_command("set_music", [1, host, port])
  end

  @spec set_music_off :: CommandMessage.t()
  def set_music_off do
    build_command("set_music", [0])
  end

  def calculate_rgb(r, g, b) do
    r * (256 * 256) + g * 256 + b
  end
end
