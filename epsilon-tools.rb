class EpsilonTools < Formula
  desc "Tool to find a canonical basis of master integrals"
  homepage "https://github.com/mprausa/epsilon"
  head "https://github.com/mprausa/epsilon.git"

  depends_on "boost"
  depends_on "cmake" => :build
  depends_on "ginac"
  depends_on "libfermat"

  def install
    args = std_cmake_args
    system "cmake", *args
    system "make"
    system "make", "install"

    mmapath = share/"Mathematica"/"Applications"/"EpsilonTools-#{version}"
    mmapath.install "mma/EpsilonTools.m"

    (buildpath/"EpsilonTools.m").write <<~EOS
      If[!MemberQ[$Path, "#{mmapath}"],
        AppendTo[$Path, "#{mmapath}"];
      ];
      Get["#{mmapath/"EpsilonTools.m"}"]
    EOS
    (share/"Mathematica"/"Applications").install "EpsilonTools.m"

    (share/"epsilon").install "example"
  end

  def caveats; <<~EOS
    EpsilonTools.m has been installed as
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/EpsilonTools.m
    #{mma_common_caveats}

    Examples have been copied to
      #{HOMEBREW_PREFIX}/share/epsilon/example/
    EOS
  end

  def mma_common_caveats; <<~EOS.chomp
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
