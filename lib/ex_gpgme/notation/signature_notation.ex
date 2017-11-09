defmodule ExGpgme.Notation.SignatureNotation do
  @moduledoc """
  Signature Notation
  """

  @type t :: %__MODULE__{
    is_human_readable: boolean,
    is_critical: boolean,
    # flags: any
    name: String.t,
    value: String.t,
  }

  @enforce_keys [
    :is_human_readable,
    :is_critical,
    :name,
    :value,
  ]
  defstruct @enforce_keys
end
