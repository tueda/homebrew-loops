class Reduze < Formula
  desc "Distributed Feynman Integral Reduction"
  homepage "https://reduze.hepforge.org/"
  url "https://reduze.hepforge.org/download/reduze-2.0.9.tar.gz"
  sha256 "e56494519faffa381f16c8c9b439e9c17485392d47b836ef372d3c4ff451e67a"
  patch :DATA

  option "with-yaml-cpp", "Build with brewed yaml-cpp"
  option "without-test", "Skip build-time tests"

  depends_on "cmake" => :build
  depends_on "ginac"
  depends_on "berkeley-db5" => :optional
  depends_on "yaml-cpp" => :optional
  depends_on :mpi => [:cxx, :optional]

  def install
    ENV.append "LDFLAGS", "-Wl,-rpath,#{Formula["berkeley-db5"].opt_lib}" if build.with? "berkeley-db5"

    args = std_cmake_args
    args << "-DUSE_DATABASE=ON" if build.with? "berkeley-db5"
    args << "-DUSE_MPI=ON" if build.with? :mpi
    system "cmake", *args
    system "make"
    system "make", "check" if build.with? "test"
    system "make", "check_mpi" if build.with?("test") && build.with?(:mpi)
    system "make", "install"
  end

  test do
    system "reduze"
  end
end
__END__
diff --git a/reduze/jobcenter.cpp b/reduze/jobcenter.cpp
index 6927285..e63a5fd 100644
--- a/reduze/jobcenter.cpp
+++ b/reduze/jobcenter.cpp
@@ -14,6 +14,7 @@
 #include "functions.h"
 #include <cmath>
 #include <iomanip>
+#include <unistd.h>  // usleep
 
 #include "job_setupsectormappings.h"
 #include "job_setupsectormappingsalt.h"
diff --git a/reduze/reduzermpi.cpp b/reduze/reduzermpi.cpp
index ddfa04b..6463390 100644
--- a/reduze/reduzermpi.cpp
+++ b/reduze/reduzermpi.cpp
@@ -13,6 +13,7 @@
 #include <mpi.h>
 #include <queue>
 #include <climits>
+#include <unistd.h>  // usleep
 
 //#include "communicator.h"
 #include "jobcenter.h"
