class AppleCalendar < Formula
  desc "Fast Apple Calendar CLI + MCP server (EventKit, read/write)"
  homepage "https://github.com/hunterbrewer04/apple-calendar-mcp"
  url "https://github.com/hunterbrewer04/apple-calendar-mcp/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "ada6cbf41c51e358c9ee9f797b984b5a8806ea82df2f261e713d06bf52dd9564"
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

  service do
    run [opt_bin/"ical", "mcp", "--http"]
    keep_alive true
    # CALENDAR_MCP_TOKEN must be provided to the service environment (the server
    # is fail-closed and will not start without it). Inject it before
    # `brew services start`, e.g.:
    #   launchctl setenv CALENDAR_MCP_TOKEN "$(openssl rand -hex 16)"
    # Bind to a private-network address by also setting CALENDAR_MCP_HOST.
    environment_variables CALENDAR_MCP_PORT: "3456"
    log_path var/"log/apple-calendar.log"
    error_log_path var/"log/apple-calendar.log"
  end

  test do
    assert_match "Usage", shell_output("#{bin}/ical boguscmd 2>&1", 1)
  end
end
