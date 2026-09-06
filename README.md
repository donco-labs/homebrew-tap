# donco-labs/homebrew-tap

Homebrew tap for [sparkling-clean](https://github.com/donco-labs/sparkling-clean) —
a macOS disk triage toolkit.

## Install

```bash
brew tap donco-labs/tap
brew trust --formula donco-labs/tap/sparkling-clean
brew install sparkling-clean
```

Homebrew 6.0 refuses to load formulae from third-party taps until you trust them.
A formula is arbitrary Ruby that runs on install, so read
[Formula/sparkling-clean.rb](Formula/sparkling-clean.rb) first — it is about
thirty lines and does nothing but copy scripts into `libexec`.

`--formula` trusts only this formula. `brew trust donco-labs/tap` would trust
every formula this tap ever gains, including ones added later.

## Use

```bash
sparkling-clean report          # read-only diagnostic, ends in a verdict
sparkling-clean check           # health guard, exit 0 ok / 1 warn / 2 crit
sparkling-clean install-guard   # launchd watchdog, checks every 2h
```

Read-only diagnostics need no special privileges. Applying Time Machine
exclusions needs Full Disk Access; snapshot thinning needs `sudo`. Every
destructive path is dry-run until you pass `--apply`.
