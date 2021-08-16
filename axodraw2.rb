class Axodraw2 < Formula
  desc "Drawing Feynman graphs in LaTeX documents"
  homepage "https://ctan.org/pkg/axodraw2"
  url "http://mirrors.ctan.org/graphics/axodraw2/axodraw2.sty"
  version "2.1.1c"
  sha256 "2957e0f96a1d21bcea875fdd01333a1b88cb8846f2cb23c4e67c2ada22eb4061"

  resource "axohelp" do
    url "http://mirrors.ctan.org/graphics/axodraw2/axohelp.c"
    sha256 "f3ee51269de018bf9e2ff049bbfe7e99ef24a5f05410aa3889d36809ff49f128"
  end

  resource "axoman" do
    url "http://mirrors.ctan.org/graphics/axodraw2/axodraw2-man.pdf"
    sha256 "e855f63cf9f69dec436b6bad64212e1a3281132b386989f1ee7d6a2a101b8ba2"
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
