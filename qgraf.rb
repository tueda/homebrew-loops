class Qgraf < Formula
  desc "Computer program to generate Feynman diagrams"
  homepage "http://cfif.ist.utl.pt/~paulo/qgraf.html"
  url "http://anonymous:@qgraf.tecnico.ulisboa.pt/v3.4/qgraf-3.4.2.tgz"
  sha256 "cfc029fb871c78943865ef8b51ebcd3cd4428448b8816714b049669dfdeab8aa"

  option "with-maxdeg10", "Extend the maximum vertex degree to 10"

  depends_on "gcc" # for gfortran

  def install
    inreplace "qgraf-3.4.2.f", "maxdeg=6", "maxdeg=10" if build.with? "maxdeg10"
    system "gfortran", "-o", "qgraf", "qgraf-3.4.2.f"
    Dir.mkdir("example")
    cp ["array.sty", "form.sty", "phi3", "qcd", "qed", "qgraf.dat", "sum.sty"], "example"
    bin.install "qgraf"
    doc.install Dir["*.pdf"]
    doc.install "example"
  end

  def caveats; <<~EOS
    Documents and example files have been copied to:
      #{doc}
  EOS
  end

  test do
    system "#{bin}/qgraf"
  end
end
