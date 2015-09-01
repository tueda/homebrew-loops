class Form < Formula
  desc "Symbolic manipulation system for very big expressions"
  homepage "http://www.nikhef.nl/~form/"
  url "https://github.com/vermaseren/form/releases/download/v4.1-20131025/form-4.1.tar.gz"
  sha256 "fb3470937d66ed5cb1af896b15058836d2c805d767adac1b9073ed2df731cbe9"

  devel do
    url "https://github.com/vermaseren/form.git",
        :revision => "5fbce8e7e9b71821629095f293094cb67e63dcac"
    version "4.1-20150901"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  head do
    url "https://github.com/vermaseren/form.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "zlib" => :recommended unless OS.mac?
  depends_on "gmp" => :recommended
  option "with-mpi", "Build also the mpi versions"
  depends_on :mpi => [:cc, :cxx, :optional]
  option "with-debug", "Build also the debug versions"

  def normalize_flags(flags)
    a = flags.split(" ")
    a.delete_if do |item|
      item == '-Os' or item == '-w'
    end
    return a.join(" ")
  end

  def install
    ENV["CFLAGS"] = normalize_flags(ENV["CFLAGS"])
    ENV["CXXFLAGS"] = normalize_flags(ENV["CXXFLAGS"])
    system "autoreconf", "-i" if build.devel? or build.head?
    system "sh", "scripts/gendate.sh", "-c", "-o", "sources/production-date.h" if build.devel? or build.head?
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking"
    ]
    args << "--enable-debug" if build.with? "debug"
    args << "--enable-parform" if build.with? :mpi
    args << "--without-gmp" if build.without? "gmp"
    system "./configure", *args
    system "make"
    system "make", "install"
  end
end
