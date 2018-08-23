class Kira < Formula
  desc "Feynman Integral Reduction Program: version 1.2"
  homepage "https://gitlab.com/kira-pyred/kira"
  url "https://gitlab.com/kira-pyred/kira/-/archive/master/kira-master.zip"
  sha256 "76c12fe86563a382a189a66e1bf8c70d3a9387b62611662f100c74d0b83b7efb"
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
