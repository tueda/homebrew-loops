class Axodraw2 < Formula
  desc "LaTeX graphical style file"
  homepage "http://www.nikhef.nl/~form/maindir/others/axodraw2/axodraw2.html"
  url "http://www.nikhef.nl/~form/maindir/others/axodraw2/axodraw2.sty"
  sha256 "f71dc57d3a5c0c3c7f8e4412c7fb7bb499a48fda643d44d6793178cb3eaa7b4b"

  resource "axohelp" do
    url "http://www.nikhef.nl/~form/maindir/others/axodraw2/axohelp.c"
    sha256 "a46a733b3fa1ada6bc58bcdbce3348d0cb12ff4664f09ade042d98fc01189f0b"
  end

  resource "axoman" do
    url "http://www.nikhef.nl/~form/maindir/others/axodraw2/axoman2.pdf"
    sha256 "ae42913435d33b44c8ddd711780b126673bcf5b183b151e253f969ae492c3d02"
  end

  def install
    (share/"texmf"/"tex"/"latex"/name).install "axodraw2.sty"

    resource("axohelp").stage do
      system ENV.cc, "-o", "axohelp", "axohelp.c", "-lm"
      bin.install "axohelp"
    end

    resource("axoman").stage do
      doc.install "axoman2.pdf"
    end
  end

  def caveats
    if OS.mac?
      default_texmf = "~/Library/texmf"
    elsif OS.linux?
      default_texmf = "~/texmf"
    end

    <<-EOS.undent
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
    system "axohelp", "test"
  end
end
