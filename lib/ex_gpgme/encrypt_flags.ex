defmodule ExGpgme.EncryptFlags do
  @moduledoc """
  Holds encryption flags
  """

  @typedoc """
  Flags for encrpytion functions
  """
  @type flag :: :always_trust |
    :expect_sign |
    :no_compress |
    :no_encrypt_to |
    :prepare |
    :symmetric |
    :throw_keyids |
    :wrap

  @typedoc """
  List of flags
  """
  @type flags :: list(flag)
end
