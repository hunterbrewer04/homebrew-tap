# homebrew-tap

Homebrew formulae for my tools.

## apple-calendar

Fast Apple Calendar CLI + MCP server (EventKit, read-only). Source:
[apple-calendar-mcp](https://github.com/hunterbrewer04/apple-calendar-mcp).

```bash
brew install hunterbrewer04/tap/apple-calendar
```

This builds from source, installs the binary as `ical`, and code-signs it with a stable
identity so the macOS Calendar permission survives upgrades. macOS 14+ required.

Run the MCP HTTP server in the background (token required — the server is fail-closed):

```bash
launchctl setenv CALENDAR_MCP_TOKEN "$(openssl rand -hex 16)"
brew services start apple-calendar
```

See the [apple-calendar-mcp README](https://github.com/hunterbrewer04/apple-calendar-mcp)
for full CLI, MCP, and security docs.
