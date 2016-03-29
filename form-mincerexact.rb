class FormMincerexact < Formula
  desc "Mincer without power expansions in ep"
  homepage "http://www.nikhef.nl/~form/maindir/packages/mincer/mincer.html"
  url "http://www.nikhef.nl/~form/maindir/packages/mincer/mincerex.tgz"
  version "20120323"
  sha256 "bc83ca9e11517c93fbcc7d71445ab1616ff2002d84902eb452cca5f7cc6dc076"

  depends_on "form" => :run

  def install
    (share/"form").install "minceex.h"
    (share/"form/minceex").install Dir.glob(["*.frm", "*.h", "*.prc", "*.log"])
  end

  def caveats; <<-EOS.undent
    Add the following line to your .bashrc or .zshrc:
      export FORMPATH="$FORMPATH:$(brew --prefix)/share/form"
    EOS
  end

  test do
    (testpath/"test.frm").write <<-EOS.undent
      Off stats;
      Off finalstats;
      Off totalsize;
      Format nospaces;
      Format 80;
      #include minceex.h
      .global
      #define TOPO "no"
      L F = 1/<p1.p1>/.../<p8.p8>*p1.p8*p2.p7;
      #call integral(`TOPO',0)
      P;
      .end
    EOS
    result = <<-EOS

   F=
      GschemeConstants(0,0)*BasicT1Integral*rat(2*ep^2-ep,4)+GschemeConstants(0
      ,0)^2*GschemeConstants(1,0)*rat(6*ep^2-6*ep+1,8*ep^2)+GschemeConstants(0,
      0)^2*GschemeConstants(2,0)*rat(-12*ep^2+10*ep-1,12*ep^2)+
      GschemeConstants(0,0)*GschemeConstants(1,0)*GschemeConstants(2,0)*rat(-2*
      ep^3+6*ep^2-4*ep+1,48*ep^3-24*ep^2);
    EOS
    assert_equal result,
      pipe_output("form -q -p #{HOMEBREW_PREFIX/"share/form"}" \
                  " test.frm").lines.last(8).join
  end
end
