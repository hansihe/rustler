use rustler::ErlOption;

#[rustler::nif]
pub fn add_u32(a: u32, b: u32) -> u32 {
    a + b
}

#[rustler::nif]
pub fn add_i32(a: i32, b: i32) -> i32 {
    a + b
}

#[rustler::nif]
pub fn echo_u8(n: u8) -> u8 {
    n
}

#[rustler::nif]
pub fn option_inc(opt: Option<f64>) -> Option<f64> {
    opt.map(|num| num + 1.0)
}

#[rustler::nif]
pub fn erlang_option_inc(opt: ErlOption<f64>) -> ErlOption<f64> {
    opt.as_ref().map(|num| num + 1.0).into()
}

#[rustler::nif]
pub fn result_to_int(res: Result<bool, &str>) -> Result<usize, String> {
    match res {
        Ok(true) => Ok(1),
        Ok(false) => Ok(0),
        Err(errstr) => Err(format!("{}{}", errstr, errstr)),
    }
}

#[rustler::nif]
pub fn echo_u128(n: u128) -> u128 {
    n
}

#[rustler::nif]
pub fn echo_i128(n: i128) -> i128 {
    n
}
