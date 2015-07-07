class MmaMint < Formula
  desc "A package counting the masters in a given sector"
  homepage "http://www.inp.nsk.su/~lee/programs/LiteRed/"
  url "http://www.inp.nsk.su/~lee/programs/LiteRed/Mint/MintV1.1.zip"
  sha256 "6ccf1ea6a2b10ec911e0c21faeacce447e8ff932dad5b52bc00443dd84f31e26"

  def install
    installpath = share/"Mathematica"/"Applications"/"Mint-#{version}"
    installpath.install ["Setup/RNL", "Setup/Mint.m"]

    (share/"mma-mint"/"examples").install Dir.glob(["Examples/*.nb"])

    (buildpath/"Mint.m").write <<-EOS.undent
      If[!MemberQ[$Path, "#{installpath}"],
        AppendTo[$Path, "#{installpath}"];
      ];
      Get["#{installpath/"Mint.m"}"]
    EOS
    (share/"Mathematica"/"Applications").install "Mint.m"
  end

  def caveats; <<-EOS.undent
    Mint.m has been copied to
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/Mint.m
    You can add it to your Mathematica $Path by adding a line
      AppendTo[$Path, "#{HOMEBREW_PREFIX}/share/Mathematica/Applications"]]
    to the file obtained by
      FileNameJoin[{$UserBaseDirectory, "Kernel", "init.m"}]
    Or run the following command in Mathematica:
      (Import["https://git.io/AppendPath.m"];AppendPath["#{HOMEBREW_PREFIX}/share/Mathematica/Applications"])

    Examples have been copied to
      #{HOMEBREW_PREFIX}/share/mma-mint/examples/
    EOS
  end
end
