class CubaAT3 < Formula
  desc "Library for multidimensional numerical integration"
  homepage "http://www.feynarts.de/cuba"
  url "http://www.feynarts.de/cuba/Cuba-3.3.tar.gz"
  sha256 "967d1c8fb64062ddbe21480075e25ad26e89bfc04dbb5c90b030925be588413f"

  keg_only :versioned_formula

  patch :DATA

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
diff --git a/src/common/MSample.c b/src/common/MSample.c
index 4c14634..fb4c179 100644
--- a/src/common/MSample.c
+++ b/src/common/MSample.c
@@ -7,6 +7,10 @@
 */
 
 
+#if MLINTERFACE < 4
+#define MLReleaseRealList MLDisownRealList
+#endif
+
 static void DoSample(This *t, cnumber n, real *x, real *f
   VES_ONLY(, real *w, ccount iter))
 {
@@ -33,12 +37,12 @@ static void DoSample(This *t, cnumber n, real *x, real *f
   t->neval += mma_n;
 
   if( mma_n != n*t->ncomp ) {
-    MLDisownRealList(stdlink, mma_f, mma_n);
+    MLReleaseRealList(stdlink, mma_f, mma_n);
     longjmp(t->abort, -3);
   }
  
   Copy(f, mma_f, n*t->ncomp);
-  MLDisownRealList(stdlink, mma_f, mma_n);
+  MLReleaseRealList(stdlink, mma_f, mma_n);
 }
 
 /*********************************************************************/
@@ -73,7 +77,7 @@ static count SampleExtra(This *t, cBounds *b)
     Copy(t->fextra, mma_f + nget*t->ndim, n*t->ncomp);
   }
 
-  MLDisownRealList(stdlink, mma_f, mma_n);
+  MLReleaseRealList(stdlink, mma_f, mma_n);
 
   return n;
 }
