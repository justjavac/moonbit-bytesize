// This file is port from https://github.com/bytesize-rs/bytesize/blob/7467a23df30bc1fee48326e0fa6c063fc85676a2/src/lib.rs
// Copyright Apache-2.0 January 2004 The bytesize Authors. All rights reserved.

///|
/// `ByteSize` is a semantic wrapper for byte count representations.

///|
/// Number of bytes in 1 kilobyte.
pub const KB : UInt64 = 1_000

///|
/// Number of bytes in 1 megabyte.
pub const MB : UInt64 = 1_000_000

///|
/// Number of bytes in 1 gigabyte.
pub const GB : UInt64 = 1_000_000_000

///|
/// Number of bytes in 1 terabyte.
pub const TB : UInt64 = 1_000_000_000_000

///|
/// Number of bytes in 1 petabyte.
pub const PB : UInt64 = 1_000_000_000_000_000

///|
/// Number of bytes in 1 kibibyte.
pub const KIB : UInt64 = 1_024

///|
/// Number of bytes in 1 mebibyte.
pub const MIB : UInt64 = 1_048_576

///|
/// Number of bytes in 1 gibibyte.
pub const GIB : UInt64 = 1_073_741_824

///|
/// Number of bytes in 1 tebibyte.
pub const TIB : UInt64 = 1_099_511_627_776

///|
/// Number of bytes in 1 pebibyte.
pub const PIB : UInt64 = 1_125_899_906_842_624

///|
/// IEC (binary) units.
///
/// See <https://en.wikipedia.org/wiki/Kilobyte>.
const UNITS_IEC : String = "KMGTPE"

///|
/// SI (decimal) units.
///
/// See <https://en.wikipedia.org/wiki/Kilobyte>.
const UNITS_SI : String = "kMGTPE"

///|
/// `ln(1024) ~= 6.931`
const LN_KIB : Double = 6.931_471_805_599_453

///|
/// `ln(1000) ~= 6.908`
const LN_KB : Double = 6.907_755_278_982_137

///|
/// Converts a decimal kilobyte count into a raw byte count.
///
/// This helper uses the SI definition (`1 kB = 1000 bytes`) and returns the
/// primitive `UInt64` value directly. Use `ByteSize::kb` when you want the same
/// converted value wrapped in `ByteSize`.
pub fn kb(size : UInt64) -> UInt64 {
  size * KB
}

///|
/// Converts a binary kibibyte count into a raw byte count.
///
/// This helper uses the IEC definition (`1 KiB = 1024 bytes`) and returns the
/// primitive `UInt64` value directly. Use `ByteSize::kib` when you want the
/// converted value as a `ByteSize`.
pub fn kib(size : UInt64) -> UInt64 {
  size * KIB
}

///|
/// Converts a decimal megabyte count into a raw byte count.
///
/// This helper uses the SI definition (`1 MB = 1_000_000 bytes`) and is useful
/// when an API expects a primitive byte count instead of a `ByteSize` wrapper.
pub fn mb(size : UInt64) -> UInt64 {
  size * MB
}

///|
/// Converts a binary mebibyte count into a raw byte count.
///
/// This helper uses the IEC definition (`1 MiB = 1_048_576 bytes`) and returns
/// a plain `UInt64`. Use `ByteSize::mib` when you want formatting helpers too.
pub fn mib(size : UInt64) -> UInt64 {
  size * MIB
}

///|
/// Converts a decimal gigabyte count into a raw byte count.
///
/// The input is interpreted with SI units (`1 GB = 1_000_000_000 bytes`), so it
/// matches storage sizes that are commonly reported by disks and networks.
pub fn gb(size : UInt64) -> UInt64 {
  size * GB
}

///|
/// Converts a binary gibibyte count into a raw byte count.
///
/// The input is interpreted with IEC units (`1 GiB = 1_073_741_824 bytes`),
/// which is the unit family typically used for memory-style measurements.
pub fn gib(size : UInt64) -> UInt64 {
  size * GIB
}

///|
/// Converts a decimal terabyte count into a raw byte count.
///
/// This helper keeps the result as a primitive `UInt64`, making it convenient
/// when you only need the exact byte total and not the `ByteSize` API.
pub fn tb(size : UInt64) -> UInt64 {
  size * TB
}

///|
/// Converts a binary tebibyte count into a raw byte count.
///
/// This helper applies IEC scaling (`1 TiB = 1024 GiB`) and returns the exact
/// number of bytes without wrapping it in `ByteSize`.
pub fn tib(size : UInt64) -> UInt64 {
  size * TIB
}

///|
/// Converts a decimal petabyte count into a raw byte count.
///
/// This helper is useful for large SI quantities such as storage capacities and
/// data transfer reports that are expressed in base-10 units.
pub fn pb(size : UInt64) -> UInt64 {
  size * PB
}

///|
/// Converts a binary pebibyte count into a raw byte count.
///
/// This helper uses IEC scaling and returns the exact byte count as `UInt64`,
/// which is useful for large memory-style quantities.
pub fn pib(size : UInt64) -> UInt64 {
  size * PIB
}

