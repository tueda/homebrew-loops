class Fire < Formula
  desc "Feynman Integral REduction"
  homepage "http://science.sander.su/FIRE.htm"
  url "https://bitbucket.org/feynmanIntegrals/fire/get/5.2.tar.gz"
  sha256 "95f5e76fe9d5df42f7fc40f885bdcefd0484df9f5ddca0074a1f5d0842e3ee2f"

  patch :DATA

  option "with-klink", "Build KLink"
  option "with-flink", "Build FLink"

  depends_on "kyoto-cabinet"
  depends_on "snappy"

  def env_math
    s = ENV["HOMEBREW_MATH"]
    if s.nil? || s.empty?
      if OS.mac?
        s = "/Applications/Mathematica.app/Contents/MacOS/MathKernel"
      else
        s = "math"
      end
      ENV["HOMEBREW_MATH"] = s
    end
    if which s
      ohai "Mathematica path: #{s}"
    else
      onoe "Mathematica (#{s}) not found."
    end
  end

  def install
    if build.with?("klink") || build.with?("flink")
      env_math
    end
    ferlpath = which "fer64"
    ferlpath ||= which "ferl"
    if ferlpath
      ohai "Default fermat path: #{ferlpath}"
      inreplace "FIRE5/sources/parser.cpp" do |s|
        s.gsub! 'common::FIRE_folder+"../extra/ferm64/fer64"', "\"#{ferlpath}\""
        s.gsub! 'common::FIRE_folder+"../extra/ferl64/fer64"', "\"#{ferlpath}\""
      end
    else
      opoo "fermat not found. You need to specify it by #fermat in .config file."
    end

    system "make", "-C", "FIRE5/sources"
    bin.install "FIRE5/sources/FIRE5"

    if build.with? "klink"
      system "make", "-C", "FIRE5/KLink"
      bin.install "FIRE5/KLink/KLink"
    end

    if build.with? "flink"
      system "make", "-C", "FIRE5/FLink"
      bin.install "FIRE5/FLink/FLink"
    end

    (share/"FIRE5").install "FIRE5/examples"
    (share/"Mathematica"/"Applications").install "FIRE5/FIRE5.m"
  end

  def caveats; <<~EOS
    FIRE5.m has been copied to
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/FIRE5.m
    You can add it to your Mathematica $Path by adding a line
      AppendTo[$Path, "#{HOMEBREW_PREFIX}/share/Mathematica/Applications"]]
    to the file obtained by
      FileNameJoin[{$UserBaseDirectory, "Kernel", "init.m"}]
    Or run the following command in Mathematica:
      (Import["https://git.io/AppendPath.m"];AppendPath["#{HOMEBREW_PREFIX}/share/Mathematica/Applications"])

    Examples have been copied to
      #{HOMEBREW_PREFIX}/share/FIRE5/examples/

    To build KLink (--with-klink) or FLink (--with-flink) on Linux with
    Mathematica 10, you need libuuid:
      brew install libuuid
    Mathematica executable for the build can be specified by the environment
    variable $HOMEBREW_MATH.

    KLink (--with-klink) conflicts with KLink in fiesta.
    EOS
  end

  test do
    cp "#{share}/FIRE5/examples/box.start", testpath
    (testpath/"box.config").write <<~EOS
      #threads           4
      #fthreads          4
      #variables         d
      #start
      #folder
      #problem           1 box.start
      #integrals         box.in
      #output            box.out
    EOS
    (testpath/"box.in").write <<~EOS
      {{1,{2,2,2,2}}}
    EOS
    system "#{bin}/FIRE5", "-c", "box"
    system "cat", "box.out"
    system "KLink", "-test" if build.with? "klink"
    system "FLink", "-test" if build.with? "flink"
  end
end
__END__
diff --git a/FIRE5/FLink/Makefile b/FIRE5/FLink/Makefile
index aca31b3..96c9a27 100644
--- a/FIRE5/FLink/Makefile
+++ b/FIRE5/FLink/Makefile
@@ -2,11 +2,8 @@
 # Name of Mathematica executable
 
 UNAME_S := $(shell uname -s)
