class MmaFeyncalc < Formula
  desc "Tools and tables for quantum field theory calculations"
  homepage "http://www.feyncalc.org/"
  url "https://github.com/FeynCalc/feyncalc/archive/Release-9_2_0.tar.gz"
  sha256 "8ae3b607207cfd675e5221ff3e724aff7e019ea030597249b500a0e4702d7115"

  head "https://github.com/FeynCalc/feyncalc.git", :branch => "hotfix-stable"

  def install
    installpath = share/"Mathematica"/"Applications"/"FeynCalc-#{version}"

    mv "FeynCalc/DocOutput", "FeynCalc/Documentation"
    installpath.install Dir["FeynCalc/*"]

    (buildpath/"FeynCalc.m").write <<~EOS
      If[!MemberQ[$Path, "#{installpath}"],
        AppendTo[$Path, "#{installpath}"];
        PacletDirectoryAdd["#{installpath}"];
      ];
      Get["#{installpath/"FeynCalc.m"}"]
    EOS
    (share/"Mathematica"/"Applications").install "FeynCalc.m"
  end

  def caveats; <<~EOS
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
