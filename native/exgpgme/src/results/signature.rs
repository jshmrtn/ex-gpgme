use rustler::{NifEnv, NifTerm, NifEncoder};
use gpgme::results::Signature;
use std::time::UNIX_EPOCH;
use rustler::types::elixir_struct;
use rustler::types::atom::nil;
use std::str::Utf8Error;
use ::results::pka_trust::transform_pka_trust;
use notation::signature_notation::transform_signature_notation;
use validity::transform_validity;
use key_algorithm::transform_key_algorithm;
use hash_algorithm::transform_hash_algorithm;
use keys::wrap_key;

mod atoms {
    rustler_atoms! {
        atom fingerprint;
        atom status;
        atom valid;
        atom invalid;
        atom creation_time;
        atom expiration_time;
        atom never_expires;
        atom is_wrong_key_usage;
        atom verified_by_chain;
        atom pka_trust;
        atom pka_address;
        atom validity;
        atom nonvalidity_reason;
        atom key_algorithm;
        atom hash_algorithm;
        atom policy_url;
        atom notations;
        atom key;
    }
}

macro_rules! nif_or_nil {
    ($expr:expr, $env:ident, $content:ident, $content_to_env:expr) => (match $expr {
        Some($content) => $content_to_env.encode($env),
        None => nil().encode($env)
    });
}

pub fn transform_signature<'a>(env: NifEnv<'a>, signature: Signature) -> Result<NifTerm<'a>, Utf8Error> {
    let fingerprint_atom = atoms::fingerprint().encode(env);
    let status_atom = atoms::status().encode(env);
    let creation_time_atom = atoms::creation_time().encode(env);
    let expiration_time_atom = atoms::expiration_time().encode(env);
    let never_expires_atom = atoms::never_expires().encode(env);
    let is_wrong_key_usage_atom = atoms::is_wrong_key_usage().encode(env);
    let verified_by_chain_atom = atoms::verified_by_chain().encode(env);
    let pka_trust_atom = atoms::pka_trust().encode(env);
    let pka_address_atom = atoms::pka_address().encode(env);
    let validity_atom = atoms::validity().encode(env);
    let nonvalidity_reason_atom = atoms::nonvalidity_reason().encode(env);
    let key_algorithm_atom = atoms::key_algorithm().encode(env);
    let hash_algorithm_atom = atoms::hash_algorithm().encode(env);
    let policy_url_atom = atoms::policy_url().encode(env);
    let notations_atom = atoms::notations().encode(env);
    let key_atom = atoms::key().encode(env);

    let status = match signature.status() {
        Ok(_) => atoms::valid().encode(env),
        Err(_) => atoms::invalid().encode(env)
    };
    let fingerprint = string_or_null!(signature.fingerprint(), env)?;
    let creation_time = nif_or_nil!(signature.creation_time(), env, content, { content.duration_since(UNIX_EPOCH).expect("time").as_secs() });
    let expiration_time = nif_or_nil!(signature.expiration_time(), env, content, { content.duration_since(UNIX_EPOCH).expect("time").as_secs() });
    let pka_address = string_or_null!(signature.pka_address(), env)?;
    let nonvalidity_reason = match signature.nonvalidity_reason() {
        Some(error) => error.description().into_owned().encode(env),
        None => nil().encode(env)
    };
    let policy_url = string_or_null!(signature.policy_url(), env)?;
    let key_arc = match signature.key() {
        Some(key) => wrap_key(key).encode(env),
        None => nil().encode(env)
    };
    let notations = signature.notations()
        .map(| notation | {
            transform_signature_notation(env, notation)
        })
        .fold(Ok(Vec::new()), | acc, notation | {
            match acc {
                Err(error) => Err(error),
                Ok(mut acc_inner) => match notation {
                    Err(error) => Err(error),
                    Ok(notation_ok) => {
                        acc_inner.push(notation_ok);
                        Ok(acc_inner)
                    }
                }
            }
        })?
        .encode(env);

    Ok(
        elixir_struct::make_ex_struct(env, "Elixir.ExGpgme.Results.Signature").ok().unwrap()
            .map_put(status_atom, status).ok().unwrap()
            .map_put(fingerprint_atom, fingerprint).ok().unwrap()
            .map_put(creation_time_atom, creation_time).ok().unwrap()
            .map_put(expiration_time_atom, expiration_time).ok().unwrap()
            .map_put(never_expires_atom, signature.never_expires().encode(env)).ok().unwrap()
            .map_put(is_wrong_key_usage_atom, signature.is_wrong_key_usage().encode(env)).ok().unwrap()
            .map_put(verified_by_chain_atom, signature.verified_by_chain().encode(env)).ok().unwrap()
            .map_put(pka_trust_atom, transform_pka_trust(env, signature.pka_trust())).ok().unwrap()
            .map_put(pka_address_atom, pka_address).ok().unwrap()
            .map_put(validity_atom, transform_validity(env, signature.validity())).ok().unwrap()
            .map_put(nonvalidity_reason_atom, nonvalidity_reason).ok().unwrap()
            .map_put(key_algorithm_atom, transform_key_algorithm(env, signature.key_algorithm())).ok().unwrap()
            .map_put(hash_algorithm_atom, transform_hash_algorithm(env, signature.hash_algorithm())).ok().unwrap()
            .map_put(policy_url_atom, policy_url).ok().unwrap()
            .map_put(notations_atom, notations).ok().unwrap()
            .map_put(key_atom, key_arc).ok().unwrap()
    )
}
