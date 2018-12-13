class Kira < Formula
  desc "Feynman Integral Reduction Program"
  homepage "https://www.physik.hu-berlin.de/de/pep/tools/kira/kira-a-feynman-integral-reduction-program"
  url "https://www.physik.hu-berlin.de/de/pep/tools/kira/kira-1.2.tar.gz"
  sha256 "ecd28b3dab652c7ecd94cfb86a2f1a6aaa8486067b9d3ef0534ee7ec93399d9a"

  head do
    url "https://gitlab.com/kira-pyred/kira.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "ginac"
  depends_on "sqlite"
  depends_on "yaml-cpp"
  depends_on "zlib" unless OS.mac?
  needs :cxx14

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
    ]

    system "autoreconf", "-i" if build.head?

    system "./configure", *args
    system "make"
    system "make", "install"

    pkgshare.install "examples"
  end

  def caveats
    <<~EOS
      Documentation is installed to:
        #{HOMEBREW_PREFIX}/share/doc/#{name}

      Examples are installed to:
        #{HOMEBREW_PREFIX}/share/#{name}/examples
    EOS
  end

  test do
    system "#{bin}/kira", "-h"
  end
end
