use rustler::{NifError};
use rustler::types::list::NifListIterator;
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
      "always_trust" => Ok(EncryptFlags::ALWAYS_TRUST),
      "expect_sign" => Ok(EncryptFlags::EXPECT_SIGN),
      "no_compress" => Ok(EncryptFlags::NO_COMPRESS),
      "no_encrypt_to" => Ok(EncryptFlags::NO_ENCRYPT_TO),
      "prepare" => Ok(EncryptFlags::PREPARE),
      "symmetric" => Ok(EncryptFlags::SYMMETRIC),
      "throw_keyids" => Ok(EncryptFlags::THROW_KEYIDS),
      "wrap" => Ok(EncryptFlags::WRAP),
      _ => Err(NifError::BadArg)
    }
}
