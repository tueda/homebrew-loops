require File.expand_path("../Library/mma_lib", __FILE__)

class MmaDream < Formula
  desc "Performing the high-precision calculation of the multiple sums"
  homepage "https://bitbucket.org/kmingulov/dream"
  url "https://bitbucket.org/kmingulov/dream/downloads/v2.0p.zip"
  sha256 "5cc128019be3252abe63f061ae4b90157e7296d32d42245b0177a1424526b5ab"

  head "https://bitbucket.org/kmingulov/dream.git"

  depends_on "mma-objects"

  def install
    mma_pkg_wrapper("DREAM.m", ["DREAM-v2.0p", "Documentation", "PacletInfo.m"])
  end

  def caveats; <<~EOS
    #{mmapath_message}
    EOS
  end

  test do
  end
end
