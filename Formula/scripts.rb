class Scripts < Formula
  desc "afeldman personal utility scripts (encryption, certs, git, dev tools, ...)"
  homepage "https://github.com/afeldman/scripts"
  version "0.1.0"
  url "https://github.com/afeldman/scripts/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "e925cacaceaacdc673f058d33b799c978635bdd709a39e31661d30acd824e065"

  SKIP = %w[install.sh release.sh CLAUDE.md].freeze

  def install
    Dir["*"]
      .select { |f| File.file?(f) }
      .reject { |f| SKIP.include?(File.basename(f)) }
      .reject { |f| f.end_with?(".md", ".rb", ".sh") }
      .select { |f| File.read(f).start_with?("#!") rescue false }
      .each   { |f| bin.install f }
  end

  test do
    assert_predicate bin/"githelper", :executable?
  end
end
