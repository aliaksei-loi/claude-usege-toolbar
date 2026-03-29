# Claude Toolbar

macOS menu bar app displaying Claude API usage information.

## Tech Stack

- **Language:** Swift 6 (strict concurrency)
- **UI:** SwiftUI with MenuBarExtra
- **Platform:** macOS 14+
- **Build:** Swift Package Manager

## Key Commands

```bash
swift build             # Build the project
swift run               # Build and run
swift build -c release  # Release build
make app                # Create .app bundle
```

## Project Structure

```
Sources/ClaudeToolbar/
├── ClaudeToolbarApp.swift   # App entry point with MenuBarExtra
├── Views/
│   ├── MenuBarView.swift    # Main popover view
│   └── UsageRow.swift       # Individual usage metric row
├── Models/
│   └── UsageData.swift      # Data models for API usage
├── Services/
│   └── AnthropicAPI.swift   # Anthropic API client
└── Resources/
    └── Info.plist            # App metadata (LSUIElement)
```

## Conventions

- Use `type` instead of `interface`/`protocol` where possible for data types (prefer structs)
- SwiftUI views, @Observable for state management
- async/await for all network calls
- Strict Swift 6 concurrency (Sendable conformance)
