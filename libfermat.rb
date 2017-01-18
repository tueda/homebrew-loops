class Libfermat < Formula
  desc "Link to the fermat computer algebra system"
  homepage "https://github.com/mprausa/libFermat"
  head "https://github.com/mprausa/libFermat.git"

  depends_on "boost"
  depends_on "cmake" => :build
  depends_on "pstreams" => :build

  def install
    args = std_cmake_args
    system "cmake", *args
    system "make"
    system "make", "install"
  end

  test do
  end
end
