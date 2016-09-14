class MmaFeyncalc < Formula
  desc "Tools and tables for quantum field theory calculations"
  homepage "http://www.feyncalc.org/"
  url "https://github.com/FeynCalc/feyncalc/archive/Release-9_1_0.tar.gz"
  sha256 "c97ee49118cb96406c61507a4442b8dbabf1a8e123e72801fbcfefeb1d63bfad"

  head "https://github.com/FeynCalc/feyncalc.git", :branch => "hotfix-stable"

  def install
    installpath = share/"Mathematica"/"Applications"/"FeynCalc-#{version}"

    mv "FeynCalc/DocOutput", "FeynCalc/Documentation"
    installpath.install Dir["FeynCalc/*"]

    (buildpath/"FeynCalc.m").write <<-EOS.undent
      If[!MemberQ[$Path, "#{installpath}"],
        AppendTo[$Path, "#{installpath}"];
        PacletDirectoryAdd["#{installpath}"];
      ];
      Get["#{installpath/"FeynCalc.m"}"]
    EOS
    (share/"Mathematica"/"Applications").install "FeynCalc.m"
  end

  def caveats; <<-EOS.undent
    FeynCalc.m has been installed to
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/FeynCalc.m
    You can add it to your Mathematica $Path by adding a line
      AppendTo[$Path, "#{HOMEBREW_PREFIX}/share/Mathematica/Applications"]]
    to the file obtained by
      FileNameJoin[{$UserBaseDirectory, "Kernel", "init.m"}]
    Or run the following command in Mathematica:
      (Import["https://git.io/AppendPath.m"];AppendPath["#{HOMEBREW_PREFIX}/share/Mathematica/Applications"])
    EOS
  end

  test do
  end
end
