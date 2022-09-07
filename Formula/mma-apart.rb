class MmaApart < Formula
  desc "Generalized Mathematica Apart Function"
  homepage "https://github.com/F-Feng/APart"
  url "https://github.com/F-Feng/APart/archive/2.0.tar.gz"
  sha256 "acef7d6d15c11b28050ea700402207e41a7bf76b1f76330e9c4347c7ed3a0aee"

  head "https://github.com/F-Feng/APart.git"

  def install
    installpath = share/"Mathematica"/"Applications"/"Apart-#{version}"

    installpath.install "Apart.m"

    (buildpath/"Apart.m").write <<~EOS
      If[!MemberQ[$Path, "#{installpath}"],
        AppendTo[$Path, "#{installpath}"];
      ];
      Get["#{installpath/"Apart.m"}"]
    EOS
    (share/"Mathematica"/"Applications").install "Apart.m"
  end

  def caveats; <<~EOS
    Apart.m has been installed as
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/Apart.m
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
