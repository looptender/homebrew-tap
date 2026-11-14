#!/bin/bash
set -euo pipefail

# This fixture installs/uninstalls packages only on an ephemeral hosted runner.
# Refuse before the first Homebrew command on a developer's machine.
if [[ "${GITHUB_ACTIONS:-}" != true || "${RUNNER_ENVIRONMENT:-}" != github-hosted ||
      "${GITHUB_REPOSITORY:-}" != looptender/homebrew-tap ||
      "${GITHUB_WORKSPACE:-}" != /Users/runner/work/* ]]; then
  echo 'Package fixture requires the disposable GitHub-hosted macOS workflow.' >&2
  exit 2
fi
case "${1:-}" in
  fresh|alias|upgrade|legacy-upgrade) mode="$1" ;;
  *) echo 'Expected fresh, alias, upgrade or legacy-upgrade.' >&2; exit 2 ;;
esac

brew --version
uname -m

baseline=cb3ff9ebdd4a4534042ef5bd070ad7c65b1d2c1e
head="$(git -C "$GITHUB_WORKSPACE" rev-parse HEAD)"
repository="$(brew --repository)"
prefix="$(brew --prefix)"
cellar="$(brew --cellar)"
canonical=looptender/tap/looptender

make_tap() {
  local owner="$1" ref="$2" destination="$repository/Library/Taps/$1/homebrew-tap"
  test ! -e "$destination"
  mkdir -p "$(dirname "$destination")"
  git clone --quiet --no-hardlinks "$GITHUB_WORKSPACE" "$destination"
  git -C "$destination" checkout --quiet --detach "$ref"
}

check_receipt() {
  python3 - "$1" "$2" <<'PY'
import json, sys
with open(sys.argv[1]) as stream:
    receipt = json.load(stream)
assert receipt['source']['tap'] == sys.argv[2], receipt['source']
PY
}

case "$mode" in
  fresh|alias)
    make_tap looptender "$head"
    requested="$canonical"
    if [[ "$mode" == alias ]]; then
      # Homebrew 7 requires canonical-item trust before resolving an old name.
      brew trust --formula "$canonical"
      requested=looptender/tap/keepgoing
    fi
    brew install "$requested"
    ;;
  upgrade|legacy-upgrade)
    owner=looptender
    if [[ "$mode" == legacy-upgrade ]]; then owner=connorburgess; fi
    make_tap "$owner" "$baseline"
    brew install "$owner/tap/keepgoing"
    old_receipt="$cellar/keepgoing/0.2.0/INSTALL_RECEIPT.json"
    check_receipt "$old_receipt" "$owner/tap"
    test ! -e "$prefix/bin/looptender"
    if [[ "$mode" == upgrade ]]; then
      git -C "$repository/Library/Taps/looptender/homebrew-tap" checkout --quiet --detach "$head"
    else
      make_tap looptender "$head"
      brew trust --formula "$canonical"
      before="$(shasum -a 256 "$old_receipt")"
      # Homebrew 7.0.12 prints the owner refusal but returns zero. Require
      # its specific diagnostic AND unchanged receipt/Cellar state below.
      migration_status=0
      brew migrate looptender/tap/keepgoing > "$RUNNER_TEMP/migration-refusal.log" 2>&1 || migration_status=$?
      echo "Unforced migration exit status: $migration_status"
      cat "$RUNNER_TEMP/migration-refusal.log"
      grep -F 'installed from connorburgess/tap' "$RUNNER_TEMP/migration-refusal.log"
      test "$(shasum -a 256 "$old_receipt")" = "$before"
      test ! -e "$cellar/looptender"
      # Only this disposable fixture opts into the cross-owner migration.
      brew migrate --force looptender/tap/keepgoing
    fi
    brew upgrade "$canonical"
    ;;
esac

brew test "$canonical"
check_receipt "$cellar/looptender/0.2.0_1/INSTALL_RECEIPT.json" looptender/tap
package_prefix="$(brew --prefix "$canonical")"
test -L "$package_prefix/bin/looptender"
test "$(readlink "$package_prefix/bin/looptender")" = keepgoing
test "$("$prefix/bin/looptender" version)" = v0.2.0
test "$("$prefix/bin/keepgoing" version)" = v0.2.0
if [[ "$mode" == fresh ]]; then brew audit --strict --online "$canonical"; fi
brew uninstall --force "$canonical"
for executable in looptender keepgoing; do
  test ! -e "$prefix/bin/$executable"
  test ! -L "$prefix/bin/$executable"
done
