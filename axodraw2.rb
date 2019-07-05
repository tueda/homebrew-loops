class Axodraw2 < Formula
  desc "Drawing Feynman graphs in LaTeX documents"
  homepage "https://ctan.org/pkg/axodraw2"
  url "http://mirrors.ctan.org/graphics/axodraw2/axodraw2.sty"
  version "2.1.1a"
  sha256 "3924eac2592d263312614c4ca784e58c414a9bf4b083c04b21d91e7979fb7547"

  resource "axohelp" do
    url "http://mirrors.ctan.org/graphics/axodraw2/axohelp.c"
    sha256 "6a8af85b1a6314d089829d30afa76dc94bc6c873a65d8236044ba7a8d7d0ebff"
  end

  resource "axoman" do
    url "http://mirrors.ctan.org/graphics/axodraw2/axodraw2-man.pdf"
    sha256 "e48dc8a9a900fa1c3ee76ebf742323fdaf047c1e97990cbb42df68d1e0b5c556"
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
