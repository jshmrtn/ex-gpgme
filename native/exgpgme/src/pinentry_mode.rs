use gpgme::PinentryMode;
use rustler::{NifTerm, NifEnv, NifEncoder, NifError};
use rustler::TermType;
use rustler::types::tuple;

mod atoms {
    rustler_atoms! {
        atom default;
        atom ask;
        atom cancel;
        atom error;
        atom loopback;
        atom other;
    }
}

pub fn pinentry_mode_to_term<'a>(pinentry_mode: PinentryMode, env: NifEnv<'a>) -> NifTerm<'a> {
    match pinentry_mode {
        PinentryMode::Default => atoms::default().encode(env),
        PinentryMode::Ask => atoms::ask().encode(env),
        PinentryMode::Cancel => atoms::cancel().encode(env),
        PinentryMode::Error => atoms::error().encode(env),
        PinentryMode::Loopback => atoms::loopback().encode(env),
        PinentryMode::Other(other) => (atoms::other(), other).encode(env)
    }
}

pub fn arg_to_pinentry_mode(arg: NifTerm) -> Result<PinentryMode, NifError> {
    match arg.get_type() {
        TermType::Atom => {
            let input_protocol = arg.atom_to_string()?;
            match input_protocol.as_ref() {
                "default" => Ok(PinentryMode::Default),
                "ask" => Ok(PinentryMode::Ask),
                "cancel" => Ok(PinentryMode::Cancel),
                "error" => Ok(PinentryMode::Error),
                "loopback" => Ok(PinentryMode::Loopback),
                _ => Err(NifError::BadArg)
            }
        },
        TermType::Tuple => {
            let tuple = tuple::get_tuple(arg)?;
            let name: String = tuple[0].atom_to_string()?;
            let other: u32 = tuple[1].decode()?;
            if name == "other" {
                Ok(PinentryMode::Other(other))
            } else {
                Err(NifError::BadArg)
            }
        },
        _ => Err(NifError::BadArg)
    }
}
