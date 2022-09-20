defmodule Yeelight.Message do
  @moduledoc false
  defstruct id: 0, method: "", params: []

  @type t :: %__MODULE__{
          id: integer,
          method: String.t(),
          params: list(integer | String.t())
        }
end
