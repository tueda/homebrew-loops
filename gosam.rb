class Gosam < Formula
  desc "The package GoSam allows for the automated calculation of one-loop" \
       "amplitudes for multi-particle processes in renormalizable quantum" \
       "field theories"
  homepage "http://gosam.hepforge.org/"
  url "http://www.hepforge.org/archive/gosam/gosam-2.0.tar.gz"
  sha256 "530a01aa114f17f598b49767499d54a1bbcbe61e5b9ea721017d849bfde5836b"
  version "2.0.2.2"

  head do
    url "http://gosam.hepforge.org/svn/branches/gosam-2.0", :using => :svn
  end

  depends_on "form"
  depends_on "qgraf"
  depends_on "gosam-contrib"
  depends_on :python

  def install
    system "./setup.py", "install", "--prefix=#{prefix}", "-f"
  end
end
