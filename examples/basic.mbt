fn main {
  let size = @bytesize.ByteSize::gib(2)
  println(size.display().iec().to_string())
}
