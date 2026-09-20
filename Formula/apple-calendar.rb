class AppleCalendar < Formula
  desc "Fast Apple Calendar CLI + MCP server (EventKit, read + write)"
  homepage "https://github.com/hunterbrewer04/apple-calendar-mcp"
  url "https://github.com/hunterbrewer04/apple-calendar-mcp/archive/refs/tags/v1.4.2.tar.gz"
  sha256 "ebb5feab4eda966bc5b79e56644ed916a8fa9c03d183270a316172de9db49c11"
  license "MIT"

  depends_on macos: :sonoma # macOS 14+ (EventKit requestFullAccessToEvents)
  # No `depends_on xcode` — the Command Line Tools' Swift toolchain builds this
  # package (verified), so requiring full Xcode would needlessly block CLT-only Macs.

  def install
    # --disable-sandbox lets the in-build codesign step write the signature.
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/apple-calendar" => "ical"
    # Stable code identity is load-bearing: macOS pins the Calendar (TCC) grant
    # to this identifier, so it must be re-applied on every (re)install.
    system "codesign", "-s", "-", "--identifier", "com.apple-calendar-mcp.cli",
           "--force", bin/"ical"
  end

  # No brew service: the networked server is installed with `ical serve setup`,
  # which writes a user-owned LaunchAgent (host baked into args, token read from
  # ~/.config/apple-calendar/token) that survives `brew upgrade`. See the README.

  test do
    assert_match "Usage", shell_output("#{bin}/ical boguscmd 2>&1", 1)
  end
end
