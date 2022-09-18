defmodule Yeelight do
  @moduledoc """
  Documentation for Yeelight.
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Discover, [])
    ]

    opts = [strategy: :one_for_one, name: Discover.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
