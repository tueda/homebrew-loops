class GraceTree < Formula
  desc "Automatized perturbative calculation on computers"
  homepage "http://minami-home.kek.jp/"
  url "http://minami-home.kek.jp/grace221/grace.221.2006.0116.tgz"
  version "2.2.1"
  sha256 "a4971eddf65126a796c788661cdfa8c7cf738d91200d09a36999cc92baa943cf"

  depends_on "gcc" # for gfortran

  def install
    ENV.deparallelize
    inreplace "Config.sh" do |s|
      s.gsub! "gracedir=`pwd`", "gracedir=#{prefix}"
      # Disable X for now: a directory found by Config.sh (/usr/include/ and
      # /usr/lib) can be incompatible with brewed gcc. Difficult to fix
      # on Travis CI.
      s.gsub! "# Athena widget and Motif", <<~EOS
        xwin=0
        xincd=
        xopti=
        xoptl=
      EOS
    end
    system "./Config.sh"
    inreplace "Makefile" do |s|
      s.gsub! /FC        =.*/, "FC        = gfortran"
      s.gsub! /FFLAGS    =.*/, "FFLAGS    = -O2"
      s.gsub! /CC        =.*/, "CC        = gcc"
      s.gsub! /COPT      =.*/, "COPT      = -O2"
    end
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"sm"/"in.prc").write <<~EOS
      Model="sm.mdl";
      Process;
        ELWK=3;
        Initial={electron, positron};
        Final  ={photon W-plus, W-minus};
        Expand=Yes;
        OPI=No;
        Kinem="2302";
      Pend;
    EOS
    (testpath/"mssm"/"in.prc").write <<~EOS
      Model="mssm.mdl";
      Process;
        ELWK={3};
        Initial={electron positron};
        Final  ={photon Chargino1 anti-Chargino1};
        Expand=Yes;
        OPI=No;
        Block=No;
        Extself=No;
        Tadpole=No;
        Kinem="2302";
      Pend;
    EOS
    Dir.chdir("sm") do
      system "#{bin}/grc"
      system "#{bin}/grcfort"
      system "make"
      system "./gauge"
    end
    Dir.chdir("mssm") do
      system "#{bin}/grc"
      system "#{bin}/grcfort"
      system "make"
      system "./gauge"
    end
  end
end
