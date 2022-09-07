class GinacAT167 < Formula
  desc "Not a Computer algebra system"
  homepage "https://www.ginac.de/"
  url "git://www.ginac.de/ginac.git",
      :tag      => "release_1-6-7",
      :revision => "065600d31de1301c0ea2df2c08ab59e7767cfc7f"

  keg_only :versioned_formula

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "texinfo" => :build unless OS.mac?
  depends_on "cln"
  depends_on "readline"
  depends_on "python@2" unless OS.mac?

  def install
    system "autoreconf", "-i"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <ginac/ginac.h>
      using namespace std;
      using namespace GiNaC;

      int main() {
        symbol x("x"), y("y");
        ex poly;

        for (int i=0; i<3; ++i) {
          poly += factorial(i+16)*pow(x,i)*pow(y,2-i);
        }

        cout << poly << endl;
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-L#{lib}",
                                "-L#{Formula["cln"].lib}",
                                "-lcln", "-lginac", "-o", "test",
                                "-I#{include}"
    system "./test"
  end
end
