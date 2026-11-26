# Scrabble Score Counter

A native SwiftUI iOS app for keeping **turn totals** during Scrabble (or similar) game nights. No tile math, no board — just tap a player, enter their turn score, and keep a running total. Games and recurring player names are saved on-device with SwiftData.

**Requirements:** macOS with Xcode 15+, iOS 17 Simulator or device.

## Open in Xcode and run on Simulator

1. Clone this repo (or download the ZIP and unzip it).
2. Open **`ScrabbleScoreCounter/ScrabbleScoreCounter.xcodeproj`** in Xcode (double-click the file, or **File → Open**).
3. In the scheme/device menu (top toolbar), pick an **iPhone** simulator (e.g. iPhone 15 / iOS 17+).
4. Press **Run** (▶) or `Cmd+R`.
5. Wait for the splash animation; you should land on the home screen.

If Xcode asks to trust a development team or manage signing, choose your personal team under **Signing & Capabilities** for the `ScrabbleScoreCounter` target. Simulator builds usually work with automatic signing.

## Usage walkthrough

1. **Home** — See games in progress and past games. Tap **New Game** to start.
2. **New Game** — Choose 1–4 players. Type names, or tap a **recurring player** chip to fill a slot. Optionally keep **Save new names as recurring players** on so names stick around for next time. Tap **Start Game**.
3. **Active game** — Tap a player tile to open the score sheet. Enter that turn’s point total and tap **Add Score**. Totals update on the tiles; recent turns list below.
4. **Undo** — Tap **Undo** to remove the last turn if you mistyped.
5. **End Game** — Tap **End Game**, confirm, and the session moves to **Past Games** on Home (with winner/tie called out when you reopen it).

Long-press a past game on Home to delete it. Long-press a recurring player chip on New Game to remove that saved name.

## Project layout

```
ScrabbleScoreCounter/
  ScrabbleScoreCounter.xcodeproj/   # Open this in Xcode
  ScrabbleScoreCounter/
    ScrabbleScoreCounterApp.swift  # App entry + SwiftData container
    RootView.swift                 # Splash → Home
    Models/Models.swift            # SavedPlayer, GameSession, turns
    Views/                         # Splash, Home, New Game, Active, Score entry
    Theme/AppTheme.swift           # Colors, board background, button style
    Assets.xcassets/
```

## Notes

- Scores are **turn totals only** — you add up the play yourself and enter the number.
- All data stays on the device (SwiftData). No accounts, network, or App Store credentials are required to build and run locally.
