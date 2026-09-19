class Plimsoll < Formula
  desc "macOS disk triage: diagnose disk-pressure freezes and reclaim space safely"
  homepage "https://github.com/donco-labs/plimsoll"
  url "https://github.com/donco-labs/plimsoll/archive/refs/tags/v0.8.1.tar.gz"
  sha256 "cd012157e67c05fec1219f38f90e2bf80c830cb32cca9e34304b20656d0a2a96"
  license "MIT"
  head "https://github.com/donco-labs/plimsoll.git", branch: "main"

  # No dependencies on purpose. Everything is zsh plus tools already on macOS
  # (diskutil, tmutil, defaults, launchctl). smartctl is optional — the SSD
  # health section degrades to a note when smartmontools is absent.
  depends_on :macos

  def install
    # Mirror the repo layout: the LaunchAgent template substitutes
    # __PL_ROOT__/bin/disk-guard.zsh, so the scripts must live under <root>/bin.
    (libexec/"bin").install Dir["bin/*"]
    (libexec/"launchd").install Dir["launchd/*"]
    doc.install Dir["docs/*.md"], "README.md"
    (libexec/"extra").install Dir["extra/*"]
    bin.install_symlink libexec/"bin/plimsoll"
  end

  def caveats
    <<~EOS
      Upgrading from sparkling-clean? Run this once. It unloads the old guard,
      moves ~/.local/state/sparkling-clean (health history included) to
      ~/.local/state/plimsoll, and repoints the SwiftBar symlink:
        plimsoll install-guard

      Read-only diagnostics work with no extra privileges:
        plimsoll report
        plimsoll check

      Applying Time Machine exclusions needs Full Disk Access. Grant it to your
      terminal in System Settings > Privacy & Security > Full Disk Access, then:
        plimsoll tm-exclude --apply

      Background watchdog (checks every 2h, notifies only on a level change):
        plimsoll install-guard

      Menu bar, via SwiftBar (quote the path; create the folder first):
        brew install --cask swiftbar
        mkdir -p "$HOME/Library/Application Support/SwiftBarPlugins"
        ln -sf "#{opt_libexec}/extra/swiftbar/plimsoll.10m.sh" \
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
    assert_match "macOS disk triage", shell_output("#{bin}/plimsoll --help")

    # The guard must emit parseable JSON and a valid level. Exit is 0/1/2 by
    # design (OK/WARN/CRIT) and which one you get depends on the machine -- in
    # the test sandbox the volume reads 0 B free, so it is CRIT and exits 2.
    # Take the output whatever the code; the assertions below judge the content.
    require "json"
    out = shell_output("#{bin}/plimsoll check --json || true")
    j = JSON.parse(out)
    assert_includes %w[OK WARN CRIT], j["level"]
    assert !j["subject"].to_s.empty?, "guard reported no subject"
    assert j["checks"].length >= 4, "expected at least four checks"

    # Destructive paths must be dry-run without --apply.
    refute_match(/^  RUN  /, shell_output("#{bin}/plimsoll reclaim"))
  end
end
