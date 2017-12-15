require "formula"

class Formula
  # The shared Mathematica application path.
  # Example: /usr/local/share/Mathematica/Applications
  def mma_app_path
    HOMEBREW_PREFIX/"share"/"Mathematica"/"Applications"
  end

  # The application path for each formula.
  # Example: /usr/local/Cellar/mma-foo/0.1/share/Mathematica/Applications
  def mma_pkg_app_path
    share/"Mathematica"/"Applications"
  end

  # Create a wrapper package file and install the library.
  def mma_pkg_wrapper(main_file, other_files=[])
    install_path = mma_pkg_app_path/"#{name}-#{version}"
    other_files = [*other_files]
    install_path.install [main_file] + [*other_files]
    (buildpath/main_file).write <<-EOS.undent
      If[!MemberQ[$Path, "#{install_path}"],
        AppendTo[$Path, "#{install_path}"];
        PacletDirectoryAdd["#{install_path}"];
      ];
      Get["#{main_file}", Path -> "#{install_path}"]
    EOS
    mma_pkg_app_path.install main_file
  end

  # $Path message for "caveats".
  def mmapath_message
    s = <<-EOS.undent
      Add the following line
        AppendTo[$Path, "#{mma_app_path}"]
      to the file printed by
        FileNameJoin[{$UserBaseDirectory, "Kernel", "init.m"}]
      Or run the following command:
        (Import["https://git.io/AppendPath.m"]; AppendPath["#{mma_app_path}"])
    EOS
    s.chomp
  end
end
