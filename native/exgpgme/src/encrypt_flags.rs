use rustler::{NifError};
use rustler::types::list::NifListIterator;
use gpgme;
use gpgme::EncryptFlags;

pub fn arg_to_protocol(atoms: NifListIterator) -> Result<EncryptFlags, NifError> {
    let mut flags = EncryptFlags::empty();

    for atom in atoms {
        let name = atom.atom_to_string()?;

        flags.insert(string_to_flag(name)?);
    }
    
    Ok(flags)
}

pub fn string_to_flag(name: String) -> Result<EncryptFlags, NifError> {
    match name.as_ref() {
      "always_trust" => Ok(gpgme::ENCRYPT_ALWAYS_TRUST),
      "expect_sign" => Ok(gpgme::ENCRYPT_EXPECT_SIGN),
      "no_compress" => Ok(gpgme::ENCRYPT_NO_COMPRESS),
      "no_encrypt_to" => Ok(gpgme::ENCRYPT_NO_ENCRYPT_TO),
      "prepare" => Ok(gpgme::ENCRYPT_PREPARE),
      "symmetric" => Ok(gpgme::ENCRYPT_SYMMETRIC),
      "throw_keyids" => Ok(gpgme::ENCRYPT_THROW_KEYIDS),
      "wrap" => Ok(gpgme::ENCRYPT_WRAP),
      _ => Err(NifError::BadArg)
    }
}
