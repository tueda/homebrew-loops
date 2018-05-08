class Qgraf < Formula
  desc "Computer program to generate Feynman diagrams"
  homepage "http://cfif.ist.utl.pt/~paulo/qgraf.html"
  url "http://anonymous:@qgraf.ist.utl.pt/v3.1/qgraf-3.1.4.tgz"
  sha256 "b6f827a654124b368ea17cd391a78a49cda70e192e1c1c22e8e83142b07809dd"

  option "with-maxdeg10", "Extend the maximum vertex degree to 10"

  depends_on "gcc"  # for gfortran

  def install
    inreplace "qgraf-3.1.4.f", "maxdeg=6", "maxdeg=10" if build.with? "maxdeg10"
    system ENV.fc, "-o", "qgraf", "qgraf-3.1.4.f"
    Dir.mkdir("example")
    cp ["array.sty", "form.sty", "phi3", "qgraf.dat", "sum.sty"], "example"
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
