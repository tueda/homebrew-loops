class Form < Formula
  desc "Symbolic manipulation system for very big expressions"
  homepage "http://www.nikhef.nl/~form/"
  url "https://github.com/vermaseren/form/releases/download/v4.1-20131025/form-4.1.tar.gz"
  sha256 "fb3470937d66ed5cb1af896b15058836d2c805d767adac1b9073ed2df731cbe9"

  head do
    url "https://github.com/vermaseren/form.git",
        :revision => "f1e220402e8c09ea7a0e2aeffbe638a467fbb10b"
    version "4.1-20150424"
    DATE_VERSION = "Apr 24 2015"
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
      "--prefix=#{prefix}",
      "--disable-dependency-tracking"
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
