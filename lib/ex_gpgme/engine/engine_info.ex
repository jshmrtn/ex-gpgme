defmodule ExGpgme.Engine.EngineInfo do
  @moduledoc """
  Engine Info Struct.
  """

  @type t :: %__MODULE__{
    home_dir: nil | String.t,
    path: nil | String.t,
    protocol: ExGpgme.protocol,
    required_version: nil | String.t,
    version: nil | String.t,
  }

  @enforce_keys [
    :home_dir,
    :path,
    :protocol,
    :required_version,
    :version,
  ]
  defstruct @enforce_keys
end
