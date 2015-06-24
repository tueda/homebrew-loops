class MmaHypexp < Formula
  desc "Expand hypergeometric functions JFJ-1 around their parameters"
  homepage "http://krone.physik.unizh.ch/~maitreda/HypExp/"
  url "http://krone.physik.unizh.ch/~maitreda/HypExp/HypExp-2.0.tar.gz"
  sha256 "d6275525a37d393c7706210d875364d06962f84e1715b570f07c56ed3cf9a60f"

  resource "lib2new" do
    url "http://krone.physik.unizh.ch/~maitreda/HypExp/lib2new.tar.gz"
    sha256 "a0d2ebbafa9710a46cb5f0d50d0b57c6c488d562b8707a1416abe2977b3ead97"
  end

  resource "lib3new" do
    url "http://krone.physik.unizh.ch/~maitreda/HypExp/lib3new.tar.gz"
    sha256 "a0cd561c149fcbecca53c24d3fc725c785dc6ef557a17f0693dd4339ce782428"
  end

  depends_on "mma-hpl"

  option "with-lib2", "Install 2F1 library"
  option "with-lib3", "Install 3F2 library"

  def install
    hypexppath = share/"Mathematica"/"Applications"/"HypExp-#{version}"

    hypexppath.install Dir.glob(["HypExp.m",
                                 "rrlpnHPL_private.out2",
                                 "listintegralsminimal.m",
                                 "rulesalgorithm.m",
                                 "collectedfunctions.out",
                                 "rrarg.m",
                                 "PZRule*.m"])

    (buildpath/"HypExp.m").write <<-EOS.undent
      $HypExpPath = "#{hypexppath}";
      If[!MemberQ[$Path, $HypExpPath],
        AppendTo[$Path, $HypExpPath];
      ];
      Get["#{hypexppath/"HypExp.m"}"]
    EOS
    (share/"Mathematica"/"Applications").install "HypExp.m"

    (buildpath/".known.m").write <<-EOS.undent
      {KnownToOrder1}
    EOS
    hypexppath.install ".known.m"

    inreplace "install_libs" do |s|
      s.gsub! 'echo "\$HPLPath = \"$installdir\""',
              "echo \"Get[\\\"#{HOMEBREW_PREFIX}/share/Mathematica/Applications/HPL.m\\\"]\""
      s.gsub! 'echo "<<HypExp\`"',
              'echo "Get[\"$installdir/HypExp.m\"]"'
    end

    if build.with? "lib2" or build.with? "lib3"
      libs = []
      libs << resource("lib2new") if build.with? "lib2"
      libs << resource("lib3new") if build.with? "lib3"
      Dir.mkdir("tmp")
      libs.each do |r|
        r.verify_download_integrity(r.fetch)
        cp r.cached_download, buildpath/"#{r.name}.tar.gz"
      end
      system "./install_libs", hypexppath
    end
  end

  def caveats; <<-EOS.undent
    HypExp.m has been copied to
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/HypExp.m
    You can add it to your Mathematica $Path by adding a line
      AppendTo[$Path, "#{HOMEBREW_PREFIX}/share/Mathematica/Applications"]]
    to the file obtained by
      FileNameJoin[{$UserBaseDirectory, "Kernel", "init.m"}]
    Or run the following command in Mathematica:
      (Import["https://git.io/AppendPath.m"];AppendPath["#{HOMEBREW_PREFIX}/share/Mathematica/Applications"])
    EOS
  end
end
