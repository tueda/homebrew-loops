require 'formula'

class Fire < Formula
  homepage "http://science.sander.su/FIRE.htm"
  url "https://bitbucket.org/feynmanIntegrals/fire/get/5.1.tar.gz"
  sha1 "2f59801b1949e22f209fba433423128da456f210"

  patch :DATA

  depends_on "kyoto-cabinet"
  depends_on "snappy"

  def install
    ferlpath = which "fer64"
    ferlpath = which "ferl" if not ferlpath
    if ferlpath
      ohai "Default fermat path: #{ferlpath}."
      inreplace "FIRE5/sources/parser.cpp" do |s|
        s.gsub! 'common::FIRE_folder+"../extra/ferm64/fer64"', "\"#{ferlpath}\""
        s.gsub! 'common::FIRE_folder+"../extra/ferl64/fer64"', "\"#{ferlpath}\""
      end
    else
      opoo "fermat not found. You need to specify it by #fermat in .config file."
    end
    system "make", "-C", "FIRE5/sources"
    bin.install "FIRE5/sources/FIRE5"
    Dir.mkdir("tmp")
    Dir.mkdir("tmp/FIRE5")
    Dir.mkdir("tmp/FIRE5/examples")
    cp "FIRE5/FIRE5.m", "tmp/FIRE5"
    cp Dir["FIRE5/examples/*"], "tmp/FIRE5/examples"
    share.install "tmp/FIRE5"
  end

  test do
    cp "#{share}/FIRE5/examples/box.start", testpath
    (testpath/"box.config").write <<-EOS.undent
      #threads           4
      #fthreads          4
      #variables         d
      #start
      #folder
      #problem           1 box.start
      #integrals         box.in
      #output            box.out
    EOS
    (testpath/"box.in").write <<-EOS.undent
      {{1,{2,2,2,2}}}
    EOS
    system "#{bin}/FIRE5", "-c", "box"
    system "cat", "box.out"
  end

  def caveats; <<-EOS.undent
    FIRE5.m has been copied to:
      #{HOMEBREW_PREFIX}/share/FIRE5/FIRE5.m

    Make a link to FIRE5.m in a directory which is visible to Mathematica, e.g.,
      $UserBaseDirectory/Applications
    EOS
  end
end
__END__
diff --git a/FIRE5/FLink/Makefile b/FIRE5/FLink/Makefile
index 5472a62..aca31b3 100644
--- a/FIRE5/FLink/Makefile
+++ b/FIRE5/FLink/Makefile
@@ -20,6 +20,7 @@ LIBDIR = ${CADDSDIR}
 MPREP = ${CADDSDIR}/mprep
 
 ifeq ($(shell echo "$(VERSION)>=10" | bc), 1)
+EXTRALIBS= -luuid -ldl
 MLIBVERSION=4
 else
 MLIBVERSION=3
@@ -37,7 +38,7 @@ MLIB = ${CADDSDIR}/libML${BIT}i${MLIBVERSION}.a
 ifeq ($(UNAME_S),Darwin)
 LIBS=-L${CADDSDIR} -lMLi${MLIBVERSION} -lstdc++ -framework Foundation -lz -lm -mmacosx-version-min=10.5
 else
-LIBS=${MLIB} -pthread -lstdc++ -lrt -lz -lm 
+LIBS=${MLIB} ${EXTRALIBS} -pthread -lstdc++ -lrt -lz -lm 
 endif
 
 CC=gcc
diff --git a/FIRE5/KLink/Makefile b/FIRE5/KLink/Makefile
index 16c50c1..31d82f7 100644
--- a/FIRE5/KLink/Makefile
+++ b/FIRE5/KLink/Makefile
@@ -21,6 +21,7 @@ endif
 
 ifeq ($(shell echo "$(VERSION)>=10" | bc), 1)
 MLIBVERSION=4
+EXTRALIBS= -luuid -ldl
 else
 MLIBVERSION=3
 endif
@@ -33,7 +34,7 @@ MPREP = ${CADDSDIR}/mprep
 ifeq ($(UNAME_S),Darwin)
 LIBS=-L${CADDSDIR} -lkyotocabinet -lMLi${MLIBVERSION} -lstdc++ -framework Foundation -lz -lm -mmacosx-version-min=10.5
 else
-LIBS=${MLIB} -Wl,-Bstatic -lkyotocabinet -Wl,-Bdynamic -pthread -lstdc++ -lrt -lz -lm
+LIBS=${MLIB} ${EXTRALIBS} -Wl,-Bstatic -lkyotocabinet -Wl,-Bdynamic -pthread -lstdc++ -lrt -lz -lm
 endif
 
 
