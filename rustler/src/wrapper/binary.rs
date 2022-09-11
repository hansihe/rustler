use crate::wrapper::size_t;
use crate::{Env, Term};
pub(crate) use rustler_sys::ErlNifBinary;
use std::mem::MaybeUninit;

pub use rustler_sys::{
    enif_make_resource_binary as make_resource_binary, enif_make_sub_binary as make_sub_binary,
};

pub unsafe fn alloc(size: size_t) -> Option<ErlNifBinary> {
    let mut binary = MaybeUninit::uninit();
    let success = rustler_sys::enif_alloc_binary(size, binary.as_mut_ptr());
    if success == 0 {
        return None;
    }
    Some(binary.assume_init())
}

pub unsafe fn realloc(binary: &mut ErlNifBinary, size: size_t) -> bool {
    let success = rustler_sys::enif_realloc_binary(binary, size);
    success != 0
}

pub unsafe fn new_binary(env: Env, size: size_t) -> (*mut u8, Term) {
    let mut term = MaybeUninit::uninit();
    let buf = rustler_sys::enif_make_new_binary(env.as_c_arg(), size, term.as_mut_ptr());
    if buf.is_null() {
        panic!("enif_make_new_binary: allocation failed");
    }
    (buf, Term::new(env, term.assume_init()))
}
