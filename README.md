# KAIJU RAMPAGE 🦎💥🏙

A native macOS arcade destruction game with a criminal plot: **Mama** —
alien matriarch — took out an insurance policy on planet Earth and sent
her kids to collect. Wreck the world's biggest cities, bank the claim
money, and crush the **Golden Snitch** before he informs the alien cops.

**The fighters (24):** all of them are Mama's girls — 18 monsters with
classic 50s names and horrifying faces (Rose, Bonnie, Nancy, Petunia,
Bertha, Ethel, Gladys, Pearl…) plus 6 robots Mama built (Doris,
Constance, Harriet, Winifred, Florence, Edith). Every fighter has a
unique body plan, silhouette, signature features, stats, and special
move, with damage-per-second tuned fair across the roster.

**The cities (36):** 30 playable at launch — Paris, Tokyo, New York,
London, Shanghai, Los Angeles, Rome, Cairo, São Paulo and 21 more —
each with its real streets, landmark, height profile, parody
storefronts (BOLEX, WACKDONALD'S, PLANET FATNESS, N&N'S WORLD,
ADIDASS), and a crowd drawn from its real demographics. Plus **6 locked
cities that drop monthly** (Istanbul Nov 2026 → Auckland Apr 2027).

## The rules that matter

- **Real money scale.** Every city is worth its real built-asset
  value: flatten 100% of Tokyo and the claim pays exactly **$14
  trillion**. The whole world totals **$177.9 trillion**.
- **One hour per city per season.** Leave any time (Q/F) and the city
  freezes exactly — clock, rubble, bank — until you come back. A spent
  city is closed until next season.
- **The hunt bank.** Every run's damage banks up, but **nothing counts
  until you crush the Golden Snitch** — one per account, hidden in one
  city, out on the street talking to a cop. A crush locks
  **(bank + final run) × 10** as a single leaderboard score.
- **The season is the calendar month.** Every day after the 1st costs
  **2% of the lock-in**. Unclaimed banks evaporate at month's end.
- **Maldo** — the striped menace — doubles your points plus a **$1
  billion** bounty when destroyed. He comes back in 16 seconds.
- **Crowd liability:** walker $10M · TikTok dancer $15M · influencer
  $25M · big guy $50M. Cars crunch for prop value. Combos chain hits
  (1.4s window) up to a ×5 claim multiplier. Mid-run events (Rush
  Hour, Maldo Mania, Demolition Derby) keep every visit spicy.
- **Mama chimes in from the heavens** at random while you play. She
  has notes. (M mutes her — she'll remember this.)
- **The Sellout Menu** (A on city select): real sponsors pay real
  money for ad slots; watching pays you claim points into the hunt
  bank. Longer ads pay more; the premium slot pays most. 10 a day —
  Mama raised a dignified family. See `SPONSORS.md`.

## How to play it on your Mac

You need Xcode (free from the Mac App Store). Then either:

**Option A — Terminal:**
```bash
cd ~/path/to/kaiju-rampage
swift run
```

**Option B — Xcode:**
Open `Package.swift` in Xcode and press ▶ Run.

The game window opens at the fighter-select screen. If the keyboard
doesn't respond at first, click the game window once to focus it.

## Controls

| Input | Action |
|---|---|
| 1–8 / click, ←/→ | Choose fighter, then city (paged) |
| A / D or ← / → | Walk |
| W / ↑ / Space | Jump · ↓/S in the air = stomp slam |
| J / click | Smash |
| E | Special move (6-second cooldown) |
| Q / F | Leave city (its clock freezes) |
| P / Esc | Pause |
| A (city select) | Sellout Menu — watch ads, bank points |
| L (select screens) | Leaderboard |
| H (select / paused) | How to play card |
| M | Mute everything (Mama included) — persists |
| R / Enter | Results: rampage again / back to selection |

## Project layout

```
Package.swift
Sources/KaijuRampage/
  KaijuRampageApp.swift   — SwiftUI app entry
  ContentView.swift       — hosts the SpriteKit scene
  GameScene.swift         — the whole game: selection, cities, combat
  Models.swift            — 24 fighters, 36 cities (pure data tables)
  Scoring.swift           — claim math, seasons, combos, ads (pure logic)
  Leaderboard.swift       — local top-10 + Game Center hook (off)
Tests/KaijuRampageTests/  — unit tests: scoring, catalog completeness
DESIGN.md                 — the design brief
SPONSORS.md               — the Sellout Menu rate card for real sponsors
OVERNIGHT.md              — build/roadmap log (the canon lives here)
```

No image assets — every monster, building and effect is drawn in code.
Sounds are built-in macOS system sounds; Mama's voice is the system
speech synthesizer. Zero setup beyond Xcode.

## Distribution

Free to download and play; ads optional. Primary channels: **Steam,
Epic, and our own website**, on **Mac and Windows** (the Windows build
is a Godot port — SpriteKit is Apple-only). The Mac App Store gets the
game exactly as-is or not at all: we never sacrifice the humor for a
listing. Full plan: `../mac-games/STORE_LAUNCH_PLAN.md`.
