class Kira < Formula
  desc "Feynman integral reduction program"
  homepage "https://kira.hepforge.org/"

  stable do
    url "https://kira.hepforge.org/downloads?f=kira-2.0.tar.gz"
    sha256 "66db95989d113ae27d319cf84bfda7fd46edaa71d78153b2289c6b1f8139ee2b"
  end

  head do
    url "https://gitlab.com/kira-pyred/kira.git"
  end

  option "with-mpich", "Enable MPI with MPICH"
  option "with-open-mpi", "Enable MPI with Open MPI"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "flint"
  depends_on "ginac"
  depends_on "gmp"
  depends_on "jemalloc" => :optional
  depends_on "mpfr"
  depends_on "mpich" => :optional
  depends_on "open-mpi" => :optional
  depends_on "yaml-cpp"
  depends_on "zlib" unless OS.mac?

  def install
    args = []

    args << "-Dmpi=true" if build.with?("open-mpi") || build.with?("mpich")
    args << "-Djemalloc=true" if build.with?("jemalloc")

    mkdir "build" do
      system "meson", *std_meson_args, *args, ".."
      system "ninja"
      system "ninja", "install"
    end

    pkgshare.install "examples"
  end

  def caveats
    <<~EOS
      Documentation is installed to:
        #{HOMEBREW_PREFIX}/share/doc/#{name}

      Examples are installed to:
        #{HOMEBREW_PREFIX}/share/#{name}/examples
    EOS
  end

  test do
    system "#{bin}/kira", "-h"
  end
end
