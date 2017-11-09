defmodule ExGpgme.Results do
  @moduledoc """
  Results Structs
  """

  @typedoc """
  PKA Trust
  """
  @type pka_trust :: :unknown |
    :bad |
    :okay |
    {:other, integer}
end
