# Package rename validation

## Mapping and release boundary

`Formula/looptender.rb` and class `Looptender` are the canonical formula. `formula_renames.json` maps the unqualified old name `keepgoing` to `looptender`, as required for a same-tap rename. The rename metadata also resolves legacy install requests to that formula. Homebrew audit rejects an alias and rename entry for the same old name, so there is no duplicate `Aliases/keepgoing` file. Homebrew 7 requires explicitly trusting the canonical formula before resolving an old-name install; the fixture grants only that formula-scoped trust.

The unchanged v0.2.0 archives contain `keepgoing`. Revision 1 installs that binary and adds a relative `looptender` executable symlink. The revision makes the existing release outdated for upgrade purposes; renaming a receipt alone does not add the executable symlink. Tests check both executable names and their common real path. License files, archive names and checksums remain unchanged.

Homebrew's `Formula#oldnames` uses the reverse rename mapping. `Formulary.tap_formula_name_type` resolves the old name through that mapping. `Migrator#from_same_tap_user?` checks installed receipt ownership; a `connorburgess/tap` receipt does not become a `looptender/tap` receipt merely because GitHub redirects a repository URL. No `tap_migrations.json` is added to the shared transferred tree.

References: [formula renaming](https://docs.brew.sh/Rename-A-Formula), [tap migration](https://docs.brew.sh/Migrating-A-Formula-To-A-Tap), and Homebrew [migrator](https://github.com/Homebrew/brew/blob/main/Library/Homebrew/migrator.rb), [formulary](https://github.com/Homebrew/brew/blob/main/Library/Homebrew/formulary.rb) and [formula](https://github.com/Homebrew/brew/blob/main/Library/Homebrew/formula.rb) implementations. Preparation also inspected installed Homebrew source at commit `bf464f57275cae0be106b43d190c98564ac59b0e`, without running its package manager.

## Disposable hosted fixtures

The workflow creates a separate GitHub-hosted macOS arm64 runner for each scenario. `scripts/check-package.sh` refuses developer-machine execution before any Homebrew command. It requires the hosted-runner environment, repository identity and runner workspace path. The workflow checks out full history so the old formula comes from the exact merged pre-rename tap commit `cb3ff9ebdd4a4534042ef5bd070ad7c65b1d2c1e`.

| Scenario | Exercise |
| --- | --- |
| `fresh` | Install the canonical formula, test both executables, check the new receipt, run strict online audit, uninstall and check both command links are gone. |
| `alias` | Trust only the canonical formula, then fresh install through `looptender/tap/keepgoing`, then verify the same canonical package, receipt, executable links and uninstall behavior. |
| `upgrade` | Install actual v0.2.0 from the pre-rename formula under `looptender/tap`, verify its receipt and absent new command, switch the tap to the tested head, upgrade and assert the new revision/receipt, both commands and uninstall. |
| `legacy-upgrade` | Install actual v0.2.0 under `connorburgess/tap`; assert cross-owner migration is refused without changing the receipt; trust only the canonical formula, explicitly force migration only on this disposable fixture, upgrade to revision 1, then verify canonical receipt, commands and uninstall. |

All scenarios use real published archives and Homebrew-created receipts, not fabricated receipt JSON. They invoke version/help-only formula tests and no providers, loops or services. The forced legacy migration is fixture code, not an endorsed blanket command for an owner's installation. The script checks migration refusal because Homebrew's dry-run path does not instantiate the migrator and therefore cannot prove its owner guard.

## Evidence and limits

Preparation validates Ruby/shell/YAML/JSON syntax, alias resolution on disk, unchanged published asset URLs/checksums and the developer-machine refusal guard. These checks do not establish a successful installation or upgrade. Hosted fixtures and strict audit remain unrun until the reviewed head is authorized for push/CI. No owner Homebrew checkout, receipt or executable was changed.

Native Intel macOS and Linux installation/upgrade, pinned or unlinked kegs, colliding preexisting `looptender` packages, custom prefixes and arbitrary old receipts are not covered. Existing configurations, services, plugins and running loops are not migrated. No new CLI release or live rollout is included.
