defmodule ExGpgme.Results.ImportResult do
  @moduledoc """
  Result struct for any imports.
  """

  alias ExGpgme.Results.Import

  @type t :: %__MODULE__{
    considered: non_neg_integer,
    without_user_id: non_neg_integer,
    imported: non_neg_integer,
    imported_rsa: non_neg_integer,
    unchanged: non_neg_integer,
    new_user_ids: non_neg_integer,
    new_subkeys: non_neg_integer,
    new_signatures: non_neg_integer,
    new_revocations: non_neg_integer,
    secret_considered: non_neg_integer,
    secret_imported: non_neg_integer,
    secret_unchanged: non_neg_integer,
    not_imported: non_neg_integer,
    imports: list(Import.t),
  }

  @enforce_keys [
    :considered,
    :without_user_id,
    :imported,
    :imported_rsa,
    :unchanged,
    :new_user_ids,
    :new_subkeys,
    :new_signatures,
    :new_revocations,
    :secret_considered,
    :secret_imported,
    :secret_unchanged,
    :not_imported,
    :imports,
  ]
  defstruct @enforce_keys
end
