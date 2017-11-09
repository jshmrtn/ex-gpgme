use rustler::resource::ResourceArc;
use std::sync::{Arc, RwLock};
use gpgme::Context;

pub struct ContextNifResource {
    pub context: Arc<RwLock<Context>>
}
unsafe impl Send for ContextNifResource {}
unsafe impl Sync for ContextNifResource {}

pub fn wrap_context(context: Context) -> ResourceArc<ContextNifResource> {
    ResourceArc::new(ContextNifResource{
        context: Arc::new(RwLock::new(context))
    })
}

macro_rules! unpack_immutable_context {
    ($context:ident, $arg:expr) => (
        let context_arc: $crate::rustler::resource::ResourceArc<::context::resource::ContextNifResource> = $arg.decode()?;
        let $context = context_arc.deref().context.read().unwrap();
    );
}

macro_rules! unpack_mutable_context {
    ($context:ident, $arg:expr) => (
        let context_arc: $crate::rustler::resource::ResourceArc<::context::resource::ContextNifResource> = $arg.decode()?;
        let mut $context = context_arc.deref().context.write().unwrap();
    );
}
