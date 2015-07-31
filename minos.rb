class Minos < Formula
  desc "The Minos database facility "
  homepage "http://www.nikhef.nl/~form/maindir/others/minos/minos.html"
  url "http://www.nikhef.nl/~form/maindir/others/minos/minosdir.tar.gz"
  sha256 "06e1a3d08f640aae5aec9e9196b57eea6a5e84ea1f386e3e8cfb528fb294dd90"
  version "20070207"

  patch :DATA

  def install
    system "make"
    bin.install "minos"
    doc.install "minos.pdf"
    doc.install "minos.ps"
  end

  def caveats; <<-EOS.undent
    Documents have been copied to:
      #{doc}
    EOS
  end
end
__END__
diff --git a/makefile b/makefile
index 7acb776..d4f1ffb 100644
--- a/makefile
+++ b/makefile
@@ -1,5 +1,7 @@
+CC = gcc
+
 .c.o:
-	cc -fomit-frame-pointer -DUNIX -D_FILE_OFFSET_BITS=64 -O -Wall -c $<
+	$(CC) $(CPPFLAGS) $(CFLAGS) -DUNIX -D_FILE_OFFSET_BITS=64 -O -c $<
 #	cc -g -O -Wall -c $<
 
 OBJS	      = lowlevel.o \
@@ -7,6 +9,6 @@ OBJS	      = lowlevel.o \
 		user.o
 
 minos:     $(OBJS) makefile
-		cc -object -s -static $(OBJS) -o minos
+		$(CC) $(CFLAGS) $(LDFLAGS) -o minos $(OBJS)
 #		cc -g $(OBJS) -o minos
 
