require "formula"

class Cuba3 < Formula
  homepage "http://www.feynarts.de/cuba"
  url "http://www.feynarts.de/cuba/Cuba-3.3.tar.gz"
  sha1 "7cfab584f2d3617c66b9913b0f0a464e0769d68c"

  patch :DATA

  keg_only "Cuba 3.3 is provided for software that doesn't compile against newer versions."

  def install
    ENV.deparallelize

    system "./configure", "--prefix=#{prefix}", "--datadir=#{share/name}/doc"
    system "make"
    system "make", "check"
    system "make", "install"

    (share/name).install "demo"
  end

  test do
    system ENV.cc,
           "-I#{include}",
           "-o", "demo-c",
           "#{share/name}/demo/demo-c.c",
           "#{lib}/libcuba.a",
           "-lm"
    system "./demo-c"
  end
end
__END__
diff --git a/configure b/configure
index 54f66a5..58174a7 100755
--- a/configure
+++ b/configure
@@ -3437,6 +3437,8 @@ test -z "$INSTALL_SCRIPT" && INSTALL_SCRIPT='${INSTALL}'
 
 test -z "$INSTALL_DATA" && INSTALL_DATA='${INSTALL} -m 644'
 
+USER_CFLAGS_=$USER_CFLAGS
+USER_CFLAGS=
 
 if test "$GCC" = yes; then :
   case `$CC --version 2>&1 < /dev/null` in #(
@@ -3444,6 +3446,9 @@ if test "$GCC" = yes; then :
     opt=-O3 ;; #(
   *gcc*4.2* | *gcc*4.4.3*) :
     opt=-O0 ;; #(
+  *gcc*4.1*) :
+    # Ensure ULLONG_MAX
+    opt='-O3 -std=gnu99' ;;
   *) :
     opt=-O3 ;;
 esac
@@ -3452,6 +3457,9 @@ else
   CFLAGS=${USER_CFLAGS:--O}
 fi
 
+# Apply both the user flags and the optimization flags obtained above.
+# In Linuxbrew, a typical input CFLAGS is like "-Os -w -pipe -march=core2".
+CFLAGS="$USER_CFLAGS_ $CFLAGS"
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for an ANSI C-conforming const" >&5
 $as_echo_n "checking for an ANSI C-conforming const... " >&6; }
