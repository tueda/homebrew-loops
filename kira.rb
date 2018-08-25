class Kira < Formula
  desc "Feynman Integral Reduction Program"
  homepage "https://www.physik.hu-berlin.de/de/pep/tools"
  url "https://www.physik.hu-berlin.de/de/pep/tools/kira/kira-1.1.tar.gz"
  sha256 "467bed896478a2145c848a58442dac117a3912924e7bb79f3e021a05b2a9691d"

  depends_on "pkg-config" => :build
  depends_on "ginac"
  depends_on "yaml-cpp"
  depends_on "sqlite"
  depends_on "zlib" unless OS.mac?

  head do
    url "https://gitlab.com/kira-pyred/kira.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    needs :cxx14 
  end

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

  def caveats; <<~EOS
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
