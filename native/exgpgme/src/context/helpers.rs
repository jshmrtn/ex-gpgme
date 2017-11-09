pub mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
    }
}

macro_rules! try_gpgme {
    ($expr:expr, $env:expr) => (match $expr {
        Ok(val) => val,
        Err(err) => {
            return Ok((::context::helpers::atoms::error(), err.description().into_owned()).encode($env))
        }
    })
}

macro_rules! context_getter {
    ($name:ident, $context:ident, $env:ident, $body:expr) => (
        pub fn $name<'a>($env: $crate::rustler::NifEnv<'a>, args: &[$crate::rustler::NifTerm<'a>])
        -> $crate::rustler::NifResult<$crate::rustler::NifTerm<'a>> {
            unpack_immutable_context!($context, args[0]);
            Ok($body)
        }
    );
}

macro_rules! context_setter {
    ($name:ident, $context:ident, $env:ident, $arg: ident, $type:ident, $body:expr) => (
        pub fn $name<'a>($env: $crate::rustler::NifEnv<'a>, args: &[$crate::rustler::NifTerm<'a>])
        -> $crate::rustler::NifResult<$crate::rustler::NifTerm<'a>> {
            unpack_mutable_context!($context, args[0]);
            let $arg: $type = args[1].decode()?;

            $body;

            Ok(::context::helpers::atoms::ok().encode($env))
        }
    )
}

macro_rules! decode_context_result {
    ($name:ident, $env:ident) => (
        match String::from_utf8($name) {
            Ok(string) => Ok((::context::helpers::atoms::ok(), string).encode($env)),
            Err(_) => Ok((::context::helpers::atoms::error(), String::from("Could not decode cyphertext to utf8")).encode($env))
        }
    )
}
