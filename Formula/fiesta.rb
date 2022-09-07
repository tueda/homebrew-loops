class Fiesta < Formula
  desc "Feynman Integral Evaluation by a Sector decomposiTion Approach"
  homepage "http://science.sander.su/FIESTA.htm"
  url "https://bitbucket.org/feynmanIntegrals/fiesta/get/3.5.tar.gz"
  sha256 "57429936d1ebb0765b15e63bc5ace3bab7990830190b70e55dd180e04c3a97c9"

  option "without-klink", "Do not build KLink"

  depends_on "cuba@3"
  depends_on "gmp"
  depends_on "kyoto-cabinet"
  depends_on "mpfr"
  depends_on "open-mpi" => :optional

  patch :DATA

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
    if build.with? "klink"
      env_math
    end
    system "make", "-C", "FIESTA3/mpfr"
    system "make", "-C", "FIESTA3/complex"
    system "make", "-C", "FIESTA3/threads"
    system "make", "-C", "FIESTA3/mpi" if build.with? "open-mpi"
    system "make", "-C", "FIESTA3/sourcesTools"
    system "make", "-C", "FIESTA3/KLink" if build.with? "klink"

    bin.install "FIESTA3/mpfr/CIntegrateMP"
    bin.install "FIESTA3/complex/CIntegrateMPC"
    bin.install "FIESTA3/threads/CIntegratePool"
    bin.install "FIESTA3/mpi/CIntegratePoolMPI" if build.with? "open-mpi"
    bin.install "FIESTA3/sourcesTools/OutputIntegrand"
    bin.install "FIESTA3/KLink/KLink" if build.with? "klink"

    inreplace "FIESTA3/FIESTA3.m" do |s|
      s.gsub! '    FIESTAPath=".";',
              "    FIESTAPath=\"#{opt_prefix}\";"
      s.gsub! 'CurrentAsyPath[]:=FIESTAPath<>"/extra/asy2.1.1.m";',
              'CurrentAsyPath[]:="asy2.1.1.m";'
      s.gsub! '    DataPath=FIESTAPath<>"/temp/db";',
              '    DataPath="/tmp/db";'
      s.gsub! '            QLink=Install[FIESTAPath<>"/bin/KLink"];',
              '            QLink=Install["KLink"];'
    end

    (share/"FIESTA3").install "FIESTA3/examples"
    (share/"Mathematica"/"Applications").install "FIESTA3/FIESTA3.m"
    (share/"Mathematica"/"Applications").install "FIESTA3/extra/asy2.1.1.m"
  end

  def caveats; <<~EOS
    FIESTA3.m and asy2.1.1.m have been copied to
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/
    You can add it to your Mathematica $Path by adding a line
      AppendTo[$Path, "#{HOMEBREW_PREFIX}/share/Mathematica/Applications"]]
    to the file obtained by
      FileNameJoin[{$UserBaseDirectory, "Kernel", "init.m"}]
    Or run the following command in Mathematica:
      (Import["https://git.io/AppendPath.m"];AppendPath["#{HOMEBREW_PREFIX}/share/Mathematica/Applications"])

    Examples have been copied to
      #{HOMEBREW_PREFIX}/share/FIESTA3/examples/

    To build KLink (--with-klink) on Linux with Mathematica 10, you need libuuid:
      brew install libuuid
    Mathematica executable for the build can be specified by the environment
    variable $HOMEBREW_MATH.

    KLink (--with-klink) conflicts with KLink in fire.
  EOS
  end

  test do
    require "open3"
    Open3.popen3("CIntegrateMP") do |stdin, _, _|
      stdin.write "Exit"
    end
    Open3.popen3("CIntegrateMPC") do |stdin, _, _|
      stdin.write "Exit"
    end
    system "CIntegratePool", "-test"
    system "mpirun", "-np", "2", "CIntegratePoolMPI", "-test" if build.with? "open-mpi"
    system "KLink", "-test" if build.with? "klink"
  end
end
__END__
diff --git a/FIESTA3/KLink/Makefile b/FIESTA3/KLink/Makefile
index 9cce5b4..ca63da3 100644
--- a/FIESTA3/KLink/Makefile
+++ b/FIESTA3/KLink/Makefile
@@ -1,9 +1,5 @@
 UNAME_S := $(shell uname -s)
