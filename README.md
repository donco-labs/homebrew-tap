# donco-labs/homebrew-tap

Homebrew tap for [sparkling-clean](https://github.com/donco-labs/sparkling-clean) —
a macOS disk triage toolkit.

```bash
brew tap donco-labs/tap
brew install sparkling-clean
```

Then:

```bash
sparkling-clean report          # read-only diagnostic
sparkling-clean check           # health guard, exit 0/1/2
sparkling-clean install-guard   # launchd watchdog, every 2h
```
