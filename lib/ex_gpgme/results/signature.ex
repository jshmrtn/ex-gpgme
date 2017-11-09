defmodule ExGpgme.Results.Signature do
  @moduledoc """
  Signature
  """

  alias ExGpgme.Keys.Key
  alias ExGpgme.Results
  alias ExGpgme.Notation.SignatureNotation

  @type status :: :valid | :invalid

  @type t :: %__MODULE__{
    fingerprint: String.t | nil,
    status: status,
    creation_time: non_neg_integer | nil,
    expiration_time: non_neg_integer | nil,
    never_expires: boolean,
    is_wrong_key_usage: boolean,
    verified_by_chain: boolean,
    pka_trust: Results.pka_trust,
    pka_address: String.t | nil,
    validity: ExGpgme.validity,
    nonvalidity_reason: String.t | nil,
    key_algorithm: ExGpgme.key_algorithm,
    hash_algorithm: ExGpgme.hash_algorithm,
    policy_url: String.t | nil,
    notations: [SignatureNotation.t],
    key: Key.t | nil,
  }

  @enforce_keys [
    :fingerprint,
    :status,
    :creation_time,
    :expiration_time,
    :never_expires,
    :is_wrong_key_usage,
    :verified_by_chain,
    :pka_trust,
    :pka_address,
    :validity,
    :nonvalidity_reason,
    :key_algorithm,
    :hash_algorithm,
    :policy_url,
    :notations,
    :key,
  ]
  defstruct @enforce_keys
end