diff --git a/FIRE5/sources/Makefile b/FIRE5/sources/Makefile
index e98aa4c..e7654ed 100644
--- a/FIRE5/sources/Makefile
+++ b/FIRE5/sources/Makefile
@@ -1,13 +1,12 @@
 
-CC= g++
-cc= gcc
-CFLAGS = -O3 -I../usr/include
+CXX = g++
+CXXFLAGS = -O3 -pthread
 
 UNAME_S := $(shell uname -s)
 ifeq ($(UNAME_S),Darwin)
-LFLAGS = -L../usr/lib/ -L../usr/lib64/ -lkyotocabinet -lsnappy -lstdc++ -lpthread -lm -lc
+LIBS = -lkyotocabinet -lsnappy -lstdc++ -lpthread -lm -lc
 else
-LFLAGS = -L../usr/lib/ -L../usr/lib64/ -Wl,-Bstatic  -lkyotocabinet -lsnappy -Wl,-Bdynamic -lstdc++ -lrt -lpthread -lm -lc 
+LIBS = -lkyotocabinet -lsnappy
 endif
 
 
@@ -17,11 +16,11 @@ endif
 OBJ = main.o point.o equation.o functions.o gateToFermat.o common.o parser.o
 
 
-default: $(OBJ)
-	${CC} $(OBJ)  ${LFLAGS}  -o FIRE5
+FIRE5: $(OBJ)
+	$(CXX) $(CPPFLAGS) $(LDFLAGS) -o FIRE5 $(OBJ) $(LIBS)
 
 .cpp.o:
-	${CC} ${CFLAGS} ${INCDIR} -c $<
+	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $<
 
 clean:
 	rm -f ./*.o test
diff --git a/FIRE5/sources/common.cpp b/FIRE5/sources/common.cpp
index 3060d82..e30916f 100644
--- a/FIRE5/sources/common.cpp
+++ b/FIRE5/sources/common.cpp
@@ -299,7 +299,7 @@ void open_database(KCDB** db,int msiz,int number) {
         throw 1;
     }
     
-      common::buckets_full[number]=pow(2,common::buckets[number]);
+      common::buckets_full[number]=pow(2.0,common::buckets[number]);
       if (common::memory_db) common::buckets_full[number]*=2;  //we need less buckets for memory_db
       
         common::points_open[number]=true;
@@ -313,7 +313,7 @@ void open_database(KCDB** db,int msiz,int number) {
 	
 	if (common::memory_db) {
 	    kyotocabinet::CacheDB* ldb=new kyotocabinet::CacheDB();
-	    ldb->tune_buckets((long long int)pow(2,common::buckets[number]));
+	    ldb->tune_buckets((long long int)pow(2.0,common::buckets[number]));
 	    ldb->tune_options(kyotocabinet::HashDB::TLINEAR | kyotocabinet::HashDB::TCOMPRESS);
 	    ldb->tune_compressor(new SnappyCompressor());
 	    if (!ldb->open("*",KCOWRITER | KCOCREATE)) {
@@ -328,11 +328,11 @@ void open_database(KCDB** db,int msiz,int number) {
 	
         if (number!=0) {
             kyotocabinet::HashDB* ldb=new kyotocabinet::HashDB();
-            ldb->tune_buckets((long long int)pow(2,common::buckets[number]));
+            ldb->tune_buckets((long long int)pow(2.0,common::buckets[number]));
             ldb->tune_defrag(1);
             ldb->tune_fbp(10);
             ldb->tune_alignment(8);
-            ldb->tune_map((long long int)pow(2,msiz));
+            ldb->tune_map((long long int)pow(2.0,msiz));
             ldb->tune_options(kyotocabinet::HashDB::TLINEAR | kyotocabinet::HashDB::TCOMPRESS);
             ldb->tune_compressor(new SnappyCompressor());
             if (!ldb->open((common::path+int2string(number)+".kch").c_str(),flags)) {
@@ -347,7 +347,7 @@ void open_database(KCDB** db,int msiz,int number) {
 
             ldb->tune_options(kyotocabinet::HashDB::TLINEAR);
             //ldb->tune_compressor(new SnappyCompressor());
-            ldb->tune_buckets((long long int)pow(2,common::buckets[number]));
+            ldb->tune_buckets((long long int)pow(2.0,common::buckets[number]));
             ldb->tune_defrag(1);
             ldb->tune_fbp(10);
             ldb->tune_alignment(8);
