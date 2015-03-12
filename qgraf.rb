require 'formula'

class Qgraf < Formula
  homepage "http://cfif.ist.utl.pt/~paulo/qgraf.html"
  url "http://anonymous:@qgraf.ist.utl.pt/v3.1/qgraf-3.1.4.tgz"
  sha1 "4bf56402255af7b9a8f26f14f4f1d02aaff34f7f"

  depends_on :fortran

  def install
    system ENV.fc, "-o", "qgraf", "qgraf-3.1.4.f"
    Dir.mkdir("example")
    cp ["array.sty", "form.sty", "phi3", "qgraf.dat", "sum.sty"], "example"
    bin.install "qgraf"
    doc.install Dir["*.pdf"]
    doc.install "example"
  end

  def caveats; <<-EOS.undent
    Documents and example files have been copied to:
      #{doc}
    EOS
  end
end