///|
/// Semantic wrapper around a raw byte count.
///
/// `ByteSize` stores the canonical value in bytes while exposing constructors,
/// comparisons, arithmetic traits, and formatting helpers for SI and IEC output.
pub struct ByteSize {
  size : UInt64
} derive(Show, Eq, Compare, Hash, Default)

///|
/// Wraps an exact byte count in `ByteSize`.
///
/// This constructor does not perform any unit conversion. Use it when you
/// already have a byte count and want access to `ByteSize` formatting,
/// comparison, and arithmetic helpers.
pub fn ByteSize::b(size : UInt64) -> ByteSize {
  ByteSize::{ size, }
}

///|
/// Constructs a `ByteSize` from a decimal kilobyte count.
///
/// The input follows the SI definition (`1 kB = 1000 bytes`). This is the
/// wrapper-producing counterpart to `kb`, so it is convenient when you want the
/// converted value together with `ByteSize` display and comparison helpers.
pub fn ByteSize::kb(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * KB }
}

///|
/// Constructs a `ByteSize` from a binary kibibyte count.
///
/// The input follows the IEC definition (`1 KiB = 1024 bytes`). Choose this
/// constructor when you want binary units and the ergonomic `ByteSize` API.
pub fn ByteSize::kib(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * KIB }
}

///|
/// Constructs a `ByteSize` from a decimal megabyte count.
///
/// The input is interpreted in SI units, making it a good fit for disk, file,
/// and transfer sizes that are normally reported in base-10 units.
pub fn ByteSize::mb(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * MB }
}

///|
/// Constructs a `ByteSize` from a binary mebibyte count.
///
/// The input is interpreted in IEC units, which is useful for measurements that
/// are naturally expressed as powers of two, such as memory sizes.
pub fn ByteSize::mib(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * MIB }
}

///|
/// Constructs a `ByteSize` from a decimal gigabyte count.
///
/// This constructor uses SI scaling and returns a value that can be compared,
/// formatted, or combined with other `ByteSize` values.
pub fn ByteSize::gb(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * GB }
}

///|
/// Constructs a `ByteSize` from a binary gibibyte count.
///
/// This constructor uses IEC scaling and is useful when you want to preserve
/// the distinction between binary sizes and decimal storage labels.
pub fn ByteSize::gib(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * GIB }
}

///|
/// Constructs a `ByteSize` from a decimal terabyte count.
///
/// Use this constructor for very large SI quantities when you still want to
/// keep the value strongly typed as `ByteSize`.
pub fn ByteSize::tb(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * TB }
}

///|
/// Constructs a `ByteSize` from a binary tebibyte count.
///
/// This constructor preserves IEC semantics for very large binary quantities
/// while still returning a regular `ByteSize` wrapper.
pub fn ByteSize::tib(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * TIB }
}

///|
/// Constructs a `ByteSize` from a decimal petabyte count.
///
/// This is the SI counterpart to `ByteSize::pib` and is appropriate for
/// extremely large base-10 byte quantities.
pub fn ByteSize::pb(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * PB }
}

///|
/// Constructs a `ByteSize` from a binary pebibyte count.
///
/// This constructor uses IEC scaling for extremely large binary quantities and
/// keeps the result available through the `ByteSize` API.
pub fn ByteSize::pib(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * PIB }
}

///|
/// Returns the underlying byte count as a primitive `UInt64`.
///
/// This is useful when an external API expects a raw integer or when you need
/// to perform calculations outside the `ByteSize` wrapper.
pub fn ByteSize::as_u64(self : ByteSize) -> UInt64 {
  self.size
}

///|
/// Returns a formatting wrapper for this byte size.
///
/// The returned `Display` starts in IEC mode, so calling `to_string` on it will
/// produce output like `1 KiB` unless you switch to an SI variant first.
pub fn ByteSize::display(self : ByteSize) -> Display {
  Display::new(self.size)
}

///|
/// Formats this value using the default IEC display style.
///
/// This is equivalent to `self.display().to_string()` and produces strings such
/// as `1 KiB`, `419 MiB`, or `2 PiB`.
pub fn ByteSize::to_string(self : ByteSize) -> String {
  self.display().to_string()
}

///|
/// Formats this value with both human-readable text and the raw byte count.
///
/// The resulting string is intended for debugging and logs, where seeing the
/// friendly unit and the exact byte total at the same time is helpful.
pub fn ByteSize::debug_string(self : ByteSize) -> String {
  "\{self.to_string()} (\{self.size} bytes)"
}

///|
/// Addition: ByteSize + ByteSize = ByteSize
impl Add for ByteSize with add(self, rhs : ByteSize) -> ByteSize {
  ByteSize::{ size: rhs.size + self.size }
}

///|
/// Subtraction: ByteSize - ByteSize = ByteSize
impl Sub for ByteSize with sub(self, rhs : ByteSize) -> ByteSize {
  ByteSize::{ size: self.size - rhs.size }
}

