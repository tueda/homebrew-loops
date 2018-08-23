class Kira < Formula
  desc "Feynman Integral Reduction Program: version 1.2"
  homepage "https://gitlab.com/kira-pyred/kira"
  head "https://gitlab.com/kira-pyred/kira.git"

  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "ginac"
  depends_on "yaml-cpp"

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
    ]
    
    system "autoreconf -i"
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
