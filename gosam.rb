class Gosam < Formula
  desc "Automated calculation of one-loop amplitudes"
  homepage "http://gosam.hepforge.org/"
  url "http://www.hepforge.org/archive/gosam/gosam-2.0.4-6d9f1cba.tar.gz"
  sha256 "faf621c70f66d9dffc16ac5cce66258067f39f686d722a4867eeb759fcde4f44"

  head do
    url "http://gosam.hepforge.org/svn/branches/gosam-2.0", :using => :svn
  end

  depends_on "gosam-contrib"
  depends_on "python@2"
  depends_on "qgraf"
  depends_on "tueda/form/form"

  def install
    system "./setup.py", "install", "--prefix=#{prefix}", "-f"
  end

  test do
  end
end
