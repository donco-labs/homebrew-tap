# donco-labs/homebrew-tap

Homebrew tap for [plimsoll](https://github.com/donco-labs/plimsoll) —
a macOS disk triage toolkit.

## Install

```bash
brew tap donco-labs/tap
brew trust --formula donco-labs/tap/plimsoll
brew install plimsoll
```

Homebrew refuses to load formulae from third-party taps until you trust them.
A formula is arbitrary Ruby that runs on install, so read
[Formula/plimsoll.rb](Formula/plimsoll.rb) first — it is about
thirty lines and does nothing but copy scripts into `libexec`.

`--formula` trusts only this formula. `brew trust donco-labs/tap` would trust
every formula this tap ever gains, including ones added later.

## Upgrading from sparkling-clean

This tap's formula was called `sparkling-clean` through v0.7.1. Trust is keyed to
the formula *name*, so having trusted `sparkling-clean` is not enough — `brew
upgrade` will stop with `Refusing to load formula donco-labs/tap/plimsoll from
untrusted tap` until you trust the new name:

```bash
brew update
brew trust --formula donco-labs/tap/plimsoll
brew upgrade
plimsoll install-guard
```

`formula_renames.json` then migrates the install rather than stranding it. The
last line moves the toolkit's own artifacts.

That unloads the old launchd guard before the new one loads — two guards on one
machine notify twice and split their de-dup state — and moves the state
directory, health history included.

## Use

```bash
plimsoll report          # read-only diagnostic, ends in a verdict
plimsoll check           # health guard, exit 0 ok / 1 warn / 2 crit
plimsoll install-guard   # launchd watchdog, checks every 2h
```

Read-only diagnostics need no special privileges. Applying Time Machine
exclusions needs Full Disk Access; snapshot thinning needs `sudo`. Every
destructive path is dry-run until you pass `--apply`.
