class FormHarmpol < Formula
  desc "FORM procedures and tables for the manipulation of HPLs"
  homepage "http://www.nikhef.nl/~form/maindir/packages/harmpol/harmpol.html"
  url "http://www.nikhef.nl/~form/maindir/packages/harmpol/harmpol.h"
  version "20070215"
  sha256 "79e506fc20ce2b2c955dd5d616b5968da2111b1f27b54ac1257c8e8d468aad9f"

  depends_on "form" => :run
  depends_on "form-summer"

  resource "harmpolex" do
    url "http://www.nikhef.nl/~form/maindir/packages/harmpol/harmpolex.tar.gz"
    sha256 "c7c7465e331039ccfc9a7b4bdf7712549ec02134026dd6ac95697030e72aec86"
  end

  resource "htable7" do
    url "http://www.nikhef.nl/~form/maindir/packages/harmpol/htable7.prc.gz"
    sha256 "046f316522621e047ea7f773533318a05937bcbf81b736c4099caec330ab22da"
  end

  resource "htable8" do
    url "http://www.nikhef.nl/~form/maindir/packages/harmpol/htable8.prc.gz"
    sha256 "94a383f0c8f4dfe8b855f43739eb3243d3365278b31393bdd087392679d4be0a"
  end

  resource "htable9" do
    url "http://www.nikhef.nl/~form/maindir/packages/harmpol/htable9.prc.gz"
    sha256 "3b082b8e70ec61a8d621fdfdc571db4dcfc30872982100e74fda06dc8d5bf4f6"
  end

  def install
    (share/"form").install "harmpol.h"

    resource("harmpolex").stage do
      (share/"form/harmpol").install Dir.glob(["*.frm"])
    end

    resource("htable7").stage do
      (share/"form").install "htable7.prc"
    end

    resource("htable8").stage do
      (share/"form").install "htable8.prc"
    end

    resource("htable9").stage do
      (share/"form").install "htable9.prc"
    end
  end

  def caveats; <<-EOS.undent
    Add the following line to your .bashrc or .zshrc:
      export FORMPATH="$FORMPATH:$(brew --prefix)/share/form"
    EOS
  end

  test do
    result = <<-EOS

   [1,1,1,1,1] = 0;

    EOS
    assert_equal result,
      pipe_output("form -q -p #{HOMEBREW_PREFIX/"share/form"}" \
                  " #{share/"form/harmpol/hcheck.frm"}").lines.last(3).join
  end
end
