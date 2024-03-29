class GraceGrc < Formula
  desc "Feynman graph generator"
  homepage "http://minami-home.kek.jp/"
  url "http://minami-home.kek.jp/ftp/grc/grc.v2.1.tar.Z"
  sha256 "9c90d8e94bec8f553e510b9a71c4ae0e70bceae86f117bbe5d96ca6c896a1dd5"

  depends_on "libx11" => :optional

  patch :DATA

  def install
    system "make", "-C", "src", "mgrc"
    system "make", "-C", "src", "mplot"
    system "make", "-C", "src", "mdraw" if build.with? "libx11"
    bin.install "src/grc"
    bin.install "src/grcplot"
    bin.install "src/grcdraw" if build.with? "libx11"
  end

  test do
    system "#{bin}/grc", "-h"
    system "#{bin}/grcplot", "-h"
    system "#{bin}/grcdraw", "-h" if build.with? "libx11"
  end
end
__END__
diff --git a/src/dagrf.c b/src/dagrf.c
index 8a1cdaa..3bfa4b1 100644
--- a/src/dagrf.c
+++ b/src/dagrf.c
@@ -44,7 +44,7 @@ Extern  Void    rgsetv          ARG((tproc*,tgraph*,int,int,int*));
 
 /* error of system calls */
 Extern int sys_nerr;
-Extern char *sys_errlist[];
+//Extern char *sys_errlist[];
 Extern int errno;
 
 /* Private functions */
