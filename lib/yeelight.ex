defmodule Yeelight do
  @moduledoc """
  Documentation for Yeelight.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Yeelight.Discover
    ]

    opts = [strategy: :one_for_one, name: Yeelight.Discover.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
