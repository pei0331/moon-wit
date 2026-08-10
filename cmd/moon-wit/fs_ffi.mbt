///|
/// Native file I/O via MoonBit runtime FFI helpers (`moonbit_f*_ffi`).
/// Only compiled on the native target (see `moon.pkg` `options(targets)`).
#external
priv type CFile

///|
#borrow(ptr)
extern "c" fn is_null(ptr : CFile) -> Int = "moonbit_is_null"

///|
#borrow(path, mode)
extern "c" fn fopen_ffi(path : Bytes, mode : Bytes) -> CFile = "moonbit_fopen_ffi"

///|
#borrow(ptr, stream)
extern "c" fn fread_ffi(
  ptr : Bytes,
  size : Int,
  nitems : Int,
  stream : CFile,
) -> Int = "moonbit_fread_ffi"

///|
#borrow(ptr, stream)
extern "c" fn fwrite_ffi(
  ptr : Bytes,
  size : Int,
  nitems : Int,
  stream : CFile,
) -> Int = "moonbit_fwrite_ffi"

///|
#borrow(stream)
extern "c" fn fseek_ffi(stream : CFile, offset : Int, whence : Int) -> Int = "moonbit_fseek_ffi"

///|
#borrow(stream)
extern "c" fn ftell_ffi(stream : CFile) -> Int = "moonbit_ftell_ffi"

///|
#borrow(stream)
extern "c" fn fclose_ffi(stream : CFile) -> Int = "moonbit_fclose_ffi"

///|
extern "c" fn make_bytes_raw(len : Int) -> Bytes = "moonbit_make_bytes_raw"

///|
/// UTF-8 encode `s` and append a NUL byte, producing a C string.
fn c_string(s : String) -> Bytes {
  let b = @utf8.encode(s)
  let len = b.length()
  let arr = FixedArray::make(len + 1, b'\x00')
  for i in 0..<len {
    arr[i] = b[i]
  }
  arr.unsafe_reinterpret_as_bytes()
}

///|
/// Read a whole text file as UTF-8. Returns `None` if the file cannot be opened.
pub fn read_file(path : String) -> String? {
  let path_bytes = c_string(path)
  let mode = c_string("rb")
  let f = fopen_ffi(path_bytes, mode)
  if is_null(f) != 0 {
    return None
  }
  ignore(fseek_ffi(f, 0, 2))
  let len = ftell_ffi(f)
  ignore(fseek_ffi(f, 0, 0))
  let buf = make_bytes_raw(len)
  let n = fread_ffi(buf, 1, len, f)
  ignore(fclose_ffi(f))
  let view = buf.view(start=0, end=n)
  Some(@utf8.decode_lossy(view))
}

///|
/// Write text (UTF-8) to a file, truncating it if it exists.
/// Returns `false` if the file cannot be opened or written fully.
pub fn write_file(path : String, content : String) -> Bool {
  let path_bytes = c_string(path)
  let mode = c_string("wb")
  let f = fopen_ffi(path_bytes, mode)
  if is_null(f) != 0 {
    return false
  }
  let content_bytes = @utf8.encode(content)
  let n = fwrite_ffi(content_bytes, 1, content_bytes.length(), f)
  ignore(fclose_ffi(f))
  n == content_bytes.length()
}