-ifeq ($(UNAME_S),Darwin)
-MATHEXE=/Applications/Mathematica.app/Contents/MacOS/MathKernel
-else
-MATHEXE=math
-endif
+MATHEXE=$(HOMEBREW_MATH)
+
 #################
 SHELL=/bin/bash
 VERSION := $(shell echo -e $$ VersionNumber | tr -d " " | $(MATHEXE) -noprompt | tr -d ".\"\n" )
@@ -19,8 +16,15 @@ INCDIR = ${CADDSDIR}
 LIBDIR = ${CADDSDIR}
 MPREP = ${CADDSDIR}/mprep
 
+CC = gcc
+CPPFLAGS += -I$(CADDSDIR)
+CFLAGS += -O3 -Wno-unused-result
+LIBS =
+
 ifeq ($(shell echo "$(VERSION)>=10" | bc), 1)
-EXTRALIBS= -luuid -ldl
+ifneq ($(UNAME_S),Darwin)
+LIBS += -luuid -ldl
+endif
 MLIBVERSION=4
 else
 MLIBVERSION=3
@@ -36,19 +40,21 @@ endif
 MLIB = ${CADDSDIR}/libML${BIT}i${MLIBVERSION}.a
 
 ifeq ($(UNAME_S),Darwin)
-LIBS=-L${CADDSDIR} -lMLi${MLIBVERSION} -lstdc++ -framework Foundation -lz -lm -mmacosx-version-min=10.5
+LDFLAGS += -L$(CADDSDIR) -framework Foundation -mmacosx-version-min=10.5
+LIBS += -lMLi$(MLIBVERSION) -lstdc++ -lz -lm
 else
-LIBS=${MLIB} ${EXTRALIBS} -pthread -lstdc++ -lrt -lz -lm 
+CFLAGS += -pthread
+LIBS += $(MLIB) -lstdc++ -lrt
 endif
 
-CC=gcc
+OBJ = FLink.o gateToMath.o  gateToFermat.o
 
-FLink : FLink.o gateToMath.o  gateToFermat.o
-	${CC} FLink.o gateToMath.o gateToFermat.o ${LIBS} -o $@
+FLink : $(OBJ)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o FLink $(OBJ) $(LIBS)
 
 
 .c.o :
-	${CC} -c ${EXTRA_CFLAGS} -I${INCDIR} $<
+	$(CC) $(CPPFLAGS) $(CFLAGS) -c $<
 
 gateToMath.c : gateToMath.tm
 	${MPREP} $? -o $@
diff --git a/FIRE5/KLink/Makefile b/FIRE5/KLink/Makefile
index 31d82f7..fda9eda 100644
--- a/FIRE5/KLink/Makefile
+++ b/FIRE5/KLink/Makefile
@@ -1,9 +1,5 @@
 UNAME_S := $(shell uname -s)
-ifeq ($(UNAME_S),Darwin)
-MATHEXE=/Applications/Mathematica.app/Contents/MacOS/MathKernel
-else
-MATHEXE=math
-endif
+MATHEXE=$(HOMEBREW_MATH)
 
 
 