-ifeq ($(UNAME_S),Darwin)
-MATHEXE=/Applications/Mathematica.app/Contents/MacOS/MathKernel
-else
-MATHEXE=math
-endif
+MATHEXE=$(HOMEBREW_MATH)
 
 
 
@@ -12,6 +8,10 @@ VERSION := $(shell echo -e $$ VersionNumber | tr -d " " | $(MATHEXE) -noprompt |
 MBASE := $(shell echo -e $$ InstallationDirectory | tr -d " " | $(MATHEXE) -noprompt | tr -d "\"\n")
 SYSID :=  $(shell echo -e $$ SystemID | tr -d " " | $(MATHEXE) -noprompt | tr -d "\"\n" )
 MLINKDIR = ${MBASE}/SystemFiles/Links/MathLink/DeveloperKit
+CADDSDIR = ${MLINKDIR}/${SYSID}/CompilerAdditions
+MLIB = ${CADDSDIR}/libML${BIT}i${MLIBVERSION}.a
+MPREP = ${CADDSDIR}/mprep
+
 ifeq ($(SYSID), Linux)
 	BIT := 32
 endif
@@ -19,34 +19,39 @@ ifeq ($(SYSID), Linux-x86-64)
 	BIT := 64
 endif
 
+CC = gcc
+CPPFLAGS += -I$(CADDSDIR)
+CFLAGS += -O3
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
-KLink: $(OBJ)
-	$(CC) $(OBJ) -L../usr/lib/ -L../usr/lib64/ ${LIBS} -o $@
+KLink : $(OBJ)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o KLink $(OBJ) $(LIBS)
 
 .c.o:
-	$(CC) -c -I${CADDSDIR} -I../usr/include/ -O2 -c $<
+	$(CC) $(CPPFLAGS) $(CFLAGS) -c $<
+
 
 MathSide.c : MathSide.tm
 	${MPREP} -o MathSide.c MathSide.tm
diff --git a/FIESTA3/complex/Makefile b/FIESTA3/complex/Makefile
index 3ceaa08..ea1b7b8 100644
--- a/FIESTA3/complex/Makefile
+++ b/FIESTA3/complex/Makefile
@@ -1,5 +1,3 @@
-include ../paths.inc
-include ../libs.inc
 include ../sources/obj.inc
 
 PRECISION = 64
@@ -7,12 +5,15 @@ PRECISION = 64
 vpath %.c ../sources
 vpath %.h ../sources
 
+CFLAGS += -O2
+CPPFLAGS += -DCOMPLEX=TRUE -DPRECISION=$(PRECISION)
+LIBS = -lmpfr -gmp -lcuba -lm
 
 CIntegrateMPC : $(OBJ)
-	$(CC) $(OBJ) ${LFLAGS} ${MPFRLIBDIR} ${CUBALIBDIR} ${LIBSSTART} -lmpfr -lgmp -lcuba ${LIBSEND} -o $@
+	$(CC) $(CFLAGS) $(LDFLAGS) -o CIntegrateMPC $(OBJ) $(LIBS)
 
 .c.o:
-	$(CC) $(CFLAGS) -DCOMPLEX=TRUE -DPRECISION=$(PRECISION) ${MPFRINCLUDEDIR} ${CUBAINCLUDEDIR} -c $<
+	$(CC) $(CPPFLAGS) $(CFLAGS) -c $<
 
 dep: depend
 
diff --git a/FIESTA3/mpfr/Makefile b/FIESTA3/mpfr/Makefile
index 248ebfc..6edce60 100644
--- a/FIESTA3/mpfr/Makefile
+++ b/FIESTA3/mpfr/Makefile
@@ -1,5 +1,3 @@
-include ../paths.inc
-include ../libs.inc
 include ../sources/obj.inc
 
 PRECISION = 64
@@ -7,12 +5,15 @@ PRECISION = 64
 vpath %.c ../sources
 vpath %.h ../sources
 
+CFLAGS += -O2
+CPPFLAGS += -DPRECISION=$(PRECISION)
+LIBS = -lmpfr -gmp -lcuba -lm
 
 CIntegrateMP : $(OBJ)
-	$(CC) $(OBJ) ${LFLAGS} ${MPFRLIBDIR} ${CUBALIBDIR} ${LIBSSTART} -lmpfr -lgmp -lcuba ${LIBSEND} -o $@
+	$(CC) $(CFLAGS) $(LDFLAGS) -o CIntegrateMP $(OBJ) $(LIBS)
 
 .c.o:
-	$(CC) $(CFLAGS) -DPRECISION=$(PRECISION) ${MPFRINCLUDEDIR} ${CUBAINCLUDEDIR} -c $<
+	$(CC) $(CPPFLAGS) $(CFLAGS) -c $<
 
 dep: depend
 
diff --git a/FIESTA3/mpi/Makefile b/FIESTA3/mpi/Makefile
index 8c41f47..b1152a6 100644
--- a/FIESTA3/mpi/Makefile
+++ b/FIESTA3/mpi/Makefile
@@ -1,15 +1,18 @@
-include ../paths.inc
-include ../libs.inc
 include ../sourcesPool/obj.inc
 
 vpath %.c ../sourcesPool
 vpath %.h ../sourcesPool
 
+MPICXX ?= mpicxx
+CXXFLAGS += -O2 -Wno-non-virtual-dtor
+CPPFLAGS += -DMPIMODE -DTHREADSMODE=0
+LIBS = -lkyotocabinet
+
 CIntegratePoolMPI : $(OBJ)
-	$(CCMPI) $(OBJ) ${KYOTOLIBDIR} ${LIBSSTART} -lkyotocabinet ${LIBSEND} -Wl,-Bdynamic -lc -o $@
+	$(MPICXX) $(CXXFLAGS) $(LDFLAGS) -o CIntegratePoolMPI $(OBJ) $(LIBS)
 
 .c.o:
-	$(CCMPI) $(CFLAGS) -Wno-non-virtual-dtor ${KYOTOINCLUDEDIR} -DMPIMODE -DTHREADSMODE=0 -c $<
+	$(MPICXX) $(CPPFLAGS) $(CXXFLAGS) -c $<
 
 dep: depend
 
diff --git a/FIESTA3/sourcesTools/Makefile b/FIESTA3/sourcesTools/Makefile
index 5167c6f..a2441a9 100644
--- a/FIESTA3/sourcesTools/Makefile
+++ b/FIESTA3/sourcesTools/Makefile
@@ -1,12 +1,16 @@
 include ../paths.inc
 include ../libs.inc
 
+CXXFLAGS += -O2
+CPPFLAGS += -Wno-non-virtual-dtor
+LIBS = -lkyotocabinet
+
 OBJ = OutputIntegrand.o
 
 OutputIntegrand : $(OBJ)
-	$(CCPLUS) $(OBJ) ${KYOTOLIBDIR} ${LIBSSTART} -lkyotocabinet ${LIBSEND} -lc -o $@
+	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o OutputIntegrand $(OBJ) $(LIBS)
 
 .c.o:
-	$(CCPLUS) $(CFLAGS) -Wno-non-virtual-dtor ${KYOTOINCLUDEDIR} -c $<
+	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $<
 
 OutputIntegrand.o : OutputIntegrand.c
\ No newline at end of file
diff --git a/FIESTA3/threads/Makefile b/FIESTA3/threads/Makefile
index 4b8ce0a..de07e26 100644
--- a/FIESTA3/threads/Makefile
+++ b/FIESTA3/threads/Makefile
@@ -1,15 +1,24 @@
-include ../paths.inc
-include ../libs.inc
 include ../sourcesPool/obj.inc
 
 vpath %.c ../sourcesPool
 vpath %.h ../sourcesPool
 
+CXXFLAGS += -O2
+CPPFLAGS += -DTHREADSMODE=1
+LIBS = -lkyotocabinet
+
+UNAME_S := $(shell uname -s)
+ifeq ($(UNAME_S),Darwin)
+LIBS += -lpthread
+else
+CXXFLAGS += -pthread
+endif
+
 CIntegratePool : $(OBJ)
-	$(CCPLUS) ${LFLAGS} $(OBJ) ${KYOTOLIBDIR} ${LIBSSTART} -lkyotocabinet ${LIBSEND} -o $@
+	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o CIntegratePool $(OBJ) $(LIBS)
 
 .c.o:
-	$(CCPLUS) $(CFLAGS) ${KYOTOINCLUDEDIR} -DTHREADSMODE=1 -c $<
+	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $<
 
 dep: depend
 
