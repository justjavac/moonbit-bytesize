# `justjavac/bytesize`

`@bytesize` provides a small `ByteSize` wrapper for converting exact byte counts
and formatting them with either IEC or SI units.

## Convert raw units

```mbt check
///|
test "raw unit helpers return exact byte counts" {
  assert_eq(@bytesize.kb(1), 1_000UL)
  assert_eq(@bytesize.mb(1), 1_000_000UL)
  assert_eq(@bytesize.gb(1), 1_000_000_000UL)
  assert_eq(@bytesize.tb(1), 1_000_000_000_000UL)
  assert_eq(@bytesize.pb(1), 1_000_000_000_000_000UL)
  assert_eq(@bytesize.kib(1), 1_024UL)
  assert_eq(@bytesize.mib(1), 1_048_576UL)
  assert_eq(@bytesize.gib(1), 1_073_741_824UL)
  assert_eq(@bytesize.tib(1), 1_099_511_627_776UL)
  assert_eq(@bytesize.pib(1), 1_125_899_906_842_624UL)
}
```
