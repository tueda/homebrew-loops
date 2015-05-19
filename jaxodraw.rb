require 'formula'

class Jaxodraw < Formula
  homepage "http://jaxodraw.sourceforge.net/"
  url "http://jaxodraw.sourceforge.net/download/pkgs/jaxodraw-2.1-0-bin.tar.gz"
  sha1 "e2eaecf369fd4999b27cc1d3fdc780ad599aab04"

  resource "axodraw4j" do
    url "https://downloads.sourceforge.net/project/jaxodraw/axodraw4j/axodraw4j_2008_11_19/axodraw4j_2008_11_19.tar.gz"
    sha1 "d07b4b51548037ce95ccf17a246afa0a181fa0e5"
  end

  resource "jax2eps" do
    url "http://users.phys.psu.edu/~collins/software/JD-utils/jax2eps"
    sha1 "e423fcd39ae56579a2b0053f6dec6e9d4bb69845"
  end

  resource "jax2tex" do
    url "http://users.phys.psu.edu/~collins/software/JD-utils/jax2tex"
    sha1 "0d23804dec3107aa8a1d198e2cf2c8a46f99af9e"
  end

  def install
    libexec.install "#{name}-#{version}.jar"
    bin.write_jar_script libexec/"#{name}-#{version}.jar", name
    resource("axodraw4j").stage do
      File.chmod 0644, "axodraw4j.sty"  # 600 -> 644
      (share/"texmf"/"tex"/"latex"/name).install "axodraw4j.sty"
    end
    cp resource("jax2eps").cached_download, "jax2eps"
    cp resource("jax2tex").cached_download, "jax2tex"
    inreplace ["jax2eps", "jax2tex"] do |s|
      s.gsub! "jaxodraw2", "jaxodraw"
    end
    inreplace "jax2eps" do |s|
      # Evince (GNOME Document Viewer 2.28.2) displays nothing for EPS generated
      # by ps2eps with -C option.
      s.gsub! 'system "ps2eps -q -C -c -l -B < $base.ps > $base.eps";',
              'system "ps2eps -q -c -l -B < $base.ps > $base.eps";'
    end
    bin.install ["jax2eps", "jax2tex"]
  end

  def caveats;
    if OS.mac?
      default_texmf = "~/Library/texmf"
    elsif OS.linux?
      default_texmf = "~/texmf"
    end

    <<-EOS.undent
    axodraw4j.sty has been installed to
      #{HOMEBREW_PREFIX}/share/texmf/tex/latex/#{name}/axodraw4j.sty

    If you are using TeX Live, you can add it to your TEXMFHOME using
      tlmgr conf texmf TEXMFHOME "#{default_texmf}:#{HOMEBREW_PREFIX}/share/texmf"
    EOS
  end
end
