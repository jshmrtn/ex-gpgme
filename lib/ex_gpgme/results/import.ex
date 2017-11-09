defmodule ExGpgme.Results.Import do
  @moduledoc """
  Import struct for any key in an import.
  """

  @type t :: %__MODULE__{
    fingerprint: String.t,
  }

  @enforce_keys [
    :fingerprint,
  ]
  defstruct @enforce_keys
end
