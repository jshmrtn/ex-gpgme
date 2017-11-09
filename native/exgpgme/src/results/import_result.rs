use rustler::{NifEnv, NifTerm, NifEncoder};
use gpgme::results::ImportResult;
use rustler::types::elixir_struct;

use ::results::import::transform_import;

mod atoms {
    rustler_atoms! {
        atom considered;
        atom without_user_id;
        atom imported;
        atom imported_rsa;
        atom unchanged;
        atom new_user_ids;
        atom new_subkeys;
        atom new_signatures;
        atom new_revocations;
        atom secret_considered;
        atom secret_imported;
        atom secret_unchanged;
        atom not_imported;
        atom imports;
    }
}

pub fn transform_import_result<'a>(env: NifEnv<'a>, result: ImportResult) -> NifTerm<'a> {
    let considered_atom = atoms::considered().encode(env);
    let without_user_id_atom = atoms::without_user_id().encode(env);
    let imported_atom = atoms::imported().encode(env);
    let imported_rsa_atom = atoms::imported_rsa().encode(env);
    let unchanged_atom = atoms::unchanged().encode(env);
    let new_user_ids_atom = atoms::new_user_ids().encode(env);
    let new_subkeys_atom = atoms::new_subkeys().encode(env);
    let new_signatures_atom = atoms::new_signatures().encode(env);
    let new_revocations_atom = atoms::new_revocations().encode(env);
    let secret_considered_atom = atoms::secret_considered().encode(env);
    let secret_imported_atom = atoms::secret_imported().encode(env);
    let secret_unchanged_atom = atoms::secret_unchanged().encode(env);
    let not_imported_atom = atoms::not_imported().encode(env);
    let imports_atom = atoms::imports().encode(env);
    let imports: Vec<NifTerm<'a>> = result.imports()
        .map(| import | {
            transform_import(env, import)
        })
        .collect();

    elixir_struct::make_ex_struct(env, "Elixir.ExGpgme.Results.ImportResult").ok().unwrap()
        .map_put(considered_atom, result.considered().encode(env)).ok().unwrap()
        .map_put(without_user_id_atom, result.without_user_id().encode(env)).ok().unwrap()
        .map_put(imported_atom, result.imported().encode(env)).ok().unwrap()
        .map_put(imported_rsa_atom, result.imported_rsa().encode(env)).ok().unwrap()
        .map_put(unchanged_atom, result.unchanged().encode(env)).ok().unwrap()
        .map_put(new_user_ids_atom, result.new_user_ids().encode(env)).ok().unwrap()
        .map_put(new_subkeys_atom, result.new_subkeys().encode(env)).ok().unwrap()
        .map_put(new_signatures_atom, result.new_signatures().encode(env)).ok().unwrap()
        .map_put(new_revocations_atom, result.new_revocations().encode(env)).ok().unwrap()
        .map_put(secret_considered_atom, result.secret_considered().encode(env)).ok().unwrap()
        .map_put(secret_imported_atom, result.secret_imported().encode(env)).ok().unwrap()
        .map_put(secret_unchanged_atom, result.secret_unchanged().encode(env)).ok().unwrap()
        .map_put(not_imported_atom, result.not_imported().encode(env)).ok().unwrap()
        .map_put(imports_atom, imports.encode(env)).ok().unwrap()
}