@@ -12,6 +8,15 @@ VERSION := $(shell echo -e $$ VersionNumber | tr -d " " | $(MATHEXE) -noprompt |
 MBASE := $(shell echo -e $$ InstallationDirectory | tr -d " " | $(MATHEXE) -noprompt | tr -d "\"\n")
 SYSID :=  $(shell echo -e $$ SystemID | tr -d " " | $(MATHEXE) -noprompt | tr -d "\"\n" )
 MLINKDIR = ${MBASE}/SystemFiles/Links/MathLink/DeveloperKit
+CADDSDIR = ${MLINKDIR}/${SYSID}/CompilerAdditions
+MLIB = ${CADDSDIR}/libML${BIT}i${MLIBVERSION}.a
+MPREP = ${CADDSDIR}/mprep
+
+CC = gcc
+CPPFLAGS += -I$(CADDSDIR)
+CFLAGS += -O3 -Wno-unused-result
+LIBS =
+
 ifeq ($(SYSID), Linux)
 	BIT := 32
 endif
@@ -20,33 +25,32 @@ ifeq ($(SYSID), Linux-x86-64)
 endif
 
 ifeq ($(shell echo "$(VERSION)>=10" | bc), 1)
+ifneq ($(UNAME_S),Darwin)
+LIBS += -luuid -ldl
+endif
 MLIBVERSION=4
-EXTRALIBS= -luuid -ldl
 else
 MLIBVERSION=3
 endif
 
 
-CADDSDIR = ${MLINKDIR}/${SYSID}/CompilerAdditions
-MLIB = ${CADDSDIR}/libML${BIT}i${MLIBVERSION}.a
-MPREP = ${CADDSDIR}/mprep
 
 ifeq ($(UNAME_S),Darwin)
-LIBS=-L${CADDSDIR} -lkyotocabinet -lMLi${MLIBVERSION} -lstdc++ -framework Foundation -lz -lm -mmacosx-version-min=10.5
+LDFLAGS += -L${CADDSDIR} -framework Foundation -mmacosx-version-min=10.5
+LIBS += -lkyotocabinet -lMLi${MLIBVERSION} -lstdc++ -lz -lm
 else
-LIBS=${MLIB} ${EXTRALIBS} -Wl,-Bstatic -lkyotocabinet -Wl,-Bdynamic -pthread -lstdc++ -lrt -lz -lm
+CFLAGS += -pthread
+LIBS += $(MLIB) -lkyotocabinet -lrt
 endif
 
 
 OBJ = KLink.o MathSide.o
 
-CC=gcc
-
 KLink: $(OBJ)
-	$(CC) $(OBJ) -L../usr/lib/ -L../usr/lib64/ ${LIBS} -o $@
+	$(CC) $(CFLAGS) $(LDFLAGS) -o KLink $(OBJ) $(LIBS)
 
 .c.o:
-	$(CC) -c -I${CADDSDIR} -I../usr/include/ -O2 -c $<
+	$(CC) $(CPPFLAGS) $(CFLAGS) -c $<
 
 MathSide.c : MathSide.tm
 	${MPREP} -o MathSide.c MathSide.tm
diff --git a/FIRE5/sources/Makefile b/FIRE5/sources/Makefile
index 7684bd7..799b53f 100644
--- a/FIRE5/sources/Makefile
+++ b/FIRE5/sources/Makefile
@@ -1,13 +1,13 @@
 
-CC= g++
-cc= gcc
-CFLAGS = -O3 -I../usr/include
+CXX=g++
+CXXFLAGS = -O3
 
 UNAME_S := $(shell uname -s)
 ifeq ($(UNAME_S),Darwin)
-LFLAGS = -L../usr/lib/ -L../usr/lib64/ -lkyotocabinet -lsnappy -lstdc++ -lpthread -lm -lc
+LIBS = -lkyotocabinet -lsnappy -lpthread -lm
 else
-LFLAGS = -L../usr/lib/ -L../usr/lib64/ -Wl,-Bstatic  -lkyotocabinet -lsnappy -Wl,-Bdynamic -lstdc++ -lrt -lpthread -lm -lc 
+CXXFLAGS += -pthread
+LIBS = -lkyotocabinet -lsnappy
 endif
 
 
@@ -18,10 +18,10 @@ OBJ = main.o point.o equation.o functions.o gateToFermat.o common.o parser.o
 
 
 FIRE5: $(OBJ)
-	${CC} $(OBJ)  ${LFLAGS}  -o FIRE5
+	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o FIRE5 $(OBJ) $(LIBS)
 
 .cpp.o:
-	${CC} ${CFLAGS} ${INCDIR} -c $<
+	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $<
 
 clean:
 	rm -f ./*.o test
