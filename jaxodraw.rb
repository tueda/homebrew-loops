class Jaxodraw < Formula
  desc "Java program for drawing Feynman diagrams"
  homepage "http://jaxodraw.sourceforge.net/"
  url "http://jaxodraw.sourceforge.net/download/pkgs/jaxodraw-2.1-0-bin.tar.gz"
  sha256 "ab1b0d2e9c4a886b42b10068eda21e299844b2df9d4c5a6737887a0c98345c42"

  resource "axodraw4j" do
    url "https://downloads.sourceforge.net/project/jaxodraw/axodraw4j/axodraw4j_2008_11_19/axodraw4j_2008_11_19.tar.gz"
    sha256 "60353a25563cb4e987304a7d030bbc7e85c688c881f804cd08e8ba76a370af61"
  end

  resource "jax2eps" do
    url "http://users.phys.psu.edu/~collins/software/JD-utils/jax2eps"
    sha256 "e8c99a43142bfc44d83943c0ec2f6a19eaa2e423c52df7430b5a76b2f0428c4e"
  end

  resource "jax2tex" do
    url "http://users.phys.psu.edu/~collins/software/JD-utils/jax2tex"
    sha256 "af6479d0703492f3e88276ffe7565587e0f7c562c1119e07d3c8a712de108ca6"
  end

  def install
    libexec.install "#{name}-#{version}.jar"
    bin.write_jar_script libexec/"#{name}-#{version}.jar", name
    resource("axodraw4j").stage do
      File.chmod 0644, "axodraw4j.sty" # 600 -> 644
      (share/"texmf"/"tex"/"latex"/name).install "axodraw4j.sty"
    end
    [resource("jax2eps"), resource("jax2tex")].each do |r|
      r.verify_download_integrity(r.fetch)
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

  def caveats
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

  test do
    # system "jaxodraw", "--version"
  end
end
