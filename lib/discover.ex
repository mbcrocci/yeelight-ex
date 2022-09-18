defmodule Discover do
  use GenServer

  defmodule State do
    defstruct udp: nil, devices: [], handlers: [], port: nil
  end

  @port 1982
  @multicast_group {239, 255, 255, 250}
  @discover_message """
  M-SEARCH * HTTP/1.1\r\n
  HOST: 239.255.255.250:1982\r\n
  MAN: "ssdp:discover"\r\n
  ST: wifi_bulb\r\n
  """

  def start_link do
    GenServer.start_link(__MODULE__, @port, name: __MODULE__)
  end

  def start do
    start_link()
    GenServer.call(__MODULE__, :start)
  end

  def discover, do: GenServer.call(__MODULE__, :discover)

  def devices, do: GenServer.call(__MODULE__, :devices)

  @impl true
  def init(port) do
    {:ok, %State{:port => port}}
  end

  @impl true
  def handle_call(:start, _from, state) do
    {:reply, :ok,
     case state.udp do
       nil ->
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

       _exists ->
         state
     end}
  end

  def handle_call(:devices, _from, state) do
    {:reply, state.devices, state}
  end

  def handle_call(:send, _from, state) do
    :gen_udp.send(state.udp, @multicast_group, @port, discover())
    {:noreply, state}
  end

  @impl true
  def handle_info(:discover, state) do
    Process.send_after(self(), {:send, @discover_message}, (:rand.uniform() * 1000) |> round)
    Process.send_after(self(), :discover, 61000)
    {:noreply, state}
  end

  def handle_info({:send, discover}, state) do
    :gen_udp.send(state.udp, @multicast_group, @port, discover)
    {:noreply, state}
  end

  def handle_info(<<@discover_message, _::binary>>, state) do
    {:noreply, state}
  end

  def handle_info({:udp, _s, _ip, _port, <<"HTTP/1.1 200 OK\r\n", device::binary>>}, state) do
    {:noreply, device |> parse_device |> update_devices(state)}
  end

  def handle_info({:udp, _s, _ip, _port, <<"NOTIFY * HTTP/1.1\r\n", device::binary>>}, state) do
    {:noreply, device |> parse_device |> update_devices(state)}
  end

  def parse_device(body) do
    raw_params = String.split(body, ["\r\n", "\n"], trim: true)

    mapped_params =
      Enum.map(raw_params, fn x ->
        case String.split(x, ": ", parts: 2) do
          ["support", v] ->
            {:support, String.split(v, " ", trim: true)}

          [k, v] when k in ~w(bright color_mode ct rgb hue sat) ->
            {String.to_atom(String.downcase(k)), String.to_integer(v)}

          [k, v] ->
            {String.to_atom(String.downcase(k)), v}

          _ ->
            nil
        end
      end)

    map =
      Enum.reject(mapped_params, &(&1 == nil))
      |> Map.new()
      |> Map.delete(:"cache-control")
      |> Map.delete(:date)
      |> Map.delete(:ext)
      |> Map.delete(:server)
      |> Map.delete(:host)
      |> Map.delete(:nts)

    struct!(Device, map)
  end

  def update_devices(device, state) when is_map(device) do
    case state.devices |> Enum.any?(&(&1.id == device.id)) do
      false -> Map.update(state, :devices, state.devices, &[device | &1])
      true -> state
    end
  end
end
