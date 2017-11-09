use rustler::{NifEnv, NifTerm, NifEncoder, NifError};
use rustler::TermType;
use rustler::types::tuple;
use gpgme::{Protocol};

mod atoms {
    rustler_atoms! {
        atom open_pgp;
        atom cms;
        atom gpg_conf;
        atom assuan;
        atom g13;
        atom ui_server;
        atom spawn;
        atom default;
        atom unknown;
        atom other;
    }
}

pub fn arg_to_protocol(arg: NifTerm) -> Result<Protocol, NifError> {
    match arg.get_type() {
        TermType::Atom => {
            let input_protocol = arg.atom_to_string()?;
            match input_protocol.as_ref() {
                "open_pgp" => Ok(Protocol::OpenPgp),
                "cms" => Ok(Protocol::Cms),
                "gpg_conf" => Ok(Protocol::GpgConf),
                "assuan" => Ok(Protocol::Assuan),
                "g13" => Ok(Protocol::G13),
                "ui_server" => Ok(Protocol::UiServer),
                "spawn" => Ok(Protocol::Spawn),
                "default" => Ok(Protocol::Default),
                "unknown" => Ok(Protocol::Unknown),
                _ => Err(NifError::BadArg)
            }
        },
        TermType::Tuple => {
            let tuple = tuple::get_tuple(arg)?;
            let name: String = tuple[0].atom_to_string()?;
            let other: u32 = tuple[1].decode()?;
            if name == "other" {
                Ok(Protocol::Other(other))
            } else {
                Err(NifError::BadArg)
            }
        },
        _ => Err(NifError::BadArg)
    }
}

pub fn protocol_to_nif(env: NifEnv, protocol: Protocol) -> NifTerm {
    match protocol {
        Protocol::OpenPgp => atoms::open_pgp().encode(env),
        Protocol::Cms => atoms::cms().encode(env),
        Protocol::GpgConf => atoms::gpg_conf().encode(env),
        Protocol::Assuan => atoms::assuan().encode(env),
        Protocol::G13 => atoms::g13().encode(env),
        Protocol::UiServer => atoms::ui_server().encode(env),
        Protocol::Spawn => atoms::spawn().encode(env),
        Protocol::Default => atoms::default().encode(env),
        Protocol::Unknown => atoms::unknown().encode(env),
        Protocol::Other(other) => (atoms::other(), other).encode(env)
    }
}
