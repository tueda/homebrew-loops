class GosamContrib < Formula
  desc "The gosam-contrib suite"
  homepage "http://gosam.hepforge.org/"
  url "https://www.hepforge.org/archive/gosam/gosam-contrib-2.0.tar.gz"
  version "2.0-20160413"
  sha256 "c05beceea74324eb51c1049773095e2cb0c09c8c909093ee913d8b0da659048d"

  head do
    url "http://gosam.hepforge.org/svn/gosam-contrib-2.0", :using => :svn
  end

  depends_on "gcc" # for gfortran

  def install
    args = [
      "--prefix=#{prefix}",
      "F77=#{ENV.fc}",
      "FC=#{ENV.fc}",
      "CC=#{ENV.cc}",
      "CXX=#{ENV.cxx}",
    ]
    system "./configure", *args
    system "make", "-C", "avh_olo-3.6.1"
    ENV.deparallelize { system "make", "-C", "ninja-1.1.0" }
    system "make"
    system "make", "install"
  end

  test do
  end
end
