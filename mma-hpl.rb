class MmaHpl < Formula
  desc "Implementation of the harmonic polylogarithms (HPL)"
  homepage "http://krone.physik.unizh.ch/~maitreda/HPL/"
  url "http://krone.physik.unizh.ch/~maitreda/HPL/HPL-2.0.tar.gz"
  sha256 "ca965edb320c735f31433daf11b099ef11d2fbd1a8108b11293d18a6674136ee"

  option "with-weight7", "Install up to weight 7 tables"
  option "with-weight8", "Install up tp weight 8 tables"

  resource "MinimalSet7" do
    url "http://krone.physik.unizh.ch/~maitreda/HPL/MinimalSet7.m.gz"
    sha256 "8080deebb06e987012dca29e6fb0c2ff60cba2da83f3a8c50e146920d8960fd6"
  end

  resource "MinimalSet8" do
    url "http://krone.physik.unizh.ch/~maitreda/HPL/MinimalSet8.m.gz"
    sha256 "d9f399701eae41cf345e7e5ac3b14ff06685082b02626aaa604776a0ae08297c"
  end

  resource "MinimalSetpm7" do
    url "http://krone.physik.unizh.ch/~maitreda/HPL/MinimalSetpm7.m.gz"
    sha256 "7678a9abed3512bbec75a0257e78e10ff547a63c8cfd4e8139063cbdcbbad07c"
  end

  resource "MinimalSetpm8" do
    url "http://krone.physik.unizh.ch/~maitreda/HPL/MinimalSetpm8.m.gz"
    sha256 "3656b8d4a04beab08628a2177ca38ae7eeba442825bd53a5884909b49929f868"
  end

  resource "h7table" do
    url "http://krone.physik.unizh.ch/~maitreda/HPL/h7table.mat.gz"
    sha256 "71bbe2ac67fe094a05375a4cc50b406639fad2f810b364d8604b614eb9b8f481"
  end

  resource "h8table" do
    url "http://krone.physik.unizh.ch/~maitreda/HPL/h8table.mat.gz"
    sha256 "e94182546438c5e138ebd157c1a5e4c0e30accc0510dff4ad7287d883a19a7e0"
  end

  resource "HPLatI7" do
    url "http://krone.physik.unizh.ch/~maitreda/HPL/HPLatI7.m.gz"
    sha256 "82131dfbacfe65273a2add6518151c3313e58275d9ead05e201991a5d61bbb7e"
  end

  resource "numHPLatI7" do
    url "http://krone.physik.unizh.ch/~maitreda/HPL/numHPLatI7.m.gz"
    sha256 "5841dc85299424ab1b77ea408587c4a72f4494179cc680d6756ecbec0c5a9d50"
  end

  def install
    hplpath = share/"Mathematica"/"Applications"/"HPL-#{version}"

    hplpath.install Dir.glob(["MinimalSet*.m",
                              "h*table.mat",
                              "*HPLatI*.m",
                              "HPL.m", "nmzv.m"])

    (buildpath/"HPL.m").write <<~EOS
      $HPLPath = "#{hplpath}";
      If[!MemberQ[$Path, $HPLPath],
        AppendTo[$Path, $HPLPath];
      ];
      Get["#{hplpath/"HPL.m"}"]
    EOS
    (share/"Mathematica"/"Applications").install "HPL.m"

    (pkgshare/"examples").install "HPL-2Examples.nb"

    if build.with?("weight7") || build.with?("weight8")
      resource("MinimalSet7").stage { hplpath.install "MinimalSet7.m" }
      resource("MinimalSetpm7").stage { hplpath.install "MinimalSetpm7.m" }
      resource("h7table").stage { hplpath.install "h7table.mat" }
      resource("HPLatI7").stage { hplpath.install "HPLatI7.m" }
      resource("numHPLatI7").stage { hplpath.install "numHPLatI7.m" }
    end

    if build.with? "weight8"
      resource("MinimalSet8").stage { hplpath.install "MinimalSet8.m" }
      resource("MinimalSetpm8").stage { hplpath.install "MinimalSetpm8.m" }
      resource("h8table").stage { hplpath.install "h8table.mat" }
    end
  end

  def caveats; <<~EOS
    HPL.m has been copied to
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/HPL.m
    You can add it to your Mathematica $Path by adding a line
      AppendTo[$Path, "#{HOMEBREW_PREFIX}/share/Mathematica/Applications"]]
    to the file obtained by
      FileNameJoin[{$UserBaseDirectory, "Kernel", "init.m"}]
    Or run the following command in Mathematica:
      (Import["https://git.io/AppendPath.m"];AppendPath["#{HOMEBREW_PREFIX}/share/Mathematica/Applications"])

    Examples have been copied to
      #{HOMEBREW_PREFIX}/share/mma-hpl/examples/
    EOS
  end

  test do
  end
end
