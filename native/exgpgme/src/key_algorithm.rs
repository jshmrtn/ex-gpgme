use rustler::{NifEnv, NifTerm, NifEncoder};
use gpgme::KeyAlgorithm;

mod atoms {
    rustler_atoms! {
        atom rsa;
        atom rsa_encrypt;
        atom rsa_sign;
        atom elgamal_encrypt;
        atom dsa;
        atom ecc;
        atom elgamal;
        atom ecdsa;
        atom ecdh;
        atom eddsa;
        atom other;
    }
}

pub fn transform_key_algorithm<'a>(env: NifEnv<'a>, algorithm: KeyAlgorithm) -> NifTerm<'a> {
    match algorithm {
        KeyAlgorithm::Rsa => atoms::rsa().encode(env),
        KeyAlgorithm::RsaEncrypt => atoms::rsa_encrypt().encode(env),
        KeyAlgorithm::RsaSign => atoms::rsa_sign().encode(env),
        KeyAlgorithm::ElgamalEncrypt => atoms::elgamal_encrypt().encode(env),
        KeyAlgorithm::Dsa => atoms::dsa().encode(env),
        KeyAlgorithm::Ecc => atoms::ecc().encode(env),
        KeyAlgorithm::Elgamal => atoms::elgamal().encode(env),
        KeyAlgorithm::Ecdsa => atoms::ecdsa().encode(env),
        KeyAlgorithm::Ecdh => atoms::ecdh().encode(env),
        KeyAlgorithm::Eddsa => atoms::eddsa().encode(env),
        KeyAlgorithm::Other(other) => (atoms::other(), other).encode(env),
    }
}
