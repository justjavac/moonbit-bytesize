// This file is port from https://github.com/bytesize-rs/bytesize/blob/7467a23df30bc1fee48326e0fa6c063fc85676a2/src/display.rs
// Copyright Apache-2.0 January 2004 The bytesize Authors. All rights reserved.

///| Format / style to use when displaying a [`ByteSize`].
pub enum Format {
  Iec
  IecShort
  Si
  SiShort
} derive(Show)

///|
pub fn Format::unit(self : Format) -> UInt64 {
  match self {
    Format::Iec | Format::IecShort => KIB
    Format::Si | Format::SiShort => KB
  }
}

///|
pub fn Format::unit_base(self : Format) -> Double {
  match self {
    Format::Iec | Format::IecShort => LN_KIB
    Format::Si | Format::SiShort => LN_KB
  }
}

///|
pub fn Format::unit_prefixes(self : Format) -> String {
  match self {
    Format::Iec | Format::IecShort => UNITS_IEC
    Format::Si | Format::SiShort => UNITS_SI
  }
}

///|
pub fn Format::unit_separator(self : Format) -> String {
  match self {
    Format::Iec | Format::Si => " "
    Format::IecShort | Format::SiShort => ""
  }
}

///|
pub fn Format::unit_suffix(self : Format) -> String {
  match self {
    Format::Iec => "iB"
    Format::Si => "B"
    Format::IecShort | Format::SiShort => ""
  }
}

///| Formatting display wrapper for byte sizes.
/// 
/// Supports various styles. By default, the IEC style is used.
pub struct Display {
  byte_size : UInt64
  format : Format
} derive(Show)

///| Create a new Display with the given byte size and default IEC format.
pub fn Display::new(byte_size : UInt64) -> Display {
  { byte_size, format: Format::Iec }
}

///| Format using IEC (binary) units.
/// 
/// E.g., `11.8 MiB`.
pub fn Display::iec(self : Display) -> Display {
  { ..self, format: Format::Iec }
}

///| Format using a short style and IEC (binary) units.
/// 
/// E.g., `11.8M`.
/// 
/// Designed to produce output compatible with `sort -h`.
pub fn Display::iec_short(self : Display) -> Display {
  { ..self, format: Format::IecShort }
}

///| Format using SI (decimal) units.
/// 
/// E.g., `12.3 MB`.
pub fn Display::si(self : Display) -> Display {
  { ..self, format: Format::Si }
}

///| Format using a short style and SI (decimal) units.
/// 
/// E.g., `12.3M`.
pub fn Display::si_short(self : Display) -> Display {
  { ..self, format: Format::SiShort }
}

///| Helper function to calculate ideal unit for no-std contexts.
pub fn ideal_unit_no_std(size : Double, unit : UInt64) -> Int {
  let mut ideal_prefix = 0
  let mut ideal_size = size
  let unit_f = unit.to_double()
  while true {
    ideal_prefix += 1
    ideal_size /= unit_f
    if ideal_size < unit_f {
      break
    }
  }
  ideal_prefix
}

///| Helper function to calculate ideal unit using logarithms.
fn ideal_unit_std(size : Double, unit_base : Double) -> Int {
  let exp = (@math.ln(size) / unit_base).to_int()
  if exp == 0 {
    1
  } else {
    exp
  }
}

///| Convert Display to string representation.
/// 
/// ## example
/// ```moonbit
/// assert_eq("518 GiB", @bytesize.ByteSize::gib(518).display().iec().to_string())
/// assert_eq("556.2 GB", @bytesize.ByteSize::gib(518).display().si().to_string())
/// assert_eq("518G", @bytesize.ByteSize::gib(518).display().iec_short().to_string())
/// ```
pub fn Display::to_string(self : Display, precision~ : Int = 1) -> String {
  let bytes = self.byte_size
  let unit = self.format.unit()
  let unit_base = self.format.unit_base()
  let unit_prefixes = self.format.unit_prefixes()
  let unit_separator = self.format.unit_separator()
  let unit_suffix = self.format.unit_suffix()
  if bytes < unit {
    "\{bytes}\{unit_separator}B"
  } else {
    let size = bytes.to_double()
    let exp = ideal_unit_std(size, unit_base)
    let unit_prefix = Int::to_char(unit_prefixes.charcode_at(exp - 1))
      .unwrap()
      .to_string()
    let unit_power = unit.to_double().pow(exp.to_double())
    let value = size / unit_power

    // Format the number with specified precision
    let formatted_value = format_double_with_precision(value, precision)
    "\{formatted_value}\{unit_separator}\{unit_prefix}\{unit_suffix}"
  }
}

///| Helper function to format a double with specified precision.
fn format_double_with_precision(value : Double, precision : Int) -> String {
  // Simple implementation - in a real scenario you might want more sophisticated formatting
  let multiplier = 10.0.pow(precision.to_double())
  let rounded = @math.round(value * multiplier) / multiplier
  rounded.to_string()
}

///|
test "ideal_unit_selection_std_no_std_iec" {
  let bytes = ByteSize::kib(2) // 2048 bytes
  if bytes.as_u64() < 1025UL {
    return
  }
  let size = bytes.as_u64().to_double()
  let std_result = ideal_unit_std(size, LN_KIB)
  let no_std_result = ideal_unit_no_std(size, KIB)
  assert_eq(std_result, no_std_result)
}

