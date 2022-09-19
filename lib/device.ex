defmodule Yeelight.Device do
  @moduledoc false
  defstruct host: "",
            port: 0,
            id: "",
            model: "",
            fw_ver: 0,
            support: [],
            power: "",
            bright: 0,
            color_mode: 0,
            ct: 0,
            rgb: 0,
            hue: 0,
            sat: 0,
            name: "",
            command_id: 0
end
