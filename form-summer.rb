class FormSummer < Formula
  desc "Package for harmonic sums"
  homepage "http://www.nikhef.nl/~form/maindir/packages/summer/summer.html"
  url "http://www.nikhef.nl/~form/maindir/packages/summer/summer.h.gz"
  version "20140325"
  sha256 "6699d592e92804dde143422d396d4eb7118129f7be38180e40d9cd1a22b8d71f"

  depends_on "form" => :run

  resource "summerex" do
    url "http://www.nikhef.nl/~form/maindir/packages/summer/summerex.tar.gz"
    sha256 "0bde4a7c1dcd7a6e3b166e1ad3cf0d79ae8be197739cd341a9a7e7e6909a8268"
  end

  resource "table7" do
    url "http://www.nikhef.nl/~form/maindir/packages/summer/table7.prc.gz"
    sha256 "4887b530f7f8fa63238598154cb52b09919b5edcbb0d92d8ff8108a8ea6e1f62"
  end

  resource "table8" do
    url "http://www.nikhef.nl/~form/maindir/packages/summer/table8.prc.gz"
    sha256 "0d955c6e4ff9096baa84da9877ab382d5535b55d316c2fad954ab684275f80bc"
  end

  resource "table9" do
    url "http://www.nikhef.nl/~form/maindir/packages/summer/table9.prc.gz"
    sha256 "36f300878564abfcf55fef831e19968245d6ce2903f35284664297e3d2ce86e8"
  end

  def install
    (share/"form").install "summer.h"

    resource("summerex").stage do
      (share/"form/summer").install Dir.glob(["*.frm", "*.h"])
    end

    resource("table7").stage do
      (share/"form").install "table7.prc"
    end

    resource("table8").stage do
      (share/"form").install "table8.prc"
    end

    resource("table9").stage do
      (share/"form").install "table9.prc"
    end
  end

  def caveats; <<-EOS.undent
    Add the following line to your .bashrc or .zshrc:
      export FORMPATH="$FORMPATH:$(brew --prefix)/share/form"
    EOS
  end

  test do
    result = <<-EOS

   F = 0;

    EOS
    assert_equal result,
      pipe_output("form -q -p #{HOMEBREW_PREFIX/"share/form"}" \
                  " #{share/"form/summer/test2.frm"}").lines.last(3).join
  end
end
