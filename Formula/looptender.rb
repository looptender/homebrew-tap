class Looptender < Formula
  desc "Keep long-running coding-agent loops going"
  homepage "https://github.com/looptender/looptender"
  # The Sustainable Use License 1.0 is not on the SPDX list. v0.1.5 and every
  # earlier release are Apache-2.0.
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/looptender/looptender/releases/download/v0.3.0/keepgoing_0.3.0_darwin_arm64.tar.gz"
      sha256 "9755e8a66db19e87b14fa1c4eaed2ae33960cf62da93be888d9fa20bd0574cf4"
    end
    on_intel do
      url "https://github.com/looptender/looptender/releases/download/v0.3.0/keepgoing_0.3.0_darwin_amd64.tar.gz"
      sha256 "867b15d2a7628984b2faafbb8850e6f284ab2d6bebf2e5cbc462ad0ad5691d53"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/looptender/looptender/releases/download/v0.3.0/keepgoing_0.3.0_linux_arm64.tar.gz"
      sha256 "5c04f84edf767e8e9cddbc6fd1a26d169df8745d18682ea1fe9570f1286b658b"
    end
    on_intel do
      url "https://github.com/looptender/looptender/releases/download/v0.3.0/keepgoing_0.3.0_linux_amd64.tar.gz"
      sha256 "8787e5d32431f82679d51e090e5ac9e6b4597e5f61f44a5a0d760e03926eb7da"
    end
  end

  def install
    bin.install "keepgoing"
    bin.install_symlink "keepgoing" => "looptender"
    # LICENSE and README.md are installed as metafiles.
    prefix.install "LICENSING.md", "THIRD_PARTY_NOTICES", "LICENSES"
  end

  test do
    assert_match "v#{version}", shell_output("#{bin}/keepgoing version")
    assert_match "v#{version}", shell_output("#{bin}/looptender version")
    assert_equal (bin/"keepgoing").realpath, (bin/"looptender").realpath
    help = shell_output("#{bin}/keepgoing init --help 2>&1")
    assert_match "task-file", help
    assert_match "with-goal", help
    assert_match "max-sends", help
    assert_match "state-dir", shell_output("#{bin}/keepgoing timeline --help 2>&1")
    assert_match "private", shell_output("#{bin}/keepgoing goal show --help 2>&1")
    assert_match "registry", shell_output("#{bin}/keepgoing client status --help 2>&1")
    assert_match "thread", shell_output("#{bin}/keepgoing transfer preview --help 2>&1")
    assert_match "allow-changes", shell_output("#{bin}/keepgoing panel --help 2>&1")
    assert_path_exists prefix/"LICENSE"
    assert_path_exists prefix/"LICENSING.md"
    assert_path_exists prefix/"THIRD_PARTY_NOTICES"
    assert_path_exists prefix/"LICENSES/Apache-2.0.txt"
  end
end
