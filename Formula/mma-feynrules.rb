require File.expand_path("Library/mma_lib", __dir__)

class MmaFeynrules < Formula
  desc "Mathematica package to calculate Feynman rules"
  homepage "https://feynrules.irmp.ucl.ac.be/"
  url "http://feynrules.irmp.ucl.ac.be/downloads/feynrules-current.tar.gz"
  version "2.3.49"
  sha256 "85eddac7b5b61eac772c93df93a0c44bc34f531069985a719fe454f0a54afc81"

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

  def caveats
    <<~EOS
      #{mmapath_message}
      Note that this formula installs the package in such a way that $FeynRulesPath is automatically defined.
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
