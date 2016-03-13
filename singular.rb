class Singular < Formula
  desc "Computer algebra system for polynomial computations"
  homepage "https://www.singular.uni-kl.de/"
  url "http://www.mathematik.uni-kl.de/ftp/pub/Math/Singular/SOURCES/4-0-3/singular-4.0.3.tar.gz"
  sha256 "e2bd893150b40485acdf139a7beed6eeb137ace232d7d57ef45e1c7046308751"

  head do
    url "https://github.com/Singular/Sources.git"
  end

  option "without-gfanlib", "Build without gfanlib extension for convex polyhedral computations"

  depends_on "readline"
  depends_on "gmp"
  depends_on "cddlib" => :recommended
  depends_on "ntl" => :recommended
  depends_on "flint" => :recommended
  depends_on "graphviz" => :recommended
  depends_on :python => :recommended

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
    ]
    if build.with? :python
      args << "--with-python"
    else
      args << "--without-python"
    end
    args << "--with-gmp=#{Formula["gmp"].opt_prefix}"
    if build.with? "ntl"
      args << "--with-ntl=#{Formula["ntl"].opt_prefix}"
    else
      args << "--without-ntl"
    end
    if build.with? "flint"
      args << "--with-flint=#{Formula["flint"].opt_prefix}"
    else
      args << "--without-flint"
    end
    args << "--enable-gfanlib" if build.with? "gfanlib"
    system "./configure", *args
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    system "Singular", "--help"
  end
end
