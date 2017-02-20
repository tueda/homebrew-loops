class Pstreams < Formula
  desc "POSIX Process Control in C++"
  homepage "https://pstreams.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/pstreams/pstreams/Release%201.0/pstreams-1.0.0.tar.gz"
  sha256 "7d24e35d26675a8d474afb45cd88694b0b9e39f01107e4ec200b1f7eb9d215f9"

  head do
    url "git://git.code.sf.net/p/pstreams/code"
  end

  def install
    system "make", "check"
    include.install "pstream.h"
  end

  test do
  end
end
