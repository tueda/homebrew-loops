class FormMincer < Formula
  desc "Package for massless three loop propagator-like integrals"
  homepage "http://www.nikhef.nl/~form/maindir/packages/mincer/mincer.html"
  url "http://www.nikhef.nl/~form/maindir/packages/mincer/mincer.h"
  version "20070206"
  sha256 "a79a0f6319b353c55a11f7f17e8b3456a8f0eac4689231bc061df198d96b9887"

  depends_on "form" => :run

  resource "mincer2" do
    url "http://www.nikhef.nl/~form/maindir/packages/mincer/mincer2.h"
    sha256 "659a17f08eaa0349f61321e2c70ef77269e36f2d7c7a91e2923209ae2d1daf4b"
  end

  resource "testmincer1" do
    url "http://www.nikhef.nl/~form/maindir/packages/mincer/testmincer1.frm"
    sha256 "0f98ddeaeedb8c0c778332255fbb8c86f7aae6377ebc44ee202e27623d1a9e54"
  end

  resource "testmincer2" do
    url "http://www.nikhef.nl/~form/maindir/packages/mincer/testmincer2.frm"
    sha256 "417d480fef6d5f5f1d6358425a54cd42344762d592d94b72184d6df93155cd14"
  end

  def install
    (share/"form").install "mincer.h"

    resource("mincer2").stage do
      (share/"form").install "mincer2.h"
    end

    resource("testmincer1").stage do
      (share/"form/mincer").install "testmincer1.frm"
    end

    resource("testmincer2").stage do
      (share/"form/mincer").install "testmincer2.frm"
    end
  end

  def caveats; <<-EOS.undent
    Add the following line to your .bashrc or .zshrc:
      export FORMPATH="$FORMPATH:$(brew --prefix)/share/form"
    EOS
  end

  test do
    result = <<-EOS

   F =
       - 6695/5184 - 1/48*ep^-3 + 41/288*ep^-2 - 1541/6912*ep^-1 + 5/4*z5 - 1/
      6*z3;

    EOS
    assert_equal result,
      pipe_output("form -q -p #{HOMEBREW_PREFIX/"share/form"}" \
                  " #{share/"form/mincer/testmincer1.frm"}").lines.last(5).join
  end
end
