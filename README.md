# justjavac/bytesize

[![coverage](https://img.shields.io/codecov/c/github/justjavac/moonbit-bytesize/main?label=coverage)](https://codecov.io/gh/justjavac/moonbit-bytesize)

`ByteSize` is a semantic wrapper for byte count representations.

> This file is port from
> [bytesize-rs/bytesize](https://github.com/bytesize-rs/bytesize/tree/7467a23df30bc1fee48326e0fa6c063fc85676a2)

## Installation

Add `justjavac/bytesize` to your dependencies:

```shell
moon add justjavac/bytesize
```

## Examples

Construction using `SI` or `IEC` helpers.

```moonbit
assert_true(@bytesize.ByteSize::kib(4) > @bytesize.ByteSize::kb(4))
```

Display as human-readable string.

```moonbit
assert_eq("518 GiB", @bytesize.ByteSize::gib(518).display().iec().to_string())
assert_eq("556.2 GB", @bytesize.ByteSize::gib(518).display().si().to_string())
assert_eq("518G", @bytesize.ByteSize::gib(518).display().iec_short().to_string())
```

Precision can be tuned for display output.

```moonbit
assert_eq("954 MiB", @bytesize.ByteSize::gb(1).display().to_string(precision=0))
assert_eq("953.67432 MiB", @bytesize.ByteSize::gb(1).display().to_string(precision=5))
```
