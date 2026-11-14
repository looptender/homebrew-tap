# Looptender Homebrew tap

```sh
brew install looptender/tap/looptender
```

Installs [looptender](https://github.com/looptender/looptender), which keeps long-running coding-agent loops going. This formula packages the published v0.2.0 archives for macOS and Linux and verifies their SHA-256 checksums. That release contains the `keepgoing` executable; formula revision 1 adds `looptender` as a symlink to the same executable. Both commands report the released version and provide the same behavior.

The old formula name resolves through `formula_renames.json`, which records the same-tap package rename. On Homebrew 7, trust the canonical formula before installing through the old name:

```sh
brew trust --formula looptender/tap/looptender
brew install looptender/tap/keepgoing
```

There is no duplicate formula alias entry. The revision increment ensures an existing v0.2.0 installation can receive the executable symlink when upgraded.

## Existing installations

A formula rename, executable symlink and installed tap receipt serve different purposes. The GitHub repository transfer preserves old download/Git redirects, but does not rewrite an installed `connorburgess/tap` receipt. Homebrew normally refuses migrating a renamed formula across different tap owners without an explicit override. No automatic cross-tap mapping is included here.

The disposable CI fixtures cover fresh installs under both formula names, an upgrade from the canonical tap's old formula, and the legacy-owner refusal followed by an explicit fixture-only migration. See [validation details](docs/validation.md). All four scenarios passed with Homebrew 7.0.12 on macOS 15 arm64; the validation guide records the exact head, base and run. Do not apply the fixture's forced migration to an existing installation without inspecting its receipt and conflicts first.

This packaging change does not update running loops, services, plugin settings or command paths saved outside Homebrew. No new CLI release is implied.
