// This file is port from https://github.com/bytesize-rs/bytesize/blob/7467a23df30bc1fee48326e0fa6c063fc85676a2/src/lib.rs
// Copyright Apache-2.0 January 2004 The bytesize Authors. All rights reserved.

///| `ByteSize` is a semantic wrapper for byte count representations.

///| Number of bytes in 1 kilobyte.
pub const KB : UInt64 = 1_000

///| Number of bytes in 1 megabyte.
pub const MB : UInt64 = 1_000_000

///| Number of bytes in 1 gigabyte.
pub const GB : UInt64 = 1_000_000_000

///| Number of bytes in 1 terabyte.
pub const TB : UInt64 = 1_000_000_000_000

///| Number of bytes in 1 petabyte.
pub const PB : UInt64 = 1_000_000_000_000_000

///| Number of bytes in 1 kibibyte.
pub const KIB : UInt64 = 1_024

///| Number of bytes in 1 mebibyte.
pub const MIB : UInt64 = 1_048_576

///| Number of bytes in 1 gibibyte.
pub const GIB : UInt64 = 1_073_741_824

///| Number of bytes in 1 tebibyte.
pub const TIB : UInt64 = 1_099_511_627_776

///| Number of bytes in 1 pebibyte.
pub const PIB : UInt64 = 1_125_899_906_842_624

///| IEC (binary) units.
///
/// See <https://en.wikipedia.org/wiki/Kilobyte>.
const UNITS_IEC : String = "KMGTPE"

///| SI (decimal) units.
///
/// See <https://en.wikipedia.org/wiki/Kilobyte>.
const UNITS_SI : String = "kMGTPE"

///| `ln(1024) ~= 6.931`
const LN_KIB : Double = 6.931_471_805_599_453

///| `ln(1000) ~= 6.908`
const LN_KB : Double = 6.907_755_278_982_137

///| Converts a quantity of kilobytes to bytes.
pub fn kb(size : UInt64) -> UInt64 {
  size * KB
}

///| Converts a quantity of kibibytes to bytes.
pub fn kib(size : UInt64) -> UInt64 {
  size * KIB
}

///| Converts a quantity of megabytes to bytes.
pub fn mb(size : UInt64) -> UInt64 {
  size * MB
}

///| Converts a quantity of mebibytes to bytes.
pub fn mib(size : UInt64) -> UInt64 {
  size * MIB
}

///| Converts a quantity of gigabytes to bytes.
pub fn gb(size : UInt64) -> UInt64 {
  size * GB
}

///| Converts a quantity of gibibytes to bytes.
pub fn gib(size : UInt64) -> UInt64 {
  size * GIB
}

///| Converts a quantity of terabytes to bytes.
pub fn tb(size : UInt64) -> UInt64 {
  size * TB
}

///| Converts a quantity of tebibytes to bytes.
pub fn tib(size : UInt64) -> UInt64 {
  size * TIB
}

///| Converts a quantity of petabytes to bytes.
pub fn pb(size : UInt64) -> UInt64 {
  size * PB
}

///| Converts a quantity of pebibytes to bytes.
pub fn pib(size : UInt64) -> UInt64 {
  size * PIB
}

///| Byte size representation.
pub struct ByteSize {
  size : UInt64
} derive(Show, Eq, Compare, Hash, Default)

///| Constructs a byte size wrapper from a quantity of bytes.
pub fn ByteSize::b(size : UInt64) -> ByteSize {
  ByteSize::{ size, }
}

///| Constructs a byte size wrapper from a quantity of kilobytes.
/// 
/// ## example
/// ```moonbit
/// let size = ByteSize::kb(1)
/// assert_eq(size.as_u64(), 1000UL)
/// assert_true(@bytesize.ByteSize::kib(4) > @bytesize.ByteSize::kb(4))
/// ```
pub fn ByteSize::kb(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * KB }
}

///| Constructs a byte size wrapper from a quantity of kibibytes.
pub fn ByteSize::kib(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * KIB }
}

///| Constructs a byte size wrapper from a quantity of megabytes.
pub fn ByteSize::mb(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * MB }
}

///| Constructs a byte size wrapper from a quantity of mebibytes.
pub fn ByteSize::mib(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * MIB }
}

///| Constructs a byte size wrapper from a quantity of gigabytes.
pub fn ByteSize::gb(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * GB }
}

///| Constructs a byte size wrapper from a quantity of gibibytes.
pub fn ByteSize::gib(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * GIB }
}

///| Constructs a byte size wrapper from a quantity of terabytes.
pub fn ByteSize::tb(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * TB }
}

///| Constructs a byte size wrapper from a quantity of tebibytes.
pub fn ByteSize::tib(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * TIB }
}

///| Constructs a byte size wrapper from a quantity of petabytes.
pub fn ByteSize::pb(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * PB }
}

///| Constructs a byte size wrapper from a quantity of pebibytes.
pub fn ByteSize::pib(size : UInt64) -> ByteSize {
  ByteSize::{ size: size * PIB }
}

///| Returns byte count.
pub fn ByteSize::as_u64(self : ByteSize) -> UInt64 {
  self.size
}

///| Returns a formatting display wrapper.
pub fn ByteSize::display(self : ByteSize) -> Display {
  Display::new(self.size)
}

///| Convert ByteSize to string using default IEC format.
pub fn ByteSize::to_string(self : ByteSize) -> String {
  self.display().to_string()
}

///| Debug representation showing both formatted size and raw bytes.
pub fn ByteSize::debug_string(self : ByteSize) -> String {
  "\{self.to_string()} (\{self.size} bytes)"
}

///| Addition: ByteSize + ByteSize = ByteSize
impl Add for ByteSize with op_add(self, rhs : ByteSize) -> ByteSize {
  ByteSize::{ size: rhs.size + self.size }
}

///| Subtraction: ByteSize - ByteSize = ByteSize
impl Sub for ByteSize with op_sub(self, rhs : ByteSize) -> ByteSize {
  ByteSize::{ size: self.size - rhs.size }
}

///| Multiplication: ByteSize * ByteSize = ByteSize
impl Mul for ByteSize with op_mul(self, rhs : ByteSize) -> ByteSize {
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
test "test_default" {
  let default_size = ByteSize::default()
  assert_eq(default_size, ByteSize::b(0))
}
