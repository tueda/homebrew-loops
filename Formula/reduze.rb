class Reduze < Formula
  desc "Distributed Feynman Integral Reduction"
  homepage "https://reduze.hepforge.org/"
  url "https://reduze.hepforge.org/download/reduze-2.6.tar.gz"
  sha256 "472f17b1c411620e9dc5c30acf76a5c202eb90d15b2c25568c8a2f2c80e48050"

  option "with-yaml-cpp", "Build with brewed yaml-cpp"
  option "without-test", "Skip build-time tests"

  depends_on "cmake" => :build
  depends_on "ginac"
  depends_on "berkeley-db" => :optional
  depends_on "open-mpi" => :optional
  depends_on "yaml-cpp" => :optional

  def install
    ENV.append "CMAKE_POLICY_VERSION_MINIMUM", "3.5" # for cmake>=4.0

    ENV.append "LDFLAGS", "-Wl,-rpath,#{Formula["berkeley-db"].opt_lib}" if build.with? "berkeley-db"

    # Fix build failure with GCC 13.
    inreplace "tools/reduze1to2/main.cpp", "#include <iostream>", "#include <cstdint>\n#include <iostream>"

    args = std_cmake_args
    args << "-DUSE_DATABASE=ON" if build.with? "berkeley-db"
    args << "-DUSE_MPI=ON" if build.with? "open-mpi"
    system "cmake", *args
    system "make"
    system "make", "check" if build.with? "test"
    system "make", "check_mpi" if build.with?("test") && build.with?("open-mpi")
    system "make", "install"
  end

  test do
    system "#{bin}/reduze"
  end
end
