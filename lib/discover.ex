# Discover request:
#
# M-SEARCH * HTTP/1.1\r\n
# HOST: 239.255.255.250:1982\r\n
# MAN: "ssdp:discover"\r\n
# ST: wifi_bulb\r\n

# Discover response:
# HTTP/1.1 200 OK
# Cache-Control: max-age=3600
# Date:
# Ext:
# Location: yeelight://192.168.1.239:55443
# Server: POSIX UPnP/1.0 YGLC/1
# id: 0x000000000015243f
# model: color
# fw_ver: 18
# support: get_prop set_default set_power toggle set_bright start_cf stop_cf set_scene
# cron_add cron_get cron_del set_ct_abx set_rgb
# power: on
# bright: 100
# color_mode: 2
# ct: 4000
# rgb: 16711680
# hue: 100
# sat: 35
# name: my_bulb
#
# ---------------------------------------------------------------------------------------------
#
# Notification message will have the following format:
# {method_pair, params_pair}\r\n
#
# with params_pair beeing an object type with the following format:
# {params_val_pair1, params_val_pair2, ...}
#
# Example => {"method": "props", "params":{"Power": "on", "bright: on"}}\r\n
#
# ---------------------------------------------------------------------------------------------


defmodule State do
  defstruct udp: nil, devices: [], handlers: [], port: nil
end

defmodule Discover do
  use GenServer

  @port 1982
  @multicast_group {239, 255, 255, 250}

  def discover_message do
    """
    M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1982\r\nMAN: "ssdp:discover"\r\nST: wifi_bulb\r\n
    """
  end

  def start_link, do: GenServer.start_link(__MODULE__, @port, name: __MODULE__)

  def start, do: GenServer.call(__MODULE__, :start)

  def discover, do: GenServer.call(__MODULE__, :discover)

  def devices, do: GenServer.call(__MODULE__, :devices)

  @impl true
  def init(port) do
    {:ok, %State{:port => port}}
  end

  @impl true
  def handle_call(:start, _from, state) do
    udp_options = [
      :binary,
      add_membership: {@multicast_group, {0, 0, 0, 0}},
      multicast_if: {0, 0, 0, 0},
      multicast_loop: false,
      multicast_ttl: 2,
      reuseaddr: true
    ]

    {:ok, udp} = :gen_udp.open(state.port, udp_options)

    Process.send_after(self(), :discover, 0)

    Map.update(state, :udp, udp, fn _ -> udp end)
    {:reply, :ok, state}
  end

  def handle_call(:devices, _from, state) do
    {:reply, state.devices, state}
  end

  def handle_call(:discover, _from, state) do
    Process.send_after(self(), {:send, discover_message()}, (:rand.uniform() * 1000) |> round)
    Process.send_after(self(), :discover, 61000)
    {:noreply, state}
  end

  def handle_call(:send, _from, state) do
    :gen_udp.send(state.udp, @multicast_group, @port, discover())
    {:noreply, state}
  end

  @impl true
  def handle_info({:udp, _s, _ip, _port, <<"HTTP/1.1 200 OK", device :: binary>>}, state) do
    device
    |> parse_device()
    |> update_devices(state)
    {:noreply, state}
  end

  def handle_info({:udp, _s, _ip, _port, <<"NOTIFY * HTTP/1.1", device :: binary>>}, state) do
    device
    |> parse_device()
    |> update_devices(state)
    {:noreply, state}
  end

  def parse_device(response) do
    Poison.decode response, as: %Device{}
  end

  def update_devices(device, state) do
    case Enum.any?(&(&1.id == device.id)) do
      true -> Map.update(state, :devices, state.devices, &([device | &1]))
    end
    {:noreply, state}
  end
end
