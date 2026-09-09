class SparklingClean < Formula
  desc "macOS disk triage: diagnose disk-pressure freezes and reclaim space safely"
  homepage "https://github.com/donco-labs/sparkling-clean"
  url "https://github.com/donco-labs/sparkling-clean/archive/refs/tags/v0.4.2.tar.gz"
  sha256 "91ade6cb3a4123e99ac09ab02609887c5dd891f0818b33e1ab223733934bd6bc"
  license "MIT"
  head "https://github.com/donco-labs/sparkling-clean.git", branch: "main"

  # No dependencies on purpose. Everything is zsh plus tools already on macOS
  # (diskutil, tmutil, defaults, launchctl). smartctl is optional — the SSD
  # health section degrades to a note when smartmontools is absent.
  depends_on :macos

  def install
    # Mirror the repo layout: the LaunchAgent template substitutes
    # __SC_ROOT__/bin/disk-guard.zsh, so the scripts must live under <root>/bin.
    (libexec/"bin").install Dir["bin/*"]
    (libexec/"launchd").install Dir["launchd/*"]
    doc.install Dir["docs/*.md"], "README.md"
    (libexec/"extra").install Dir["extra/*"]
    bin.install_symlink libexec/"bin/sparkling-clean"
  end

  def caveats
    <<~EOS
      Read-only diagnostics work with no extra privileges:
        sparkling-clean report
        sparkling-clean check

      Applying Time Machine exclusions needs Full Disk Access. Grant it to your
      terminal in System Settings > Privacy & Security > Full Disk Access, then:
        sparkling-clean tm-exclude --apply

      Background watchdog (checks every 2h, notifies only on a level change):
        sparkling-clean install-guard

      Menu bar, via SwiftBar (quote the path; create the folder first):
        brew install --cask swiftbar
        mkdir -p "$HOME/Library/Application Support/SwiftBarPlugins"
        ln -sf "#{opt_libexec}/extra/swiftbar/sparkling-clean.10m.sh" \
               "$HOME/Library/Application Support/SwiftBarPlugins/"
        open -a SwiftBar

      Point SwiftBar at that folder on first launch. Do NOT use
      ~/Library/Application Support/SwiftBar -- that is SwiftBar's own state
      directory, and it loads its diagnostics file there as a second, broken
      plugin showing "?" in the menu bar.
    EOS
  end

  test do
    # Dispatcher resolves its siblings through the bin symlink.
    assert_match "macOS disk triage", shell_output("#{bin}/sparkling-clean --help")

    # The guard must emit parseable JSON and a valid level. Exit is 0/1/2 by
    # design, so tolerate non-zero.
    require "json"
    out = shell_output("#{bin}/sparkling-clean check --json", 1)
    out = shell_output("#{bin}/sparkling-clean check --json") if out.strip.empty?
    j = JSON.parse(out)
    assert_includes %w[OK WARN CRIT], j["level"]
    assert !j["subject"].to_s.empty?, "guard reported no subject"
    assert j["checks"].length >= 4, "expected at least four checks"

    # Destructive paths must be dry-run without --apply.
    refute_match(/^  RUN  /, shell_output("#{bin}/sparkling-clean reclaim"))
  end
end
