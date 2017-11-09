use rustler::{NifEnv, NifTerm, NifEncoder};
use gpgme::Validity;

mod atoms {
    rustler_atoms! {
        atom unknown;
        atom undefined;
        atom never;
        atom marginal;
        atom full;
        atom ultimate;
    }
}

pub fn transform_validity<'a>(env: NifEnv<'a>, validity: Validity) -> NifTerm<'a> {
    match validity {
        Validity::Unknown => atoms::unknown().encode(env),
        Validity::Undefined => atoms::undefined().encode(env),
        Validity::Never => atoms::never().encode(env),
        Validity::Marginal => atoms::marginal().encode(env),
        Validity::Full => atoms::full().encode(env),
        Validity::Ultimate => atoms::ultimate().encode(env),
    }
}
