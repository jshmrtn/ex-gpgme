use rustler::{NifEnv, NifTerm, NifEncoder};
use gpgme::results::PkaTrust;

mod atoms {
    rustler_atoms! {
        atom unknown;
        atom bad;
        atom okay;
        atom other;
    }
}

pub fn transform_pka_trust<'a>(env: NifEnv<'a>, trust: PkaTrust) -> NifTerm<'a> {
    match trust {
        PkaTrust::Unknown => atoms::unknown().encode(env),
        PkaTrust::Bad => atoms::bad().encode(env),
        PkaTrust::Okay => atoms::okay().encode(env),
        PkaTrust::Other(other) => (atoms::other(), other).encode(env),
    }
}
