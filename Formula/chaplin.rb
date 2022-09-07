class Chaplin < Formula
  desc "Complex Harmonic Polylogarithms in FORTRAN"
  homepage "https://chaplin.hepforge.org/"
  url "https://chaplin.hepforge.org/code/chaplin-1.2.tar"
  sha256 "f17c2d985fd4e4ce36cede945450416d3fa940af68945c91fa5d3ca1d76d4b49"

  depends_on "gcc" # for gfortran

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
    ]
    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
  end
end