///|
test "ideal_unit_selection_std_no_std_si" {
  let bytes = ByteSize::kb(2) // 2000 bytes
  if bytes.as_u64() < 1025UL {
    return
  }
  let size = bytes.as_u64().to_double()
  let std_result = ideal_unit_std(size, LN_KB)
  let no_std_result = ideal_unit_no_std(size, KB)
  assert_eq(std_result, no_std_result)
}

///|
test "to_string_iec" {
  let display = Display::{
    byte_size: ByteSize::gib(1).as_u64(),
    format: Format::Iec,
  }
  assert_eq("1 GiB", display.to_string())
  let display2 = Display::{
    byte_size: ByteSize::gb(1).as_u64(),
    format: Format::Iec,
  }
  assert_eq("953.7 MiB", display2.to_string())
}

///|
test "to_string_si" {
  let display = Display::{
    byte_size: ByteSize::gib(1).as_u64(),
    format: Format::Si,
  }
  assert_eq("1.1 GB", display.to_string())
  let display2 = Display::{
    byte_size: ByteSize::gb(1).as_u64(),
    format: Format::Si,
  }
  assert_eq("1 GB", display2.to_string())
}

///|
test "to_string_short" {
  let display = Display::{
    byte_size: ByteSize::gib(1).as_u64(),
    format: Format::IecShort,
  }
  assert_eq("1G", display.to_string())
  let display2 = Display::{
    byte_size: ByteSize::gb(1).as_u64(),
    format: Format::IecShort,
  }
  assert_eq("953.7M", display2.to_string())
}

///| Helper function for display string assertions
fn assert_to_string(
  expected : String,
  byte_size : ByteSize,
  format : Format
) -> Unit raise {
  let display = Display::{ byte_size: byte_size.as_u64(), format }
  assert_eq(expected, display.to_string())
}

///|
test "test_to_string_as" {
  assert_to_string("215 B", ByteSize::b(215), Format::Iec)
  assert_to_string("215 B", ByteSize::b(215), Format::Si)
  assert_to_string("1 KiB", ByteSize::kib(1), Format::Iec)
  assert_to_string("1 kB", ByteSize::kib(1), Format::Si)
  assert_to_string("293.9 KiB", ByteSize::kb(301), Format::Iec)
  assert_to_string("301 kB", ByteSize::kb(301), Format::Si)
  assert_to_string("1 MiB", ByteSize::mib(1), Format::Iec)
  assert_to_string("1 MB", ByteSize::mib(1), Format::Si)
  assert_to_string("1.9 GiB", ByteSize::mib(1907), Format::Iec)
  assert_to_string("2 GB", ByteSize::mib(1908), Format::Si)
  assert_to_string("399.6 MiB", ByteSize::mb(419), Format::Iec)
  assert_to_string("419 MB", ByteSize::mb(419), Format::Si)
  assert_to_string("482.4 GiB", ByteSize::gb(518), Format::Iec)
  assert_to_string("518 GB", ByteSize::gb(518), Format::Si)
  assert_to_string("741.2 TiB", ByteSize::tb(815), Format::Iec)
  assert_to_string("815 TB", ByteSize::tb(815), Format::Si)
  assert_to_string("540.9 PiB", ByteSize::pb(609), Format::Iec)
  assert_to_string("609 PB", ByteSize::pb(609), Format::Si)
}

///|
test "precision" {
  let size = ByteSize::mib(1908)

  // Test default precision (1 decimal place)
  assert_eq("1.9 GiB", size.to_string())

  // Test precision 0
  assert_eq("2 GiB", size.display().to_string(precision=0))

  // Test precision 5
  assert_eq("1.86328 GiB", size.display().to_string(precision=5))
}

///|
test "precision_with_different_formats" {
  let size = ByteSize::gb(1)

  // Test IEC format with different precisions
  assert_eq("953.7 MiB", size.display().iec().to_string(precision=1))
  assert_eq("954 MiB", size.display().iec().to_string(precision=0))
  assert_eq("953.67432 MiB", size.display().iec().to_string(precision=5))

  // Test SI format with different precisions
  assert_eq("1 GB", size.display().si().to_string(precision=1))
  assert_eq("1 GB", size.display().si().to_string(precision=0))
  assert_eq("1 GB", size.display().si().to_string(precision=5))
}

///|
test "short_format_precision" {
  let size = ByteSize::mib(1500)

  // Test IEC short format
  assert_eq("1.5G", size.display().iec_short().to_string(precision=1))
  assert_eq("1G", size.display().iec_short().to_string(precision=0))

  // Test SI short format
  assert_eq("1.6G", size.display().si_short().to_string(precision=1))
  assert_eq("2G", size.display().si_short().to_string(precision=0))
}

///|
test "bytes_display" {
  // Test that bytes are always displayed as whole numbers regardless of precision
  let small_size = ByteSize::b(42)
  assert_eq("42 B", small_size.display().iec().to_string(precision=1))
  assert_eq("42 B", small_size.display().iec().to_string(precision=0))
  assert_eq("42 B", small_size.display().iec().to_string(precision=5))
  assert_eq("42 B", small_size.display().si().to_string(precision=1))
  assert_eq("42 B", small_size.display().si().to_string(precision=0))
  assert_eq("42 B", small_size.display().si().to_string(precision=5))
}

///|
test "large_values_precision" {
  let large_size = ByteSize::pib(2)
  assert_eq("2 PiB", large_size.display().iec().to_string(precision=1))
  assert_eq("2 PiB", large_size.display().iec().to_string(precision=0))

  // Test corresponding SI display
  assert_eq("2.3 PB", large_size.display().si().to_string(precision=1))
  assert_eq("2 PB", large_size.display().si().to_string(precision=0))
}
