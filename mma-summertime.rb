class MmaSummertime < Formula
  desc "Package for the multiple sums with factorized summand"
  homepage "http://www.inp.nsk.su/~lee/programs/SummerTime/"
  url "http://www.inp.nsk.su/~lee/programs/SummerTime/releases/SummerTime-v1.0.zip"
  sha256 "654dc1f73d3e10529584d074d0738645d8844e3cfc01f1f6c924fae91842afe4"

  def install
    installpath = share/"Mathematica"/"Applications"/"SummerTime-#{version}"

    installpath.install Dir.glob(["SummerTime-v#{version}/*"])

    (buildpath/"SummerTime.m").delete
    (buildpath/"SummerTime.m").write <<-EOS.undent
      Get["#{installpath/"SummerTime.m"}"]
    EOS
    (share/"Mathematica"/"Applications").install "SummerTime.m"
  end

  def caveats; <<-EOS.undent
    SummerTime.m has been copied to
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/SummerTimed.m
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
