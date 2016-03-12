class Form < Formula
  desc "Symbolic manipulation system for very big expressions"
  homepage "http://www.nikhef.nl/~form/"
  url "https://github.com/vermaseren/form/releases/download/v4.1-20131025/form-4.1.tar.gz"
  sha256 "fb3470937d66ed5cb1af896b15058836d2c805d767adac1b9073ed2df731cbe9"

  devel do
    url "https://github.com/vermaseren/form.git",
        :revision => "0beb5ac79b3820a8da3163cbb3f84cb526195011"
    version "4.1-20150903"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  head do
    url "https://github.com/vermaseren/form.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  option "with-mpi", "Build also the mpi versions"
  option "with-debug", "Build also the debug versions"
  option "without-test", "Skip build-time tests"

  depends_on "zlib" => :recommended unless OS.mac?
  depends_on "gmp" => :recommended
  depends_on :mpi => [:cc, :cxx, :optional]

  def normalize_flags(flags)
    # Don't use optimization flags given by Homebrew.
    a = flags.split(" ")
    a.delete_if do |item|
      item == "-Os" || item == "-w"
    end
    a.join(" ")
  end

  def install
    ENV["CFLAGS"] = normalize_flags(ENV["CFLAGS"])
    ENV["CXXFLAGS"] = normalize_flags(ENV["CXXFLAGS"])
    system "autoreconf", "-i" if build.devel? || build.head?
    system "sh", "scripts/gendate.sh", "-c", "-o", "sources/production-date.h" if build.devel? || build.head?
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--disable-silent-rules",
    ]
    args << "--enable-debug" if build.with? "debug"
    args << "--enable-parform" if build.with? :mpi
    args << "--without-gmp" if build.without? "gmp"
    system "./configure", *args
    system "make"
    # NOTE: test suite in the tarball depends on Linux strace.
    system "make", "check" if build.with?("test") && (build.devel? || build.head? || OS.linux?)
    system "make", "install"
  end

  test do
    (testpath/"test.frm").write <<-EOS.undent
      Off stats;
      Off finalstats;
      Off totalsize;
      On highfirst;
      Symbols a, b;
      Local F = (a + b)^2;
      Print;
      .end
    EOS
    result = <<-EOS

   F =
      a^2 + 2*a*b + b^2;

    EOS
    assert_equal result, pipe_output("#{bin}/form -q test.frm")
  end
end
