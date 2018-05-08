class Gosam < Formula
  desc "Automated calculation of one-loop amplitudes"
  homepage "http://gosam.hepforge.org/"
  url "http://www.hepforge.org/archive/gosam/gosam-2.0.tar.gz"
  version "2.0.2.2"
  sha256 "530a01aa114f17f598b49767499d54a1bbcbe61e5b9ea721017d849bfde5836b"

  head do
    url "http://gosam.hepforge.org/svn/branches/gosam-2.0", :using => :svn
  end

  depends_on "tueda/form/form"
  depends_on "qgraf"
  depends_on "gosam-contrib"
  depends_on "python@2"

  def install
    system "./setup.py", "install", "--prefix=#{prefix}", "-f"
  end

  test do
  end
end
