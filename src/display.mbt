// This file is port from https://github.com/bytesize-rs/bytesize/blob/7467a23df30bc1fee48326e0fa6c063fc85676a2/src/display.rs
// Copyright Apache-2.0 January 2004 The bytesize Authors. All rights reserved.

///|
/// Formatting style used when rendering a `ByteSize`.
///
/// `Format` controls the unit family (IEC or SI), whether separators are kept,
/// and how suffixes such as `B` or `iB` are produced.
pub enum Format {
  Iec
  IecShort
  Si
  SiShort
} derive(Show)

///|
/// Returns the numeric unit step for this format.
///
/// IEC formats scale by `1024`, while SI formats scale by `1000`. `Display`
/// uses this value to decide when to promote bytes to the next unit.
pub fn Format::unit(self : Format) -> UInt64 {
  match self {
    Format::Iec | Format::IecShort => KIB
    Format::Si | Format::SiShort => KB
  }
}

///|
/// Returns the logarithmic base used for unit selection.
///
/// This value matches the natural logarithm of the format's unit step and is
/// used by `Display::to_string` to choose the best prefix efficiently.
pub fn Format::unit_base(self : Format) -> Double {
  match self {
    Format::Iec | Format::IecShort => LN_KIB
    Format::Si | Format::SiShort => LN_KB
  }
}

///|
/// Returns the sequence of unit prefixes for this format.
///
/// IEC formats use uppercase binary prefixes such as `K`, `M`, and `G`, while
/// SI formats use the decimal sequence beginning with lowercase `k`.
pub fn Format::unit_prefixes(self : Format) -> String {
  match self {
    Format::Iec | Format::IecShort => UNITS_IEC
    Format::Si | Format::SiShort => UNITS_SI
  }
}

///|
/// Returns the separator inserted between the numeric value and unit text.
///
/// Long formats keep a space, such as `1 KiB` or `1 MB`, while the short
/// formats omit it to produce strings such as `1K` and `1M`.
pub fn Format::unit_separator(self : Format) -> String {
  match self {
    Format::Iec | Format::Si => " "
    Format::IecShort | Format::SiShort => ""
  }
}

///|
/// Returns the suffix appended after the unit prefix.
///
/// IEC long format uses `iB`, SI long format uses `B`, and the short formats
/// omit the suffix entirely.
pub fn Format::unit_suffix(self : Format) -> String {
  match self {
    Format::Iec => "iB"
    Format::Si => "B"
    Format::IecShort | Format::SiShort => ""
  }
}

///|
/// Formatting wrapper for byte sizes.
///
/// `Display` stores the raw byte count together with the selected `Format`.
/// Newly created instances default to IEC formatting until you switch styles.
pub struct Display {
  byte_size : UInt64
  format : Format
} derive(Show)

///|
/// Creates a display wrapper with the default IEC format.
///
/// The provided `byte_size` is stored unchanged. Call `si`, `si_short`, or
/// `iec_short` on the returned value when you want a different rendering style.
pub fn Display::new(byte_size : UInt64) -> Display {
  { byte_size, format: Format::Iec }
}

///|
/// Switches the display wrapper to IEC long format.
///
/// This produces output such as `11.8 MiB`, with a separating space and the
/// binary `iB` suffix.
pub fn Display::iec(self : Display) -> Display {
  { ..self, format: Format::Iec }
}

///|
/// Switches the display wrapper to IEC short format.
///
/// This produces compact output such as `11.8M`. The short form is convenient
/// for narrow UI surfaces and shell output that is sorted with `sort -h`.
pub fn Display::iec_short(self : Display) -> Display {
  { ..self, format: Format::IecShort }
}

///|
/// Switches the display wrapper to SI long format.
///
/// This produces output such as `12.3 MB`, which matches the decimal unit
/// system commonly used by storage devices and transfer rates.
pub fn Display::si(self : Display) -> Display {
  { ..self, format: Format::Si }
}

///|
/// Switches the display wrapper to SI short format.
///
/// This produces compact decimal strings such as `12.3M`, which are useful
/// when you want SI semantics but minimal visual noise.
pub fn Display::si_short(self : Display) -> Display {
  { ..self, format: Format::SiShort }
}

///|
/// Calculates the 1-based unit index using repeated division only.
///
/// This helper mirrors the format-selection logic without relying on logarithms,
/// which makes it useful in restricted environments or for validation tests.
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

///|
/// Calculates the same unit index as `ideal_unit_no_std` by using logarithms.
fn ideal_unit_std(size : Double, unit_base : Double) -> Int {
  let exp = (@math.ln(size) / unit_base).to_int()
  if exp == 0 {
    1
  } else {
    exp
  }
}

///|
/// Formats the stored byte count as a human-readable string.
///
/// Values smaller than the first unit are rendered as bytes, while larger
/// values are promoted to the most suitable unit for the active `Format`.
/// `precision` controls how many decimal places are kept after rounding.
pub fn Display::to_string(self : Display, precision? : Int = 1) -> String {
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
    let unit_prefix = match unit_prefixes.get_char(exp - 1) {
      Some(c) => c.to_string()
      None => "?"
    }
    let unit_power = @math.pow(unit.to_double(), exp.to_double())
    let value = size / unit_power

    // Format the number with specified precision
    let formatted_value = format_double_with_precision(value, precision)
    "\{formatted_value}\{unit_separator}\{unit_prefix}\{unit_suffix}"
  }
}

///|
/// Rounds a floating-point value to the requested number of decimal places.
fn format_double_with_precision(value : Double, precision : Int) -> String {
  // Simple implementation - in a real scenario you might want more sophisticated formatting
  let multiplier = @math.pow(10.0, precision.to_double())
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

///|
test "format_accessors" {
  let iec = Format::Iec
  let iec_short = Format::IecShort
  let si = Format::Si
  let si_short = Format::SiShort

  assert_eq(iec.unit(), KIB)
  assert_eq(si.unit(), KB)
  assert_true(iec.unit_base() > 6.9)
  assert_true(si.unit_base() > 6.8)
  assert_eq(iec.unit_prefixes(), "KMGTPE")
  assert_eq(si_short.unit_prefixes(), "kMGTPE")
  assert_eq(iec_short.unit_separator(), "")
  assert_eq(si.unit_separator(), " ")
  assert_eq(iec.unit_suffix(), "iB")
  assert_eq(si.unit_suffix(), "B")
  assert_eq(si_short.unit_suffix(), "")
}

///|
/// Keeps the display-format assertions concise across the formatting tests.
fn assert_to_string(
  expected : String,
  byte_size : ByteSize,
  format : Format,
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