///|
/// Multiplication: ByteSize * ByteSize = ByteSize
impl Mul for ByteSize with mul(self, rhs : ByteSize) -> ByteSize {
  ByteSize::{ size: rhs.size * self.size }
}

///|
test "test_arithmetic_op" {
  let x = ByteSize::mb(1)
  let y = ByteSize::kb(100)
  assert_eq((x + y).as_u64(), 1_100_000UL)
  assert_eq((x - y).as_u64(), 900_000UL)
  assert_eq((x + ByteSize::b(100_000UL)).as_u64(), 1_100_000UL)
  assert_eq((x * ByteSize::b(2UL)).as_u64(), 2_000_000UL)

  // Test commutative operations
  assert_eq((ByteSize::b(2UL) * x).as_u64(), 2_000_000UL)
  assert_eq((ByteSize::b(100_000UL) + x).as_u64(), 1_100_000UL)
}

///|
test "test_arithmetic_primitives" {
  let x = ByteSize::mb(1)
  assert_eq((x + ByteSize::b(1_000_000)).as_u64(), 2_000_000UL)
  assert_eq((x + ByteSize::b(1_000)).as_u64(), 1_001_000UL)
  assert_eq((x - ByteSize::b(1_000_000)).as_u64(), 0UL)
  assert_eq((x - ByteSize::b(1_000)).as_u64(), 999_000UL)

  // Test with different integer types
  assert_eq((x + ByteSize::b(1000000)).as_u64(), 2_000_000UL)
  assert_eq((x + ByteSize::b(1000)).as_u64(), 1_001_000UL)
}

///|
test "test_comparison" {
  assert_true(ByteSize::mb(1) == ByteSize::kb(1000))
  assert_true(ByteSize::mib(1) == ByteSize::kib(1024))
  assert_true(ByteSize::mb(1) != ByteSize::kib(1024))
  assert_true(ByteSize::mb(1) < ByteSize::kib(1024))
  assert_true(ByteSize::b(0) < ByteSize::tib(1))
}

///|
test "test_display" {
  assert_eq("215 B", ByteSize::b(215).to_string())
  assert_eq("1 KiB", ByteSize::kib(1).to_string())
  assert_eq("301 KiB", ByteSize::kib(301).to_string())
  assert_eq("419 MiB", ByteSize::mib(419).to_string())
  assert_eq("518 GiB", ByteSize::gib(518).to_string())
  assert_eq("815 TiB", ByteSize::tib(815).to_string())
  assert_eq("609 PiB", ByteSize::pib(609).to_string())
}

///|
test "test_display_formats" {
  let size = ByteSize::mb(1)

  // Test different format styles
  assert_eq(size.display().si().to_string(), "1 MB")
  assert_eq(size.display().si_short().to_string(), "1M")
}

///|
test "test_default" {
  let default_size = ByteSize::{ size: 0UL }
  assert_eq(ByteSize::b(0), default_size)
}

///|
test "test_constructor_consistency" {
  // Test that constructors work correctly
  assert_eq(ByteSize::kb(1).as_u64(), KB)
  assert_eq(ByteSize::kib(1).as_u64(), KIB)
  assert_eq(ByteSize::mb(1).as_u64(), MB)
  assert_eq(ByteSize::mib(1).as_u64(), MIB)
  assert_eq(ByteSize::gb(1).as_u64(), GB)
  assert_eq(ByteSize::gib(1).as_u64(), GIB)
  assert_eq(ByteSize::tb(1).as_u64(), TB)
  assert_eq(ByteSize::tib(1).as_u64(), TIB)
  assert_eq(ByteSize::pb(1).as_u64(), PB)
  assert_eq(ByteSize::pib(1).as_u64(), PIB)
}

///|
test "test_large_values" {
  let large_size = ByteSize::tb(5)
  let another_large = ByteSize::pb(1)
  assert_true(large_size < another_large)
  assert_eq((large_size + ByteSize::gb(500)).as_u64(), 5_500_000_000_000UL)
}

///|
test "test_zero_and_small_values" {
  let zero = ByteSize::b(0)
  let one_byte = ByteSize::b(1)
  let small = ByteSize::b(512)
  assert_true(zero < one_byte)
  assert_true(one_byte < small)
  assert_eq((small + one_byte).as_u64(), 513UL)
  assert_eq((small - one_byte).as_u64(), 511UL)
}

///|
test "test_edge_cases" {
  // Test edge cases and boundary conditions
  let max_kb = ByteSize::b(1023)
  let min_kib = ByteSize::kib(1)

  // 1023 KB should be less than 1 KiB
  assert_true(max_kb < min_kib)

  // Test multiplication doesn't overflow with reasonable values
  let result = ByteSize::mb(1000) * ByteSize::b(2UL)
  assert_eq(result.as_u64(), 2_000_000_000UL)
}

///|
test "test_default_method" {
  let default_size = ByteSize::default()
  assert_eq(default_size, ByteSize::b(0))
}
