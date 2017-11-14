defmodule ExGpgme.Context do
  @moduledoc """
  GPG Context

  **Warning**: The context is not immutable.
  Therefore multiple processes will influence each other with configuration, flags etc.
  """

  use Rustler, otp_app: :ex_gpgme, crate: :exgpgme

  alias ExGpgme.Results.{ImportResult, VerificationResult}
  alias ExGpgme.Keys.Key
  alias ExGpgme.EncryptFlags
  alias ExGpgme.Engine.EngineInfo

  @typedoc """
  GPG Context for all functions of `ExGpgme.Context`.

  **Warning**: The context is not immutable.
  Therefore multiple processes will influence each other with configuration, flags etc.
  """
  @opaque context :: reference

  @doc """
  The function creates a context with the protocol. All crypto operations will be performed by the crypto engine
  configured for that protocol.
  See [Protocols and Engines](https://www.gnupg.org/documentation/manuals/gpgme/Protocols-and-Engines.html#Protocols-and-Engines).

  Setting the protocol does not check if the crypto engine for that protocol is available and installed correctly.
  See [Engine Version Check](https://www.gnupg.org/documentation/manuals/gpgme/Engine-Version-Check.html#Engine-Version-Check).

  ### Examples

      iex> ExGpgme.Context.from_protocol(:open_pgp)
      {:ok, #Reference<0.1689386418.123076612.191614>}

  """
  @spec from_protocol(protocol :: ExGpgme.protocol) :: {:ok, context} | {:error, String.t}
  def from_protocol(_protocol), do: exit(:nif_not_loaded)

  @doc """
  See `from_protocol/1`.

  """
  @spec from_protocol!(protocol :: ExGpgme.protocol) :: context | no_return
  def from_protocol!(protocol) do
    case from_protocol(protocol) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  @doc """
  The function retrieves the protocol currently used with the context.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.protocol
      :open_pgp

  """
  @spec protocol(context :: context):: ExGpgme.protocol
  def protocol(_context), do: exit(:nif_not_loaded)

  @doc """
  The function returns `true` if the output is ASCII armored, and `false` if it is not.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.armor?
      false

  """
  @spec armor?(context :: context):: boolean
  def armor?(_context), do: exit(:nif_not_loaded)

  @doc """
  The function specifies if the output should be ASCII armored. By default, output is not ASCII armored.

  ASCII armored output is disabled if `yes` is `false`, and enabled otherwise.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.set_armor(true)
      :ok

  """
  @spec set_armor(context :: context, yes :: boolean):: :ok
  def set_armor(_context, _yes), do: exit(:nif_not_loaded)

  @doc """
  The function returns `true` if canonical text mode is enabled, and `false` if it is not.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.text_mode?
      false

  """
  @spec text_mode?(context :: context):: boolean
  def text_mode?(_context), do: exit(:nif_not_loaded)

  @doc """
  The function specifies if canonical text mode should be used. By default, text mode is not used.

  Text mode is for example used for the `RFC2015` signatures; note that the updated `RFC 3156` mandates that the mail
  user agent does some preparations so that text mode is not needed anymore.

  This option is only relevant to the OpenPGP crypto engine, and ignored by all other engines.

  Canonical text mode is disabled if `yes` is `false`, and enabled otherwise.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.set_text_mode(true)
      :ok

  """
  @spec set_text_mode(context :: context, yes :: boolean):: :ok
  def set_text_mode(_context, _yes), do: exit(:nif_not_loaded)

  @doc """
  The function returns `true` if offline mode is enabled, and `false` if it is not.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.offline?
      false

  """
  @spec offline?(context :: context):: boolean
  def offline?(_context), do: exit(:nif_not_loaded)

  @doc """
  The function specifies if offline mode should be used. By default, offline mode is not used.

  The offline mode specifies if `dirmngr` should be used to do additional validation that might require connections to
  external services. (e.g. `CRL` / `OCSP` checks).

  Offline mode only affects the keylist mode `GPGME_KEYLIST_MODE_VALIDATE` and is only relevant to the `CMS` crypto
  engine. Offline mode is ignored otherwise.

  This option may be extended in the future to completely disable the use of `dirmngr` for any engine.

  Offline mode is disabled if `yes` is `false`, and enabled otherwise.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.set_offline(true)
      :ok

  """
  @spec set_offline(context :: context, yes :: boolean):: :ok
  def set_offline(_context, _yes), do: exit(:nif_not_loaded)

  @doc """
  The value of flags settable by `set_flag/3` can be retrieved by this function. If name is unknown the function returns
  `:error`. For boolean flags an empty string is returned for `false` and the string `"1"` is returned for `true`;
  a test for an empty string can be used to get the boolean value.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.get_flag("not-existing-flag")
      {:error, :not_set}

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.get_flag("export-session-key")
      {:ok, ""}

  """
  @spec get_flag(context :: context, name :: String.t):: {:ok, String.t} | {:error, :not_set | String.t}
  def get_flag(_context, _name), do: exit(:nif_not_loaded)

  @doc """
  See `get_flag/2`.

  """
  @spec get_flag!(context :: context, name :: String.t):: String.t | no_return
  def get_flag!(context, name) do
    case get_flag(context, name) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  @doc """
  Some minor properties of the context can be controlled with flags set by this function. The properties are identified
  by the following values for `name`:

  * `"redraw"` - This flag is normally not changed by the caller because GPGME sets and clears it automatically:
    The flag is cleared before an operation and set if an operation noticed that the engine has launched a Pinentry.
    A Curses based application may use this information to redraw the screen.
  * `"full-status"` - Using a `value` of `"1"` the status callback set by gpgme_set_status_cb returns all status lines
    with the exception of `PROGRESS` lines. With the default of `"0"` the status callback is only called in certain
    situations.
  * `"raw-description"` - Setting the `value` to `"1"` returns human readable strings in a raw format. For example the
    non breaking space characters (`~`) will not be removed from the description field of the gpgme_tofu_info_t object.
  * `"export-session-key"` - Using a `value` of `"1"` specifies that the context should try to export the symmetric
    session key when decrypting data. By default, or when using an empty string or `"0"` for value, session keys are
    not exported.
  * `override-session-key"` - The string given in `value` is passed to the GnuPG engine to override the session key for
    decryption. The format of that session key is specific to GnuPG and can be retrieved during a decrypt operation when
    the context flag `"export-session-key"` is enabled. Please be aware that using this feature with GnuPG < `2.1.16`
    will leak the session key on many platforms via `ps(1)`.

  ### Examples

      iex> context = :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      iex> ExGpgme.Context.set_flag(context, "not-existing-flag", "1")
      {:error, "Unknown name"}

      iex> context = :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      iex> ExGpgme.Context.set_flag(context, "raw-description", "1")
      :ok

  """
  @spec set_flag(context :: context, flag :: String.t, value :: String.t):: :ok | {:error, String.t}
  def set_flag(_context, _flag, _value), do: exit(:nif_not_loaded)

  @doc """
  Returns an `EngineInfo` struct that describes the configuration of the context.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.engine_info
      %ExGpgme.Engine.EngineInfo{home_dir: "",
        path: "/usr/local/MacGPG2/bin/gpg", protocol: :open_pgp,
        required_version: "1.4.0", version: "2.2.0"}

  """
  @spec engine_info(context :: context):: {:ok, EngineInfo.t} | {:error, String.t}
  def engine_info(_context), do: exit(:nif_not_loaded)

  @doc """
  See `engine_info/1`

  """
  @spec engine_info!(context :: context):: EngineInfo.t | no_return
  def engine_info!(context) do
    case engine_info(context) do
      {:ok, engine_info} -> engine_info
      {:error, error} -> raise error
    end
  end

  @doc """
  Set engine path for GPG Context.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.set_engine_path("/some/path")
      :ok

  """
  @spec set_engine_path(context :: context, path :: String.t):: :ok | {:error, String.t}
  def set_engine_path(_context, _path), do: exit(:nif_not_loaded)

  @doc """
  See `set_engine_path/2`

  """
  @spec set_engine_path!(context :: context, path :: String.t):: nil | no_return
  def set_engine_path!(context, path) do
    case set_engine_path(context, path) do
      :ok -> nil
      {:error, error} -> raise error
    end
  end

  @doc """
  Set home directory for GPG Context.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.set_engine_home_dir("/some/path")
      :ok

  """
  @spec set_engine_home_dir(context :: context, home_dir :: String.t):: :ok | {:error, String.t}
  def set_engine_home_dir(_context, _home_dir), do: exit(:nif_not_loaded)

  @doc """
  See `set_engine_home_dir/2`

  """
  @spec set_engine_home_dir!(context :: context, home_dir :: String.t):: nil | no_return
  def set_engine_home_dir!(context, home_dir) do
    case set_engine_home_dir(context, home_dir) do
      :ok -> nil
      {:error, error} -> raise error
    end
  end

  @doc """
  The function returns the mode set for the context.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.pinentry_mode
      :default

  """
  @spec pinentry_mode(context :: context):: ExGpgme.pinentry_mode
  def pinentry_mode(_context), do: exit(:nif_not_loaded)

  @doc """
  The function sets the mode for the context.

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.set_pinentry_mode(:ask)
      :ok

  """
  @spec set_pinentry_mode(context :: context, mode :: ExGpgme.pinentry_mode):: :ok | {:error, String.t}
  def set_pinentry_mode(_context, _mode), do: exit(:nif_not_loaded)

  @doc """
  See `set_pinentry_mode/2`

  """
  @spec set_pinentry_mode!(context :: context, mode :: ExGpgme.pinentry_mode):: nil | no_return
  def set_pinentry_mode!(context, mode) do
    case set_pinentry_mode(context, mode) do
      :ok -> nil
      {:error, error} -> raise error
    end
  end

  @doc """
  Import Keys

  ### Examples

      iex> :open_pgp
      ...> |> ExGpgme.Context.from_protocol!
      ...> |> ExGpgme.Context.import(File.read!("priv/test/keys/sender_public.asc"))
      {:ok,
       %ExGpgme.Results.ImportResult{considered: 1, imported: 0,
        imported_rsa: 0,
        imports: [%ExGpgme.Results.Import{fingerprint: "95E93F470BCB2E96C648572DFBFA85913EE05E95"}],
        new_revocations: 0, new_signatures: 0, new_subkeys: 0,
        new_user_ids: 0, not_imported: 0, secret_considered: 0,
        secret_imported: 0, secret_unchanged: 0, unchanged: 1,
        without_user_id: 0}}

  """
  @spec import(context :: context, data :: String.t) :: {:ok, ImportResult.t} | {:error, String.t}
  def import(_context, _data), do: exit(:nif_not_loaded)

  @doc """
  See `import/2`.

  """
  @spec import!(context :: context, data :: String.t) :: ImportResult.t | no_return
  def import!(context, data) do
    case __MODULE__.import(context, data) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  @doc """
  Find a key by Fingerprint

  ### Examples

      iex> context = ExGpgme.Context.from_protocol!(:open_pgp)
      iex> ExGpgme.Context.import!(context, File.read!("priv/test/keys/sender_public.asc"))
      iex> ExGpgme.Context.find_key(context, "95E93F470BCB2E96C648572DFBFA85913EE05E95")
      {:ok, #Reference<0.411470915.3086352388.254522>}

      iex> context = ExGpgme.Context.from_protocol!(:open_pgp)
      iex> ExGpgme.Context.import!(context, File.read!("priv/test/keys/sender_public.asc"))
      iex> ExGpgme.Context.find_key(context, "not-existing-fingerprint")
      {:error, "End of file"}

  """
  @spec find_key(context :: context, fingerprint :: String.t) :: {:ok, Key.t} | {:error, String.t}
  def find_key(_context, _fingerprint), do: exit(:nif_not_loaded)

  @doc """
  See `find_key/2`.

  """
  @spec find_key!(context :: context, fingerprint :: String.t) :: Key.t | no_return
  def find_key!(context, fingerprint) do
    case find_key(context, fingerprint) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end

  @doc """
  Encrypts a message for the specified recipients.

  ### Examples

      iex> context = ExGpgme.Context.from_protocol!(:open_pgp)
      iex> ExGpgme.Context.set_armor(context, true)
      iex> ExGpgme.Context.import!(context, File.read!("priv/test/keys/sender_public.asc"))
      iex> recipient = ExGpgme.Context.find_key!(context, "95E93F470BCB2E96C648572DFBFA85913EE05E95")
      iex> ExGpgme.Context.encrypt(context, [recipient], "Hello World", [:always_trust])
      {:ok,
       "-----BEGIN PGP MESSAGE-----\\n[data]\\n-----END PGP MESSAGE-----\\n"}

  """
  @spec encrypt(context :: context, recipients :: [Key.t], data :: String.t, flags:: EncryptFlags.flags)
    :: {:ok, String.t} | {:error, String.t}
  def encrypt(context, recipients, data, flags \\ []),
    do: encrypt_with_flags(context, recipients, data, flags)

  @spec encrypt_with_flags(context :: context, recipients :: [Key.t], data :: String.t, flags:: EncryptFlags.flags)
    :: {:ok, String.t} | {:error, String.t}
  defp encrypt_with_flags(_context, _recipients, _data, _flags), do: exit(:nif_not_loaded)

  @doc """
  See `encrypt/4`
  """
  @spec encrypt!(context :: context, recipients :: [Key.t], data :: String.t, flags:: EncryptFlags.flags)
    :: String.t | no_return
  def encrypt!(context, recipients, data, flags \\ []) do
    case encrypt(context, recipients, data, flags) do
      {:ok, cypthertext} -> cypthertext
      {:error, error} -> raise error
    end
  end

  @doc """
  Signs and encrypts a message for the specified recipients.

  ### Examples

      iex> context = ExGpgme.Context.from_protocol!(:open_pgp)
      iex> ExGpgme.Context.set_armor(context, true)
      iex> ExGpgme.Context.import!(context, File.read!("priv/test/keys/sender_public.asc"))
      iex> recipient = ExGpgme.Context.find_key!(context, "95E93F470BCB2E96C648572DFBFA85913EE05E95")
      iex> ExGpgme.Context.sign_and_encrypt(context, [recipient], "Hello World", [:always_trust])
      {:ok, "-----BEGIN PGP MESSAGE-----\\n[data]\\n-----END PGP MESSAGE-----\\n"}

  """
  @spec sign_and_encrypt(context :: context, recipients :: [Key.t], data :: String.t, flags:: EncryptFlags.flags)
    :: {:ok, String.t} | {:error, String.t}
  def sign_and_encrypt(context, recipients, data, flags \\ []),
    do: sign_and_encrypt_with_flags(context, recipients, data, flags)

  @spec sign_and_encrypt_with_flags(context :: context, recipients :: [Key.t],
    data :: String.t, flags:: EncryptFlags.flags)
    :: {:ok, String.t} | {:error, String.t}
  defp sign_and_encrypt_with_flags(_context, _recipients, _data, _flags), do: exit(:nif_not_loaded)

  @doc """
  See `sign_and_encrypt/4`
  """
  @spec sign_and_encrypt!(context :: context, recipients :: [Key.t], data :: String.t, flags:: EncryptFlags.flags)
    :: String.t | no_return
  def sign_and_encrypt!(context, recipients, data, flags \\ []) do
    case sign_and_encrypt(context, recipients, data, flags) do
      {:ok, cypthertext} -> cypthertext
      {:error, error} -> raise error
    end
  end

  @doc """
  The function deletes the key `key` from the key ring of the crypto engine used by `context`.

  ### Examples

      iex> context = ExGpgme.Context.from_protocol!(:open_pgp)
      iex> ExGpgme.Context.import!(context, File.read!("priv/test/keys/sender_public.asc"))
      iex> key = ExGpgme.Context.find_key!(context, "95E93F470BCB2E96C648572DFBFA85913EE05E95")
      iex> ExGpgme.Context.delete_key(context, key)
      :ok

  """
  @spec delete_key(context :: context, key :: Key.t) :: :ok | {:error, String.t}
  def delete_key(_context, _key), do: exit(:nif_not_loaded)

  @doc """
  See `delete_key/2`

  """
  @spec delete_key!(context :: context, key :: Key.t) :: nil | no_return
  def delete_key!(context, key) do
    case delete_key(context, key) do
      :ok -> nil
      {:error, error} -> raise error
    end
  end

  @doc """
  The function deletes the secret key `key` from the key ring of the crypto engine used by `context`.

  ### Examples

      iex> context = ExGpgme.Context.from_protocol!(:open_pgp)
      iex> ExGpgme.Context.import!(context, File.read!("priv/test/keys/sender_public.asc"))
      iex> key = ExGpgme.Context.find_key!(context, "95E93F470BCB2E96C648572DFBFA85913EE05E95")
      iex> ExGpgme.Context.delete_secret_key(context, key)
      :ok

  """
  @spec delete_secret_key(context :: context, key :: Key.t) :: :ok | {:error, String.t}
  def delete_secret_key(_context, _key), do: exit(:nif_not_loaded)

  @doc """
  See `delete_secret_key/2`

  """
  @spec delete_secret_key!(context :: context, key :: Key.t) :: nil | no_return
  def delete_secret_key!(context, key) do
    case delete_secret_key(context, key) do
      :ok -> nil
      {:error, error} -> raise error
    end
  end

  @doc """
  The function decrypts the ciphertext in the argument `ciphertext` and returns the plain text.

  ### Examples

      iex> context = ExGpgme.Context.from_protocol!(:open_pgp)
      iex> ExGpgme.Context.set_armor(context, true)
      iex> ExGpgme.Context.import!(context, File.read!("priv/test/keys/sender_secret.asc"))
      iex> recipient = ExGpgme.Context.find_key!(context, "95E93F470BCB2E96C648572DFBFA85913EE05E95")
      iex> cyphertext = ExGpgme.Context.encrypt!(context, [recipient], "Hello World", [:always_trust])
      iex> ExGpgme.Context.decrypt(context, cyphertext)
      {:ok, "Hello World"}

  """
  @spec decrypt(context :: context, cypertext :: String.t) :: {:ok, String.t} | {:error, String.t}
  def decrypt(_context, _cyphertext), do: exit(:nif_not_loaded)

  @doc """
  See `decrypt/2`

  """
  @spec decrypt!(context :: context, cypertext :: String.t) :: String.t | no_return
  def decrypt!(context, cyphertext) do
    case decrypt(context, cyphertext) do
      {:ok, plaintext} -> plaintext
      {:error, error} -> raise error
    end
  end

  @doc """
  The function creates a signature for the text in the `data`. The type of the signature created is determined by the
  ASCII armor (or, if that is not set, by the encoding specified for sig), the text mode attributes set for the context
  ctx and the requested signature mode `mode`.

  ### Examples

      iex> context = ExGpgme.Context.from_protocol!(:open_pgp)
      iex> ExGpgme.Context.set_armor(context, true)
      iex> ExGpgme.Context.import!(context, File.read!("priv/test/keys/sender_secret.asc"))
      iex> ExGpgme.Context.sign(context, "Hello World")
      {:ok, "-----BEGIN PGP MESSAGE-----\\n[data]\\n-----END PGP MESSAGE-----\\n"}

  """
  @spec sign(context :: context, mode :: ExGpgme.sign_mode, data :: String.t)
    :: {:ok, String.t} | {:error, String.t}
  def sign(context, mode \\ :normal, data), do: sign_with_mode(context, mode, data)

  @spec sign_with_mode(context :: context, mode :: ExGpgme.sign_mode, data :: String.t)
    :: {:ok, String.t} | {:error, String.t}
  defp sign_with_mode(_context, _mode, _data), do: exit(:nif_not_loaded)

  @doc """
  See `sign/3`

  """
  @spec sign!(context :: context, mode :: ExGpgme.sign_mode, data :: String.t) :: String.t | no_return
  def sign!(context, mode \\ :normal, data) do
    case sign(context, mode, data) do
      {:ok, signature} -> signature
      {:error, error} -> raise error
    end
  end

  @doc """
  The function verifies that the signature `signature` is a valid signature.

  ### Examples

      iex> context = ExGpgme.Context.from_protocol!(:open_pgp)
      iex> ExGpgme.Context.set_armor(context, true)
      iex> ExGpgme.Context.import!(context, File.read!("priv/test/keys/sender_secret.asc"))
      iex> signature = ExGpgme.Context.sign!(context, "Hello World")
      iex> ExGpgme.Context.verify_opaque(context, signature, "Hello World")
      {:ok,
        %ExGpgme.Results.VerificationResult{filename: nil,
         signatures: [%ExGpgme.Results.Signature{creation_time: 1510648065,
           expiration_time: nil,
           fingerprint: "406B5EE427BA5396C39D0F1DD257FFE3438B29DB",
           hash_algorithm: :sha512, is_wrong_key_usage: false, key: nil,
           key_algorithm: :rsa, never_expires: true,
           nonvalidity_reason: nil, notations: [], pka_address: nil,
           pka_trust: :unknown, policy_url: nil, status: :valid,
           validity: :full, verified_by_chain: false}]}}

  """
  @spec verify_opaque(context :: context, signature :: String.t, data :: String.t)
    :: {:ok, VerificationResult.t} | {:error, String.t}
  def verify_opaque(_context, _signature, _data), do: exit(:nif_not_loaded)

  @doc """
  See `verify_opaque/3`
  """
  @spec verify_opaque!(context :: context, signature :: String.t, data :: String.t)
    :: VerificationResult.t | no_return
  def verify_opaque!(context, signature, data) do
    case verify_opaque(context, signature, data) do
      {:ok, result} -> result
      {:error, error} -> raise error
    end
  end
end
