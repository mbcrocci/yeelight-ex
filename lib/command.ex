defmodule Yeelight.Command do
  @moduledoc """
  create command and send to device
  ```
  Yeelight.Command.set_scene_auto_delay_off(1, 5)
  |> Yeelight.Command.send_to(device)
  ```
  """
  alias Yeelight.Message

  @type duration :: non_neg_integer() | nil
  @power_on_mode %{normal: 0, ct: 1, rgb: 2, hsv: 3, cf: 4, night: 5}

  def send_to(command, device) do
    json =
      command
      |> Map.from_struct()
      |> Map.put(:id, device.command_id)
      |> Jason.encode!()
      |> Kernel.<>("\r\n")

    {:ok, socket} =
      :gen_tcp.connect(
        String.to_charlist(device.host),
        device.port,
        [:binary, {:active, false}]
      )

    :ok = :gen_tcp.send(socket, json)
    result = :gen_tcp.recv(socket, 0)
    :ok = :gen_tcp.close(socket)

    Yeelight.Result.parse_result(result)
  end

  @spec build_command(binary(), list()) :: Message.t()
  def build_command(method, params)
      when is_binary(method) and is_list(params) do
    %Message{method: method, params: params}
  end

  @spec get_properties(list()) :: Message.t()
  def get_properties(properties) do
    build_command("get_prop", properties)
  end

  @spec set_temperature(1700..6500, duration()) :: Message.t()
  def set_temperature(temperature, duration) do
    build_command("set_ct_abx", [temperature | get_effect(duration)])
  end

  @spec set_rgb(0..255, 0..255, 0..255, duration()) :: Message.t()
  def set_rgb(r, g, b, duration \\ nil) do
    calculate_rgb(r, g, b)
    |> set_rgb(duration)
  end

  def set_rgb(rgb, duration \\ nil)
  @spec set_rgb(list(0..255), duration()) :: Message.t()
  def set_rgb([r, g, b], duration) do
    set_rgb(r, g, b, duration)
  end

  @spec set_rgb(0..0xFFFFFF, duration()) :: Message.t()
  def set_rgb(rgb, duration) do
    build_command("set_rgb", [rgb | get_effect(duration)])
  end

  @spec set_hsv(0..359, 0..100, duration()) :: Message.t()
  def set_hsv(hue, saturation, duration \\ nil) do
    build_command("set_hsv", [hue, saturation | get_effect(duration)])
  end

  @spec set_bright(1..100, duration()) :: Message.t()
  def set_bright(brightness, duration \\ nil) do
    build_command("set_bright", [brightness | get_effect(duration)])
  end

  @spec set_power_on(atom(), duration()) :: Message.t()
  def set_power_on(mode, duration \\ nil) do
    build_command("set_power", ["on"] ++ get_effect(duration) ++ [Map.get(@power_on_mode, mode)])
  end

  @spec set_power_off(duration()) :: Message.t()
  def set_power_off(duration \\ nil) do
    build_command("set_power", ["off" | get_effect(duration)])
  end

  @spec toggle() :: Message.t()
  def toggle(), do: build_command("toggle", [])

  @spec set_default() :: Message.t()
  def set_default(), do: build_command("set_default", [])

  @spec start_color_flow(non_neg_integer(), 0..2, list(map())) :: Message.t()
  def start_color_flow(count, action, flow_expressions) do
    build_command("start_cf", [count, action, get_flow_expression_string(flow_expressions)])
  end

  @spec stop_color_flow() :: Message.t()
  def stop_color_flow(), do: build_command("stop_cf", [])

  def set_scene_rgb(r, g, b, brightness) do
    set_scene_rgb(calculate_rgb(r, g, b), brightness)
  end

  def set_scene_rgb(rgb, brightness) do
    build_command("set_scene", ["color", rgb, brightness])
  end

  def set_scene_temperature(temperature, brightness) do
    build_command("set_scene", ["ct", temperature, brightness])
  end

  def set_scene_auto_delay_off(time, brightness) do
    build_command("set_scene", ["auto_delay_off", brightness, time])
  end

  def set_scene_color_flow(count, action, flow_expressions) do
    build_command("set_scene", ["cf", count, action, get_flow_expression_string(flow_expressions)])
  end

  def set_scene_hsv(hue, saturation, brightness) do
    build_command("set_scene", ["hsv", hue, saturation, brightness])
  end

  @spec start_timer_job(integer()) :: Message.t()
  def start_timer_job(minutes) do
    build_command("cron_add", [0, minutes])
  end

  @spec get_timer_job() :: Message.t()
  def get_timer_job() do
    build_command("cron_get", [0])
  end

  @spec stop_timer_job() :: Message.t()
  def stop_timer_job() do
    build_command("cron_del", [0])
  end

  @spec set_name(binary()) :: Message.t()
  def set_name(name), do: build_command("set_name", [name])

  @spec set_adjust(atom, atom) :: Message.t()
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

  @spec adjust_brightness(-100..100, non_neg_integer()) :: Message.t()
  def adjust_brightness(percentage, duration) do
    build_command("adjust_bright", [percentage, duration])
  end

  @spec adjust_color_temperature(-100..100, non_neg_integer()) :: Message.t()
  def adjust_color_temperature(percentage, duration) do
    build_command("adjust_ct", [percentage, duration])
  end

  @spec adjust_color(-100..100, non_neg_integer()) :: Message.t()
  def adjust_color(percentage, duration) do
    build_command("adjust_color", [percentage, duration])
  end

  @spec set_music_on(String.t(), integer) :: Message.t()
  def set_music_on(host, port) do
    build_command("set_music", [1, host, port])
  end

  @spec set_music_off :: Message.t()
  def set_music_off do
    build_command("set_music", [0])
  end

  def calculate_rgb(r, g, b) do
    r * (256 * 256) + g * 256 + b
  end

  defp get_flow_expression_string(flow_expressions) do
    Enum.map_join(flow_expressions, ", ", &to_string/1)
  end

  defp get_effect(duration) do
    if duration, do: [:smooth, duration], else: [:sudden, 0]
  end
end
