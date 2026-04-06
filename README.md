# Claude Toolbar

A lightweight macOS menu bar app that displays your Claude API usage limits at a glance.

![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift 6](https://img.shields.io/badge/Swift-6-orange)

## Features

- Lives in your menu bar — no Dock icon, no windows
- Shows current session (5-hour) usage percentage directly in the menu bar
- Displays weekly usage limits for all models and Sonnet
- Color-coded progress bars (blue → yellow → red)
- Reset time countdowns for each limit bucket
- Auto-refreshes every 5 minutes
- Reads Claude credentials from your macOS Keychain (uses Claude Code's stored OAuth token)

## Prerequisites

- macOS 14 (Sonoma) or later
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated (the app reads its OAuth token from Keychain)

## Install

```bash
git clone https://github.com/aliaksei-loi/claude-usege-toolbar.git
cd claude-usege-toolbar
```

### Run directly

```bash
swift run
```

### Build .app bundle

```bash
make app
```

The `Claude Toolbar.app` bundle will be created in the project root. Move it to `/Applications` if you'd like:

```bash
make install
```

## How it works

The app reads Claude Code's OAuth credentials from the macOS Keychain and calls the Anthropic usage API (`/api/oauth/usage`) to fetch your current rate limit utilization. It tracks three buckets:

| Bucket | Description |
|---|---|
| **Current session** | 5-hour rolling window |
| **All models** | 7-day combined usage |
| **Sonnet only** | 7-day Sonnet-specific usage |

## Project Structure

```
Sources/ClaudeToolbar/
├── ClaudeToolbarApp.swift          # App entry, MenuBarExtra setup
├── AppState.swift                  # Observable state, auto-refresh logic
├── Models/
│   └── UsageData.swift             # UsageLimits, UsageBucket, API response types
├── Services/
│   ├── KeychainReader.swift        # Reads Claude Code OAuth token from Keychain
│   └── UsageLimitsAPI.swift        # Anthropic usage API client
├── Views/
│   └── MenuBarView.swift           # Main popover UI with progress bars
└── Resources/
    └── Assets.xcassets/            # Menu bar icon
```

## License

MIT
