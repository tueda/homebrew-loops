class Lanhep < Formula
  desc "Feynman rules generation in momentum representation"
  homepage "https://theory.sinp.msu.ru/~semenov/lanhep.html"
  url "https://theory.sinp.msu.ru/~semenov/lhep400.tgz"
  version "4.0.0"
  sha256 "881dcfad962e21bfe76531799a131b2f2dfc5cfaa3414bb80ab4f14955b6c56b"

  def install
    inreplace "main.c", "InputDirectory=find_path(argv[0],env);", "InputDirectory=find_path(\"#{share}/\",env);"
    ENV.deparallelize
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
