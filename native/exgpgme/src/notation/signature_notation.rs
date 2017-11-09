use rustler::{NifEnv, NifTerm, NifEncoder};
use gpgme::notation::SignatureNotation;
use rustler::types::elixir_struct;
use std::str::Utf8Error;

mod atoms {
    rustler_atoms! {
        atom is_human_readable;
        atom is_critical;
        // atom flags;
        atom name;
        atom value;
    }
}

pub fn transform_signature_notation<'a>(env: NifEnv<'a>, notation: SignatureNotation) -> Result<NifTerm<'a>, Utf8Error> {
    let is_human_readable_atom = atoms::is_human_readable().encode(env);
    let is_critical_atom = atoms::is_critical().encode(env);
    // let flags_atom = atoms::flags().encode(env);
    let name_atom = atoms::name().encode(env);
    let value_atom = atoms::value().encode(env);

    let name = string_or_null!(notation.name(), env)?;
    let value = string_or_null!(notation.value(), env)?;

    Ok(
        elixir_struct::make_ex_struct(env, "Elixir.ExGpgme.Notation.SignatureNotation").ok().unwrap()
            .map_put(is_human_readable_atom, notation.is_human_readable().encode(env)).ok().unwrap()
            .map_put(is_critical_atom, notation.is_critical().encode(env)).ok().unwrap()
            .map_put(name_atom, name.encode(env)).ok().unwrap()
            .map_put(value_atom, value.encode(env)).ok().unwrap()
    )
}
