macro_rules! string_or_null {
    ($expr:expr, $env:ident) => (match $expr {
        Ok(result) => Ok(String::from(result).encode($env)),
        Err(None) => Ok($crate::rustler::types::atom::nil().encode($env)),
        Err(Some(error)) => Err(error)
    });
}
