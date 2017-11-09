#[macro_use] extern crate rustler;
#[macro_use] extern crate lazy_static;
extern crate gpgme;

use rustler::{NifEnv, NifTerm};
use rustler::schedule::NifScheduleFlags;

#[macro_use] mod helpers;
#[macro_use] mod keys;
mod context;
mod results;
mod engine;
mod protocol;
mod encrypt_flags;
mod pinentry_mode;
mod sign_mode;
mod validity;
mod key_algorithm;
mod hash_algorithm;
mod notation;

rustler_export_nifs! {
    "Elixir.ExGpgme.Context",
    [
        ("from_protocol", 1, context::from_protocol),
        ("protocol", 1, context::protocol),
        ("armor?", 1, context::armor),
        ("set_armor", 2, context::set_armor),
        ("text_mode?", 1, context::text_mode),
        ("set_text_mode", 2, context::set_text_mode),
        ("offline?", 1, context::offline),
        ("set_offline", 2, context::set_offline),
        ("get_flag", 2, context::get_flag),
        ("set_flag", 3, context::set_flag),
        ("engine_info", 1, context::engine_info),
        ("set_engine_path", 2, context::set_engine_path),
        ("set_engine_home_dir", 2, context::set_engine_home_dir),
        ("pinentry_mode", 1, context::pinentry_mode),
        ("set_pinentry_mode", 2, context::set_pinentry_mode),
        ("import", 2, context::import, NifScheduleFlags::DirtyIo),
        ("find_key", 2, context::find_key, NifScheduleFlags::DirtyIo),
        ("delete_key", 2, context::delete_key, NifScheduleFlags::DirtyIo),
        ("delete_secret_key", 2, context::delete_secret_key, NifScheduleFlags::DirtyIo),
        ("decrypt", 2, context::decrypt, NifScheduleFlags::DirtyIo),
        ("encrypt_with_flags", 4, context::encrypt_with_flags, NifScheduleFlags::DirtyIo),
        ("sign_and_encrypt_with_flags", 4, context::sign_and_encrypt_with_flags, NifScheduleFlags::DirtyIo),
        ("sign_with_mode", 3, context::sign_with_mode, NifScheduleFlags::DirtyIo),
        ("verify_opaque", 3, context::verify_opaque, NifScheduleFlags::DirtyIo),
    ],
    Some(on_load)
}

fn on_load<'a>(env: NifEnv<'a>, _load_info: NifTerm<'a>) -> bool {
    resource_struct_init!(context::resource::ContextNifResource, env);
    resource_struct_init!(keys::KeyResource, env);
    true
}
