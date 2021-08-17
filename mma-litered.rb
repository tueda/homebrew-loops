class MmaLitered < Formula
  desc "Package performing the IBP reduction of the multiloop integrals"
  homepage "http://www.inp.nsk.su/~lee/programs/LiteRed/"
  url "https://www.inp.nsk.su/~lee/programs/LiteRed/LiteRedV1/LiteRedV1.83.zip"
  sha256 "608d22f868eb8de849b2e53eac8fa0f96a98b4eabca6478df4131fb0464a75ed"

  def install
    installpath = share/"Mathematica"/"Applications"/"LiteRed-#{version}"
    installpath.install ["Setup/RNL", "Setup/LiteRed.m"]

    (pkgshare/"examples").install Dir.glob(["Examples/*.nb"])

    (buildpath/"LiteRed.m").write <<~EOS
      If[!MemberQ[$Path, "#{installpath}"],
        AppendTo[$Path, "#{installpath}"];
      ];
      Get["#{installpath/"LiteRed.m"}"]
    EOS
    (share/"Mathematica"/"Applications").install "LiteRed.m"
  end

  def caveats; <<~EOS
    LiteRed.m has been copied to
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/LiteRed.m
    You can add it to your Mathematica $Path by adding a line
      AppendTo[$Path, "#{HOMEBREW_PREFIX}/share/Mathematica/Applications"]]
    to the file obtained by
      FileNameJoin[{$UserBaseDirectory, "Kernel", "init.m"}]
    Or run the following command in Mathematica:
      (Import["https://git.io/AppendPath.m"];AppendPath["#{HOMEBREW_PREFIX}/share/Mathematica/Applications"])

    Examples have been copied to
      #{HOMEBREW_PREFIX}/share/mma-litered/examples/
  EOS
  end

  test do
  end
end
