class MmaPackageX < Formula
  desc "Package to get compact analytic expressions for loop integrals"
  homepage "https://packagex.hepforge.org/"
  url "http://www.hepforge.org/archive/packagex/X-2.1.0.zip"
  sha256 "fc8c071f871575c01dbbe472b192e2fc1387ae8e196c347d3b7b88d978396715"

  def install
    installpath = share/"Mathematica"/"Applications"/"X-#{version}"
    installpath.install "X"

    (buildpath/"X.m").write <<-EOS.undent
      If[!MemberQ[$Path, "#{installpath}"],
        AppendTo[$Path, "#{installpath}"];
        PacletDirectoryAdd["#{installpath}"];
      ];
      Get["X`", Path -> "#{installpath}"]
    EOS
    (share/"Mathematica"/"Applications").install "X.m"
  end

  def caveats; <<-EOS.undent
    X.m has been created at
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/X.m
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
