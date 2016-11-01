class MmaFormtracer < Formula
  desc "Mathematica Tracing Package Using FORM"
  homepage "https://arxiv.org/abs/1610.09331"
  url "https://raw.githubusercontent.com/FormTracer/FormTracer/1d0dee2bdf758a687670c234b24bf513f2fc22b4/FormTracer.zip"
  version "2.0.0"
  sha256 "0c7ef6d93a0eb4c9bfe1e4d4d6d0fc238951165376af3d82cbec7e62d64ef221"

  patch :DATA

  depends_on "form"

  def install
    installpath = share/"Mathematica"/"Applications"/"FormTracer-#{version}"

    marker = 'formExecutable="";(* is set automatically below, can be changed by DefineFormExecutable[path]*)'
    inreplace "FormTracer.m", marker, marker + "AppendTo[defaultFormExecutables, \"#{HOMEBREW_PREFIX}/bin/form\"];"

    installpath.install ["Documentation", "Examples", "Header", "FormTracer.m", "CHANGELOG", "PacletInfo.m"]

    (buildpath/"FormTracer.m").write <<-EOS.undent
      If[!MemberQ[$Path, "#{installpath}"],
        AppendTo[$Path, "#{installpath}"];
        PacletDirectoryAdd["#{installpath}"];
      ];
      Get["#{installpath/"FormTracer.m"}"]
    EOS
    (share/"Mathematica"/"Applications").install "FormTracer.m"
  end

  def caveats; <<-EOS.undent
    FormTracer.m has been installed to
      #{HOMEBREW_PREFIX}/share/Mathematica/Applications/FormTracer.m
    You can add it to your Mathematica $Path by adding a line
      AppendTo[$Path, "#{HOMEBREW_PREFIX}/share/Mathematica/Applications"]]
    to the file obtained by
      FileNameJoin[{$UserBaseDirectory, "Kernel", "init.m"}]
    Or run the following command in Mathematica:
      (Import["https://git.io/AppendPath.m"];AppendPath["#{HOMEBREW_PREFIX}/share/Mathematica/Applications"])
    EOS
  end

  test do
  end
end
__END__
diff --git a/FormTracer.m b/FormTracer.m
index c4e7c30..9342d22 100644
--- a/FormTracer.m
+++ b/FormTracer.m
@@ -381,6 +381,7 @@ Begin["`Private`"];
 
 (* ::Input::Initialization:: *)
 (*determine the FormTracer directory*)
+(*
 formTracerDirectory= If[DirectoryQ[FileNameJoin[{$UserBaseDirectory,"Applications","FormTracer"}]],
 (*installed in the user directory*)
 FileNameJoin[{$UserBaseDirectory,"Applications","FormTracer"}],
@@ -391,6 +392,12 @@ Message[FormTracer::formtracerdirectorynotfound];
 FileNameJoin[{$UserBaseDirectory,"Applications","FormTracer"}]
 ]
 ];
+*)
+formTracerDirectory = FindFile[FileNameJoin[{"Header", "special_color.h"}]];
+If[formTracerDirectory === $Failed,
+  Message[FormTracer::formtracerdirectorynotfound];
+];
+formTracerDirectory = FileNameJoin[Drop[FileNameSplit[formTracerDirectory], -2]];
 
 $FormTracerVersionNumber=Quiet[Check[Version/.List@@Import[FileNameJoin[{formTracerDirectory,"PacletInfo.m"}]],"0.0.0"]];
 {$FormTracerMainVersion,$FormTracerVersion,$FormTracerBuiltVersion}=First@StringReplace[$FormTracerVersionNumber,mV__~~"."~~v__~~"."~~bV__:>ToExpression/@{mV,v,bV}];
