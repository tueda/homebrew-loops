require File.expand_path("Library/mma_lib", __dir__)

class MmaPackageX < Formula
  desc "Package to get compact analytic expressions for loop integrals"
  homepage "https://packagex.hepforge.org/"
  url "http://www.hepforge.org/archive/packagex/X-2.1.1.zip"
  sha256 "317a6cebb04448b758111fe927a9f29e6b041e6ba18979df7ed675427d20a406"

  def install
    mma_pkg_wrapper("X.m", ["Kernel", "Documentation"] + Dir["*.m"])
  end

  def caveats; <<~EOS
    #{mmapath_message}
  EOS
  end

  test do
  end
end
