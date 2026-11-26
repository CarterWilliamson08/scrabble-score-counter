# Scrabble Score Counter

A native SwiftUI iOS app for keeping **turn totals** during Scrabble (or similar) game nights. No tile math, no board — just tap a player, enter their turn score, and keep a running total. Games and recurring player names are saved on-device with SwiftData.

## Requirements

- **Mac** with **Xcode 15+** (from the Mac App Store)
- A free **Apple ID** (no paid Developer Program membership needed to run on your own iPhone)
- An **iPhone** on **iOS 17+**, connected with a cable (or set up for [wireless debugging](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device#Enable-wireless-development) after the first USB pairing)
- For quick testing only: any **iOS 17+ Simulator** that ships with Xcode

## Simulator vs physical device

Use the **Simulator** for fast iteration while you build or tweak the app. Install on a **physical iPhone** when you want to score a real game night — touch, orientation, and on-device storage behave like everyday use.

## Open in Xcode and run on Simulator

1. Clone this repo (or download the ZIP and unzip it).
2. Open **`ScrabbleScoreCounter/ScrabbleScoreCounter.xcodeproj`** in Xcode (double-click the file, or **File → Open**).
3. In the scheme/device menu (top toolbar), pick an **iPhone** simulator (e.g. iPhone 15 / iOS 17+).
4. Press **Run** (▶) or `Cmd+R`.
5. Wait for the splash animation; you should land on the home screen.

If Xcode asks to trust a development team or manage signing, choose your personal team under **Signing & Capabilities** for the `ScrabbleScoreCounter` target. Simulator builds usually work with automatic signing.

## Install on a physical iPhone (free Apple ID)

You do **not** need the paid $99/year Apple Developer Program to run this app on your own phone. A free Personal Team is enough.

1. Open **`ScrabbleScoreCounter/ScrabbleScoreCounter.xcodeproj`** in Xcode.
2. In the left sidebar, select the **ScrabbleScoreCounter** project (blue icon), then select the **ScrabbleScoreCounter** target.
3. Open the **Signing & Capabilities** tab.
4. Check **Automatically manage signing**.
5. Under **Team**, choose **Add Account…**, sign in with your Apple ID, then select your **Personal Team**.
6. Set a unique **Bundle Identifier** if Xcode complains about conflicts (for example `com.carterwilliamson.scrabble-score-counter`). The project already ships with `com.carterwilliamson.ScrabbleScoreCounter`.
7. Connect your iPhone with a cable. Unlock the phone and tap **Trust** if prompted.
8. In Xcode’s scheme/device menu, select your **iPhone** as the run destination (not a Simulator).
9. Press **Run** (▶) or `Cmd+R`. Xcode builds, installs, and launches the app.

### First launch: “Untrusted Developer”

The first time you install with a free Personal Team, iOS may block the app until you trust yourself:

1. On the iPhone, open **Settings → General → VPN & Device Management** (wording can vary slightly by iOS version).
2. Under **Developer App**, tap your Apple ID / developer entry.
3. Tap **Trust …** and confirm.
4. Open the Scrabble Score Counter app again.

### Free account limits (honest notes)

- Apps signed with a **free Personal Team** typically **expire after about 7 days**. When that happens, reopen the project in Xcode and **Run** again to re-install / re-sign.
- The paid **Apple Developer Program** ($99/year) is only needed later for **TestFlight**, App Store distribution, or longer-lived device provisioning — not for personal on-device use of this project.

## Installing without owning a Mac

You **cannot** install this app on an iPhone directly from GitHub (no App Store link, no “download IPA and tap to install” from the repo). iOS only runs apps that are properly signed.

Realistic options if you don’t have a Mac day-to-day:

1. **Borrow a Mac once** — Use a friend’s Mac (or a library/school machine with Xcode) and follow **Install on a physical iPhone** above with a free Apple ID. Expect to re-sign about every **7 days** unless you switch to a paid account.
2. **TestFlight** — Requires the paid **Apple Developer Program** ($99/year) and a Mac (or Mac-based CI) at least once to archive the app and upload a build. Testers then install via Apple’s TestFlight app — no USB cable each time.
3. **App Store** — Same paid program and archive/upload path as TestFlight, then a public listing later. Not set up for this project yet.

Do **not** rely on random third-party “IPA stores” or unsigned OTA links; without correct Apple signing they won’t install (or won’t stay installed) on a normal iPhone.

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
