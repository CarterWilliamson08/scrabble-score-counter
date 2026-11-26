# Scrabble Score Counter

Keep **turn totals** during Scrabble (or similar) game nights — tap a player, enter their turn score, keep a running total. No tile math, no board.

This repo has two clients with the same product idea:

| Path | Who it’s for |
|------|----------------|
| [`web/`](web/) | **iPhone Safari** — no Mac, no Xcode, no Apple Developer Program. Best everyday option. |
| [`ScrabbleScoreCounter/`](ScrabbleScoreCounter/) | Native **SwiftUI** draft when you have a Mac |

---

## Web app (no Mac required)

The mobile web app in [`web/`](web/) stores games and saved player names in the browser (`localStorage`) on your phone. Turn totals only — same flow as the native draft (home, new game 1–4 players, recurring names, undo, end/save).

### Open locally (computer)

```bash
cd web
python3 -m http.server 4173 --bind 127.0.0.1
```

Then open [http://127.0.0.1:4173](http://127.0.0.1:4173). Any static file server pointed at `web/` works.

### Add to Home Screen (iPhone)

1. Publish or host the contents of `web/` (or open your computer’s preview URL on the same Wi‑Fi).
2. On the **iPhone**, open the site in **Safari** (not Chrome).
3. Tap the **Share** button (square with an arrow pointing up).
4. Scroll and tap **Add to Home Screen**.
5. Confirm the name (e.g. “Scrabble Score”) and tap **Add**.
6. Open the new icon on your Home Screen like an app. Scores stay on that iPhone only.

Tip: After Add to Home Screen, it launches without Safari chrome (PWA-lite: web app manifest + light offline cache).

### Web file map

| Path | Role |
|------|------|
| `web/index.html` | Shell + splash |
| `web/styles.css` | Mobile UI |
| `web/app.js` | Screens, scoring, localStorage |
| `web/manifest.webmanifest` | Home Screen / standalone metadata |
| `web/sw.js` | Light offline cache |
| `web/icons/` | App icons |

---

## Native SwiftUI (Mac + Xcode)

A native SwiftUI iOS app. Games and recurring player names are saved on-device with SwiftData.

### Requirements

- **Mac** with **Xcode 15+** (from the Mac App Store)
- A free **Apple ID** (no paid Developer Program membership needed to run on your own iPhone)
- An **iPhone** on **iOS 17+**, connected with a cable (or set up for [wireless debugging](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device#Enable-wireless-development) after the first USB pairing)
- For quick testing only: any **iOS 17+ Simulator** that ships with Xcode

### Simulator vs physical device

Use the **Simulator** for fast iteration while you build or tweak the app. Install on a **physical iPhone** when you want to score a real game night — touch, orientation, and on-device storage behave like everyday use.

### Open in Xcode and run on Simulator

1. Clone this repo (or download the ZIP and unzip it).
2. Open **`ScrabbleScoreCounter/ScrabbleScoreCounter.xcodeproj`** in Xcode (double-click the file, or **File → Open**).
3. In the scheme/device menu (top toolbar), pick an **iPhone** simulator (e.g. iPhone 15 / iOS 17+).
4. Press **Run** (▶) or `Cmd+R`.
5. Wait for the splash animation; you should land on the home screen.

If Xcode asks to trust a development team or manage signing, choose your personal team under **Signing & Capabilities** for the `ScrabbleScoreCounter` target. Simulator builds usually work with automatic signing.

### Install on a physical iPhone (free Apple ID)

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

#### First launch: “Untrusted Developer”

The first time you install with a free Personal Team, iOS may block the app until you trust yourself:

1. On the iPhone, open **Settings → General → VPN & Device Management** (wording can vary slightly by iOS version).
2. Under **Developer App**, tap your Apple ID / developer entry.
3. Tap **Trust …** and confirm.
4. Open the Scrabble Score Counter app again.

#### Free account limits (honest notes)

- Apps signed with a **free Personal Team** typically **expire after about 7 days**. When that happens, reopen the project in Xcode and **Run** again to re-install / re-sign.
- The paid **Apple Developer Program** ($99/year) is only needed later for **TestFlight**, App Store distribution, or longer-lived device provisioning — not for personal on-device use of this project.

### Installing the native app without owning a Mac

You **cannot** install the **native** SwiftUI app on an iPhone directly from GitHub (no App Store link, no “download IPA and tap to install” from the repo). iOS only runs native apps that are properly signed.

If you don’t have a Mac, use the **[`web/`](web/) app** above and **Add to Home Screen** instead.

Other native-only options:

1. **Borrow a Mac once** — Follow **Install on a physical iPhone** with a free Apple ID. Expect to re-sign about every **7 days** unless you switch to a paid account.
2. **TestFlight** — Requires the paid **Apple Developer Program** ($99/year) and a Mac (or Mac-based CI) at least once.
3. **App Store** — Same paid program path. Not set up for this project yet.

Do **not** rely on random third-party “IPA stores” or unsigned OTA links.

### Usage walkthrough (native)

1. **Home** — See games in progress and past games. Tap **New Game** to start.
2. **New Game** — Choose 1–4 players. Type names, or tap a **recurring player** chip to fill a slot. Optionally keep **Save new names as recurring players** on so names stick around for next time. Tap **Start Game**.
3. **Active game** — Tap a player tile to open the score sheet. Enter that turn’s point total and tap **Add Score**. Totals update on the tiles; recent turns list below.
4. **Undo** — Tap **Undo** to remove the last turn if you mistyped.
5. **End Game** — Tap **End Game**, confirm, and the session moves to **Past Games** on Home (with winner/tie called out when you reopen it).

Long-press a past game on Home to delete it. Long-press a recurring player chip on New Game to remove that saved name.

### Native project layout

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

### Notes

- Scores are **turn totals only** — you add up the play yourself and enter the number.
- All native data stays on the device (SwiftData). No accounts or network required to build and run locally.
