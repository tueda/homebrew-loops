class MmaLitered < Formula
  desc "Package performing the IBP reduction of the multiloop integrals"
  homepage "http://www.inp.nsk.su/~lee/programs/LiteRed/"
  url "http://www.inp.nsk.su/~lee/programs/LiteRed/LiteRedV1/LiteRedV1.82.zip"
  sha256 "8acce970305ad52487c13c3643b1725df81248986bd39ef11d96f172fc8dd826"

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
