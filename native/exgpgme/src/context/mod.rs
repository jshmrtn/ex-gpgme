use rustler::{NifEnv, NifTerm, NifResult, NifEncoder};
use rustler::resource::ResourceArc;
use rustler::types::list::NifListIterator;
use gpgme::{Context, EncryptFlags};
use gpgme::keys::Key;
use std::ops::Deref;
use results::verification_result::transform_verification_result;
use keys;
use protocol;
use encrypt_flags;
use engine;
use pinentry_mode;
use sign_mode;
use results::import_result::transform_import_result;

#[macro_use] pub mod helpers;
#[macro_use] pub mod resource;

mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
        atom not_set;
    }
}

pub fn from_protocol<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let protocol = protocol::arg_to_protocol(args[0])?;

    let context = try_gpgme!(Context::from_protocol(protocol), env);

    Ok((atoms::ok(), resource::wrap_context(context)).encode(env))
}

context_getter!(protocol, context, env, { protocol::protocol_to_nif(env, context.protocol()) });
context_getter!(offline, context, env, { context.offline().encode(env) });
context_setter!(set_offline, context, env, yes, bool, { context.set_offline(yes) });
context_getter!(text_mode, context, env, { context.text_mode().encode(env) });
context_setter!(set_text_mode, context, env, yes, bool, { context.set_text_mode(yes) });
context_getter!(armor, context, env, { context.armor().encode(env) });
context_setter!(set_armor, context, env, yes, bool, { context.set_armor(yes) });

pub fn get_flag<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    unpack_immutable_context!(context, args[0]);

    let name: String = try!(args[1].decode());

    match context.get_flag(name) {
        Ok(result) => Ok((atoms::ok(), String::from(result)).encode(env)),
        Err(_) => Ok((atoms::error(), atoms::not_set()).encode(env))
    }
}

pub fn set_flag<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    unpack_mutable_context!(context, args[0]);

    let name: String = try!(args[1].decode());
    let value: String = try!(args[2].decode());

    try_gpgme!(context.set_flag(name, value), env);

    Ok(atoms::ok().encode(env))
}

context_getter!(engine_info, context, env, {
    match engine::engine_info_to_term(context.engine_info(), env) {
        Ok(result) => result,
        Err(_) => (atoms::error(), String::from("Could not decode cyphertext to utf8")).encode(env)
    }
});

context_setter!(set_engine_path, context, env, path, String, { try_gpgme!(context.set_engine_path(path), env) });
context_setter!(set_engine_home_dir, context, env, home_dir, String, { try_gpgme!(context.set_engine_home_dir(home_dir), env) });

context_getter!(pinentry_mode, context, env, { pinentry_mode::pinentry_mode_to_term(context.pinentry_mode(), env) });

pub fn set_pinentry_mode<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    unpack_mutable_context!(context, args[0]);

    let mode = pinentry_mode::arg_to_pinentry_mode(args[1])?;

    try_gpgme!(context.set_pinentry_mode(mode), env);

    Ok(atoms::ok().encode(env))
}

pub fn import<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    unpack_mutable_context!(context, args[0]);

    let data: String = try!(args[1].decode());

    let result = try_gpgme!(context.import(data), env);

    Ok((atoms::ok(), transform_import_result(env, result)).encode(env))
}

pub fn find_key<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    unpack_immutable_context!(context, args[0]);

    let fingerprint: String = try!(args[1].decode());

    let result = try_gpgme!(context.find_key(fingerprint), env);

    Ok((atoms::ok(), keys::wrap_key(result)).encode(env))
}

pub fn encrypt_with_flags<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    unpack_mutable_context!(context, args[0]);
    unpack_key_list!(recipients, args[1]);

    keys::keys_not_empty(recipients.len())?;

    let data: String = args[2].decode()?;

    let flags: EncryptFlags = encrypt_flags::arg_to_protocol(args[3].decode::<NifListIterator>()?)?;

    let mut cyphertext: Vec<u8> = Vec::new();
    try_gpgme!(context.encrypt_with_flags(recipients, data, &mut cyphertext, flags), env);

    decode_context_result!(cyphertext, env)
}

pub fn sign_and_encrypt_with_flags<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    unpack_mutable_context!(context, args[0]);
    unpack_key_list!(recipients, args[1]);

    keys::keys_not_empty(recipients.len())?;

    let data: String = args[2].decode()?;

    let flags: EncryptFlags = encrypt_flags::arg_to_protocol(args[3].decode::<NifListIterator>()?)?;

    let mut cyphertext: Vec<u8> = Vec::new();
    try_gpgme!(context.sign_and_encrypt_with_flags(recipients, data, &mut cyphertext, flags), env);

    decode_context_result!(cyphertext, env)
}

pub fn delete_key<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    unpack_mutable_context!(context, args[0]);

    let key_arc = try!(args[1].decode::<ResourceArc<keys::KeyResource>>());
    let key_ref = key_arc.deref();
    let key: &Key = &key_ref.key;

    try_gpgme!(context.delete_key(key), env);

    Ok(atoms::ok().encode(env))
}

pub fn delete_secret_key<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    unpack_mutable_context!(context, args[0]);

    let key_arc = try!(args[1].decode::<ResourceArc<keys::KeyResource>>());
    let key_ref = key_arc.deref();
    let key: &Key = &key_ref.key;

    try_gpgme!(context.delete_secret_key(key), env);

    Ok(atoms::ok().encode(env))
}

pub fn decrypt<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    unpack_mutable_context!(context, args[0]);

    let cyphertext: String = try!(args[1].decode::<String>());//.into_bytes();

    let mut cleartext: Vec<u8> = Vec::new();

    try_gpgme!(context.decrypt(cyphertext, &mut cleartext), env);

    decode_context_result!(cleartext, env)
}

pub fn sign_with_mode<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    unpack_mutable_context!(context, args[0]);

    let mode = sign_mode::arg_to_sign_mode(args[1])?;

    let data: String = args[2].decode()?;

    let mut signature: Vec<u8> = Vec::new();

    try_gpgme!(context.sign(mode, data, &mut signature), env);

    decode_context_result!(signature, env)
}

pub fn verify_opaque<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    unpack_mutable_context!(context, args[0]);

    let signature: String = args[1].decode()?;

    let data: String = args[2].decode()?;

    let result = try_gpgme!(context.verify_opaque(signature, data), env);

    match transform_verification_result(env, result) {
        Ok(nif_result) => Ok((atoms::ok(), nif_result).encode(env)),
        Err(_) => Ok((atoms::error(), String::from("Could not decode cyphertext to utf8")).encode(env))
    }
}
