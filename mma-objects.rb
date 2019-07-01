require File.expand_path("Library/mma_lib", __dir__)

class MmaObjects < Formula
  desc "Simple classes and objects, allowing to write object-oriented code"
  homepage "https://bitbucket.org/kmingulov/objects"
  url "https://bitbucket.org/kmingulov/objects/downloads/v1.31.zip"
  sha256 "aa83f074c2ddfe01009d6a78d2acfc78133eebc27c3ff1d7b04b79072d620205"

  head "https://bitbucket.org/kmingulov/objects.git"

  def install
    mma_pkg_wrapper("Objects.m", ["Documentation", "PacletInfo.m"])
  end

  def caveats; <<~EOS
    #{mmapath_message}
  EOS
  end

  test do
  end
end
