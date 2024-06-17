class Qgraf < Formula
  desc "Computer program to generate Feynman diagrams"
  homepage "http://cfif.ist.utl.pt/~paulo/qgraf.html"
  url "http://anonymous:anonymous@qgraf.tecnico.ulisboa.pt/links/qgraf-3.6.8.tgz"
  sha256 "bfb98cd041863ea8063ba4806a73a30e6d2fff55502a010408173b0c1786b829"

  option "without-maxdeg20", "Don't extend the maximum vertex degree to 20"

  depends_on "gcc" # for gfortran

  def install
    inreplace "qgraf-#{version}.f08", "maxdeg=8", "maxdeg=20" if build.with? "maxdeg20"
    system "gfortran", "-o", "qgraf", "qgraf-#{version}.f08"
    Dir.mkdir("example")
    cp ["array.sty", "form.sty", "phi3", "qcd", "qed", "qedx", "qgraf.dat", "sum.sty"], "example"
    bin.install "qgraf"
    doc.install Dir["*.pdf"]
    doc.install "example"
  end

  def caveats
    <<~EOS
      Documents and example files have been copied to:
        #{doc}
    EOS
  end

  test do
    File.symlink(doc/"example"/"form.sty", testpath/"form.sty")
    if build.with? "maxdeg20"
      (testpath/"qcd").write <<~EOS
        [ quark, antiquark, - ]
        [ gluon, gluon, + ]
        [ ghost, antighost, - ]
        [ phi, phi, + ]

        [ antiquark, quark, gluon ]
        [ gluon, gluon, gluon ]
        [ gluon, gluon, gluon, gluon ]
        [ antighost, ghost, gluon ]

        % test for maxdeg
        [ phi, phi, phi ]
        [ phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi,
          phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi,
          phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi,
          phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi,
          phi, phi, phi, phi ]
        [ phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi, phi,
          phi, phi, phi, phi, phi ]
      EOS
    else
      File.symlink(doc/"example"/"qcd", testpath/"qcd")
    end
    (testpath/"qgraf.dat").write <<~EOS
      output = 'qgraf.out';
      style  = 'form.sty';
      model  = 'qcd';
      in     = gluon;
      out    = gluon;
      loops  = 3;
      loop_momentum = ;
      options =;
    EOS
    assert_match " 2829 connected diagrams", pipe_output("#{bin}/qgraf")
  end
end
