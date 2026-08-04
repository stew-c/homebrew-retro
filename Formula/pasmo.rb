class Pasmo < Formula
  desc "Portable Z80 cross assembler with ZX Spectrum, Amstrad CPC and MSX output"
  homepage "https://pasmo.speccy.org/"
  url "https://pasmo.speccy.org/bin/pasmo-0.5.5.tar.gz"
  sha256 "c83ff23e06b26ab5de05efaf13d9ebaf485d43f9a3a1ed50bba17be5a87918ac"
  license "GPL-3.0-only"

  def install
    system "./configure", *std_configure_args
    system "make"
    system "make", "check"
    system "make", "install"

    doc.install "pasmodoc.html", "README", "NEWS", "AUTHORS", "ChangeLog"
    (pkgshare/"examples").install Dir["hello*.asm", "jumptable.asm", "macro.asm", "undoc.asm"]
  end

  test do
    (testpath/"hello.asm").write <<~ASM
          org 32768
      start:
          ld a, 2
          call 5633
          ld a, 42
          rst 16
          ret
          end start
    ASM

    system bin/"pasmo", "--tapbas", "hello.asm", "hello.tap"
    tap = (testpath/"hello.tap").binread

    # A TAP file is a sequence of length-prefixed blocks. The first block is a
    # 19-byte header whose type byte (0) marks it as a BASIC program: the loader
    # --tapbas generates.
    assert_equal 19, tap[0, 2].unpack1("v")
    assert_equal 0, tap[2].ord

    # Raw binary output should be exactly the six assembled instructions.
    system bin/"pasmo", "--bin", "hello.asm", "hello.bin"
    assert_equal "3e02cd01163e2ad7c9", (testpath/"hello.bin").binread.unpack1("H*")
  end
end
