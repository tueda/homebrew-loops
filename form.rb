require 'formula'

class Form < Formula
  homepage "http://www.nikhef.nl/~form/"
  url "https://github.com/vermaseren/form/releases/download/v4.1-20131025/form-4.1.tar.gz"
  sha1 "527005d082a823e260d77043be3c2539dcc6a72f"
  head do
    url "https://github.com/vermaseren/form.git",
        :revision => "36ecf57b0192e50296c7149d39a69f59cf64efa1"
    version "4.1-20150412"
    DATE_VERSION = "Apr 12 2015"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "gmp" => :recommended
  option "with-mpi", "Build also the mpi versions"
  depends_on :mpi => [:cc, :cxx, :optional]
  option "with-debug", "Build also the debug versions"

  def install
    system "autoreconf", "-i" if build.head?
    args = [
      "--prefix=#{prefix}"
    ]
    args << "--enable-debug" if build.with? "debug"
    args << "--enable-parform" if build.with? :mpi
    args << "--without-gmp" if build.without? "gmp"
    system "./configure", *args
    args = []
    args << "DATE=#{DATE_VERSION}" if build.head?
    system "make", *args
    system "make", "install"
  end
end