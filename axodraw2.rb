class Axodraw2 < Formula
  desc "Drawing Feynman graphs in LaTeX documents"
  homepage "https://ctan.org/pkg/axodraw2"
  url "http://mirrors.ctan.org/graphics/axodraw2/axodraw2.sty"
  version "2.1.1b"
  sha256 "2957e0f96a1d21bcea875fdd01333a1b88cb8846f2cb23c4e67c2ada22eb4061"

  resource "axohelp" do
    url "http://mirrors.ctan.org/graphics/axodraw2/axohelp.c"
    sha256 "53dbecf517ab670b3770f0959e40a221933ff1bb6dd214c61cb250a2170a3780"
  end

  resource "axoman" do
    url "http://mirrors.ctan.org/graphics/axodraw2/axodraw2-man.pdf"
    sha256 "d14994f760669ed3d2fda0effc3eb0cff9232211b6351b801afa118f0150a98f"
  end

  def install
    (share/"texmf"/"tex"/"latex"/name).install "axodraw2.sty"

    resource("axohelp").stage do
      system ENV.cc, "-o", "axohelp", "axohelp.c", "-lm"
      bin.install "axohelp"
    end

    resource("axoman").stage do
      doc.install "axodraw2-man.pdf"
    end
  end

  def caveats
    if OS.mac?
      default_texmf = "~/Library/texmf"
    elsif OS.linux?
      default_texmf = "~/texmf"
    end

    <<~EOS
      axodraw2.sty has been installed to
        #{HOMEBREW_PREFIX}/share/texmf/tex/latex/#{name}/axodraw2.sty

      If you are using TeX Live, you can add it to your TEXMFHOME using
        tlmgr conf texmf TEXMFHOME "#{default_texmf}:#{HOMEBREW_PREFIX}/share/texmf"

      The manual has been copied to:
        #{doc}/axoman2.pdf
    EOS
  end

  test do
    touch testpath/"test.ax1"
    system "#{bin}/axohelp", "test"
  end
end
