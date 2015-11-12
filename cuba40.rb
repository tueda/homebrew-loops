class Cuba40 < Formula
  desc "A library for multidimensional numerical integration"
  homepage "http://www.feynarts.de/cuba"
  url "http://www.feynarts.de/cuba/Cuba-4.0.tar.gz"
  sha256 "f2576448ddc296e3ff841a085e737c2451512482f561ae9e2e9616903b685c75"

  patch :DATA

  keg_only "Cuba 4.0 is provided for software that doesn't compile against newer versions."

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
index 3b28f5f..080976e 100755
--- a/configure
+++ b/configure
@@ -3438,6 +3438,8 @@ test -z "$INSTALL_SCRIPT" && INSTALL_SCRIPT='${INSTALL}'
 
 test -z "$INSTALL_DATA" && INSTALL_DATA='${INSTALL} -m 644'
 
+USER_CFLAGS_=$USER_CFLAGS
+USER_CFLAGS=
 
 if test "$GCC" = yes; then :
   case `$CC --version 2>&1 < /dev/null` in #(
@@ -3445,6 +3447,9 @@ if test "$GCC" = yes; then :
     opt=-O3 ;; #(
   *gcc*4.2* | *gcc*4.4.3*) :
     opt=-O0 ;; #(
+  *gcc*4.1*) :
+    # Ensure ULLONG_MAX
+    opt='-O3 -std=gnu99' ;;
   *) :
     opt=-O3 ;;
 esac
@@ -3453,6 +3458,9 @@ else
   CFLAGS=${USER_CFLAGS:--O}
 fi
 
+# Apply both the user flags and the optimization flags obtained above.
+# In Linuxbrew, a typical input CFLAGS is like "-Os -w -pipe -march=core2".
+CFLAGS="$USER_CFLAGS_ $CFLAGS"
 
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking for an ANSI C-conforming const" >&5
 $as_echo_n "checking for an ANSI C-conforming const... " >&6; }
