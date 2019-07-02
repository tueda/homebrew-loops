require File.expand_path("Library/mma_lib", __dir__)

class Feynrules < Formula
  desc "Mathematica package to calculate Feynman rules"
  homepage "https://feynrules.irmp.ucl.ac.be/"
  url "http://feynrules.irmp.ucl.ac.be/downloads/feynrules-current.tar.gz"
  version "2.3.34"
  sha256 "a17c76da0d317d81150e6e73a800675a8a0e61bd88ab148c9016816ae3c468e9"

  def install
    mma_pkg_wrapper("FeynRules.m",
                    ["Core",
                     "Interfaces",
                     "Models",
                     "FeynRulesPackage.m",
                     "FRPalette.nb",
                     "NLOCT.m",
                     "ToolBox.m"],
                    "$FeynRulesPath = SetDirectory[\"#{mma_pkg_private_path}\"];")
  end

  def caveats; <<~EOS
    #{mmapath_message}
  EOS
  end

  test do
    (testpath/"test.m").write <<~EOS
      AppendTo[$Path, "#{mma_app_path}"];
      << FeynRules`;
      SetDirectory[$FeynRulesPath <> "/Models/FirstExample"];
      LoadModel["FirstExample.fr"];
      If[Head[FS[G, mu, nu, a]] === FS,
        Print["Failed: " <> ToString[FS[G, mu, nu, a]]];
        Exit[1];
      ];
    EOS
    system ENV.wolframscript, "-f", "test.m"
  end
end
