use gpgme::SignMode;
use rustler::{NifTerm, NifError};
use rustler::TermType;
use rustler::types::tuple;

pub fn arg_to_sign_mode(arg: NifTerm) -> Result<SignMode, NifError> {
    match arg.get_type() {
        TermType::Atom => {
            let input_protocol = arg.atom_to_string()?;
            match input_protocol.as_ref() {
                "normal" => Ok(SignMode::Normal),
                "detached" => Ok(SignMode::Detached),
                "clear" => Ok(SignMode::Clear),
                _ => Err(NifError::BadArg)
            }
        },
        TermType::Tuple => {
            let tuple = tuple::get_tuple(arg)?;
            let name: String = tuple[0].atom_to_string()?;
            let other: u32 = tuple[1].decode()?;
            if name == "other" {
                Ok(SignMode::Other(other))
            } else {
                Err(NifError::BadArg)
            }
        },
        _ => Err(NifError::BadArg)
    }
}
