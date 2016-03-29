class FormColor < Formula
  desc "Package for calculating color group coefficients"
  homepage "http://www.nikhef.nl/~form/maindir/packages/color/color.html"
  url "http://www.nikhef.nl/~form/maindir/packages/color/color.h"
  version "20090807"
  sha256 "616e225880fda51c5e1d37b8730a520b1994f05d70713e7e8b2fca2e2ab3fd00"

  depends_on "form" => :run

  resource "color" do
    url "http://www.nikhef.nl/~form/maindir/packages/color/color.tar.gz"
    sha256 "f648fd368a03c0d7237f40ed42768095d7cc84f47009af61ddc4d421392f46f5"
  end

  def install
    (share/"form").install "color.h"

    resource("color").stage do
      (share/"form/color").install Dir.glob(["*.frm", "*.prc"])
    end
  end

  def caveats; <<-EOS.undent
    Add the following line to your .bashrc or .zshrc:
      export FORMPATH="$FORMPATH:$(brew --prefix)/share/form"
    EOS
  end

  test do
    result = <<-EOS

   girth14 =
       + 1/648*NA*cA^7
       - 8/15*d444(cOlpA1,cOlpA2,cOlpA3)*cA
       + 16/9*d644(cOlpA1,cOlpA2,cOlpA3)
      ;

    EOS
    assert_equal result,
      pipe_output("form -q -p #{HOMEBREW_PREFIX/"share/form"}" \
                  " #{share/"form/color/tloop.frm"}").lines.last(7).join
  end
end
