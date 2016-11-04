class Reduze < Formula
  desc "Distributed Feynman Integral Reduction"
  homepage "https://reduze.hepforge.org/"
  url "https://reduze.hepforge.org/download/reduze-2.1.tar.gz"
  sha256 "757556ba0b05b7b4c14091ce4a54f79259b530ed22180417b41f9ae443378ea7"

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
