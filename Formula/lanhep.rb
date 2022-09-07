class Lanhep < Formula
  desc "Feynman rules generation in momentum representation"
  homepage "https://theory.sinp.msu.ru/~semenov/lanhep.html"
  url "https://theory.sinp.msu.ru/~semenov/lhep332.tgz"
  version "3.3.2"
  sha256 "82690ef2976d708622017687ee302951ece737779e8ac5db55b5df98aefc07df"

  def install
    inreplace "main.c", "InputDirectory=find_path(argv[0],env);", "InputDirectory=find_path(\"#{share}/\",env);"
    system "make"
    bin.install "lhep"
    share.install %w[mdl minsusy susy8 susyLHA test]
  end

  test do
    system bin/"lhep", "-co", "-OutDir", "tmp", share/"test/input/stand.mdl"
    ["func4.mdl", "lgrng4.mdl", "prtcls4.mdl", "vars4.mdl"].each do |f|
      assert_equal (testpath/"tmp"/f).read, (share/"test/output"/f).read
    end
  end
end
