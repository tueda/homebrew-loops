class Kira < Formula
  desc "Feynman Integral Reduction Program"
  homepage "https://www.physik.hu-berlin.de/de/pep/tools"
  url "https://www.physik.hu-berlin.de/de/pep/tools/kira-1.0.tar.gz"
  sha256 "5176724197c5946b94b40bc20cfa3118cc8e056ad40f8dfe10d69a476e7b24fd"

  depends_on "pkg-config" => :build
  depends_on "ginac"
  depends_on "yaml-cpp"
  depends_on "sqlite"
  depends_on "zlib" unless OS.mac?

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
    ]
    system "./configure", *args
    system "make"
    system "make", "install"

    doc.install "doc/paper.pdf"
    pkgshare.install "examples"
  end

  def caveats; <<-EOS.undent
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
