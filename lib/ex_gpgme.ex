defmodule ExGpgme do
  @moduledoc """
  Elixir NIF wrapper for `gpgme`.

  **Warning**: The context is not immutable.
  Therefore multiple processes will influence each other with configuration, flags etc.
  """

  @typedoc """
  A cryptographic protocol that may be used with the library.

  Each protocol is implemented by an engine that the library communicates with to perform various operations.
  """
  @type protocol :: :open_pgp |
    :cms |
    :gpg_conf |
    :assuan |
    :g13 |
    :ui_server |
    :spawn |
    :default |
    :unknown |
    {:other, non_neg_integer}

  @typedoc """
  This option is used to change the operation mode of the pinentry.
  """
  @type pinentry_mode :: :default |
    :ask |
    :cancel |
    :error |
    :loopback |
    {:other, integer}

  @typedoc """
  This option is used to change the operation mode of the signing.
  """
  @type sign_mode :: :normal |
    :detached |
    :clear |
    {:other, integer}

  @typedoc """
  Signature Validity
  """
  @type validity :: :unknown |
    :undefined |
    :never |
    :marginal |
    :full |
    :ultimate

  @typedoc """
  Hash Algorithm
  """
  @type hash_algorithm :: :none |
    :md2 |
    :md4 |
    :md5 |
    :sha1 |
    :sha224 |
    :sha256 |
    :sha384 |
    :sha512 |
    :ripe_md160 |
    :tiger |
    :haval |
    :crc32 |
    :crc32_rfc1510 |
    :crc24_rfc2440 |
    {:other, integer}

  @typedoc """
  Key Algorithm
  """
  @type key_algorithm :: :rsa |
    :rsa_encrypt |
    :rsa_sign |
    :elgamal_encrypt |
    :dsa |
    :ecc |
    :elgamal |
    :ecdsa |
    :ecdh |
    :eddsa |
    {:other, integer}
end
