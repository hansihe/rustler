use super::{
    nif_filler::{self, DynNifFiller},
    types::*,
};

static mut DYN_NIF_CALLBACKS: DynNifCallbacks =
    unsafe { std::mem::MaybeUninit::zeroed().assume_init() };

pub unsafe fn internal_set_symbols(callbacks: DynNifCallbacks) {
    DYN_NIF_CALLBACKS = callbacks;
}

pub unsafe fn internal_write_symbols() {
    let filler = nif_filler::new();
    DYN_NIF_CALLBACKS.write_symbols(filler);
}

/// See [enif_make_pid](http://erlang.org/doc/man/erl_nif.html#enif_make_pid) in the Erlang docs
pub unsafe fn enif_make_pid(_env: *mut ErlNifEnv, pid: ErlNifPid) -> ERL_NIF_TERM {
    pid.pid
}

/// See [enif_compare_pids](http://erlang.org/doc/man/erl_nif.html#enif_compare_pids) in the Erlang docs
pub unsafe fn enif_compare_pids(pid1: *const ErlNifPid, pid2: *const ErlNifPid) -> c_int {
    // Mimics the implementation of the enif_compare_pids macro
    enif_compare((*pid1).pid, (*pid2).pid)
}

// Include the file generated by `build.rs`.
include!(concat!(env!("OUT_DIR"), "/nif_api.snippet.rs"));
// example of included content:
// extern "C" {
//     pub fn enif_priv_data(arg1: *mut ErlNifEnv) -> *mut c_void;
//     pub fn enif_alloc(size: size_t) -> *mut c_void;
//     pub fn enif_free(ptr: *mut c_void);
//     pub fn enif_is_atom(arg1: *mut ErlNifEnv, term: ERL_NIF_TERM) -> c_int;
//     pub fn enif_is_binary(arg1: *mut ErlNifEnv, term: ERL_NIF_TERM) -> c_int;
// ...