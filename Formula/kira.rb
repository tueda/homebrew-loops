class Kira < Formula
  desc "Feynman integral reduction program"
  homepage "https://kira.hepforge.org/"
  url "https://gitlab.com/kira-pyred/kira/-/archive/3.1/kira-3.1.tar.gz"
  sha256 "bb084fa666d4335a72739520ad8d766b87e86f1c8f6763d673f69bc4ea39d717"
  license "GPL-3.0-or-later"
  head "https://gitlab.com/kira-pyred/kira.git", branch: "master"
  option "with-mpich", "Enable MPI with MPICH"
  option "with-open-mpi", "Enable MPI with Open MPI"
  option "without-jemalloc", "Build without jemalloc"

  depends_on "cmake" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "flint"
  depends_on "ginac"
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "yaml-cpp"
  depends_on "jemalloc" => :recommended
  depends_on "mpich" => :optional
  depends_on "open-mpi" => :optional

  uses_from_macos "zlib"

  # gcc5.5 fails to compile FireFly.
  on_linux do
    depends_on "gcc"
  end
  fails_with gcc: "5"
  fails_with gcc: "6"
  fails_with gcc: "7"
  fails_with gcc: "8"
  fails_with gcc: "9"

  def install
    args = %w[
      --force-fallback-for=firefly
    ]

    args << "-Dmpi=true" if build.with?("open-mpi") || build.with?("mpich")
    args << "-Djemalloc=true" if build.with?("jemalloc")

    system "meson", "setup", "build", *std_meson_args, *args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"

    pkgshare.install "examples"
  end

  def caveats
    <<~EOS
      Examples are installed to:
        #{HOMEBREW_PREFIX}/share/#{name}/examples
    EOS
  end

  test do
    system bin/"kira", "-h"
  end
end
