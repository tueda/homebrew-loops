class MmaFeynarts < Formula
  desc "Generation and visualization of Feynman diagrams and amplitudes"
  homepage "http://www.feynarts.de/"
  url "http://www.feynarts.de/FeynArts-3.9.tar.gz"
  sha256 "1add14aea4f3ee09b29e88438ad105ccd7df48969514c6b902f6c57bee303963"

  def install
    installpath = share/"Mathematica"/"Applications"/"FeynArts-#{version}"
    installpath.install ["ShapeData", "FeynArts", "FeynArts.m", "Models",
                         "Setup.m"]
    doc.install "manual/FA3Guide.pdf"

    (buildpath/"FeynArts.m").write <<~EOS
      If[!MemberQ[$Path, "#{installpath}"],
        AppendTo[$Path, "#{installpath}"];
      ];
      Get["#{installpath/"FeynArts.m"}"]
    EOS
    (share/"Mathematica"/"Applications").install "FeynArts.m"
  end

  def caveats; <<~EOS
    FeynArts.m has been installed to
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/FeynArts.m
    You can add it to your Mathematica $Path by adding a line
      AppendTo[$Path, "#{HOMEBREW_PREFIX}/share/Mathematica/Applications"]]
    to the file obtained by
      FileNameJoin[{$UserBaseDirectory, "Kernel", "init.m"}]
    Or run the following command in Mathematica:
      (Import["https://git.io/AppendPath.m"];AppendPath["#{HOMEBREW_PREFIX}/share/Mathematica/Applications"])

    The manual has been copied to:
      #{doc}/FA3Guide.pdf
    EOS
  end

  test do
  end
end
