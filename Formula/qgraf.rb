class Qgraf < Formula
  desc "Computer program to generate Feynman diagrams"
  homepage "http://cefema-gt.tecnico.ulisboa.pt/~paulo/qgraf.html"
  url "http://anonymous:anonymous@qgraf.tecnico.ulisboa.pt/links/qgraf-3.6.10.tgz"
  sha256 "6d4b5c6eb97de1942b824d80b8cb454dd77667492d0001e3bf21e761c5702194"

  option "without-maxdeg20", "Don't extend the maximum vertex degree to 20"

  depends_on "gcc@14" => :build # for gfortran

  fails_with :gcc do
    version "15"
    cause "gfortran 15 leads to a runtime error showing only 'could not be found'"
  end

  def install
    inreplace "qgraf-#{version}.f08", "maxdeg=8", "maxdeg=20" if build.with? "maxdeg20"
    system Formula["gcc@14"].opt_bin/"gfortran-14", "-o", "qgraf", "qgraf-#{version}.f08"
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
