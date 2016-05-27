class Axodraw2 < Formula
  desc "LaTeX graphical style file"
  homepage "http://www.nikhef.nl/~form/maindir/others/axodraw2/axodraw2.html"
  url "http://www.nikhef.nl/~form/maindir/others/axodraw2/axodraw2.sty"
  sha256 "b2947e7c7dd341673157a657ca5e6ae5827c0fe663be518f8564aab94dd1323a"

  resource "axohelp" do
    url "http://www.nikhef.nl/~form/maindir/others/axodraw2/axohelp.c"
    sha256 "60ff628991b38b0d761201a84a1cb51a9543b2920d3d8f32d9b8404982d7c3ef"
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
