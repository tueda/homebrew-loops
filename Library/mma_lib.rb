# typed: false
# frozen_string_literal: true

require "formula"

class Formula # rubocop:disable Style/Documentation
  # The shared Mathematica application path.
  # Example: /usr/local/share/Mathematica/Applications
  def mma_app_path
    HOMEBREW_PREFIX/"share"/"Mathematica"/"Applications"
  end

  # The application path for each formula. Linked to `mma_app_path`.
  # Example: /usr/local/Cellar/mma-foo/0.1/share/Mathematica/Applications
  def mma_pkg_app_path
    share/"Mathematica"/"Applications"
  end

  # The private directory under the shared application path for each formula.
  # Example: /usr/local/Cellar/mma-foo/0.1/share/Mathematica/Applications/mma-foo-0.1
  def mma_pkg_private_path
    mma_pkg_app_path/"#{name}-#{version}"
  end

  # Create a wrapper package file and install the library.
  def mma_pkg_wrapper(main_file, other_files = [], prolog = "")
    private_path = mma_pkg_private_path

    files_to_be_installed = [*other_files]
    if File.exist?(main_file)
      files_to_be_installed += [main_file]
      entry_point = main_file
    else
      entry_point = "#{File.basename(main_file, ".*")}`"
    end

    private_path.install files_to_be_installed

    (buildpath/main_file).write <<~EOS
      #{prolog}
      If[!MemberQ[$Path, "#{private_path}"],
        AppendTo[$Path, "#{private_path}"];
        PacletDirectoryAdd["#{private_path}"];
      ];
      Get["#{entry_point}", Path -> "#{private_path}"]
    EOS

    mma_pkg_app_path.install main_file
  end

  # $Path message for "caveats".
  def mmapath_message
    s = <<~EOS
      Add the following line
        AppendTo[$Path, "#{mma_app_path}"]
      to the file printed by
        FileNameJoin[{$UserBaseDirectory, "Kernel", "init.m"}]
      This can also be done by running the following command:
        (Import["https://git.io/AppendPath.m"]; AppendPath["#{mma_app_path}"])
    EOS
    s.chomp
  end

  # Find Mathematica and put it to $HOMEBREW_MATH.
  def env_math
    s = ENV.fetch("HOMEBREW_MATH", nil)
    if s.blank?
      s = if OS.mac?
        "/Applications/Mathematica.app/Contents/MacOS/MathKernel"
      else
        "math"
      end
      ENV["HOMEBREW_MATH"] = s
    end
    if which s
      ohai "Mathematica path: #{s}"
    else
      onoe "Mathematica (#{s}) not found."
    end
  end
end

module MmaEnv # rubocop:disable Style/Documentation
  def wolframscript
    path = "wolframscript"
    odie "WolframScript not found" unless which path
    path
  end
end

ENV.extend MmaEnv
