class GosamContrib < Formula
  desc "The gosam-contrib suite"
  homepage "http://gosam.hepforge.org/"
  url "https://www.mpp.mpg.de/~jfsoden/gosam_install/gosam-contrib-2.0.tar.gz"
  version "2.0-20150723-1"
  sha256 "817fb1092c9151102a7be5ceb9d332155f713d37c557def7604b5d4e833618b1"

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
    system "make", "clean"
    system "make", "-C", "avh_olo-3.6"
    system "make", "-C", "ff-2.0"
    system "make", "-C", "qcdloop-1.95"
    system "make", "-C", "ninja-1.0.0"
    system "make", "-C", "golem95-1.3.0"
    system "make", "-C", "samurai-2.9.1"
    system "make"
    system "make", "install"
  end

  test do
  end
end
