# justjavac/bytesize

`ByteSize` is a semantic wrapper for byte count representations.

> This file is port from
> [bytesize-rs/bytesize](https://github.com/bytesize-rs/bytesize/tree/7467a23df30bc1fee48326e0fa6c063fc85676a2)

## Installation

Add `justjavac/bytesize` to your dependencies:

```shell
moon update
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

Arithmetic operations are supported.

```moonbit
let x = @bytesize.ByteSize::kb(100)
let y = @bytesize.ByteSize::mb(1)
let plus = x + y
println(plus)

let minus = y - x
println(minus)
```
