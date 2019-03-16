defmodule Yeelight do
  @moduledoc """
  Documentation for Yeelight.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Yeelight.hello()
      :world

  """
  def hello do
    :world
  end
end


# Notification message will have the following format:
# {method_pair, params_pair}\r\n
#
# with params_pair beeing an object type with the following format:
# {params_val_pair1, params_val_pair2, ...}
#
# Example => {"method": "props", "params":{"Power": "on", "bright: on"}}\r\n



