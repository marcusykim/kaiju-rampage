# Kaiju Rampage — Sponsor Rate Card (the Sellout Catalog)

The monetization model, exactly as designed with Marcus (2026-10-28):
**real companies pay real money to advertise in the game.** Players
open the Sellout Menu, pick an advertiser, watch the ad (unskippable),
and get paid in points — and points in this game are insurance-claim
dollars that land in the player's hunt bank. The game says the quiet
part out loud: the button reads "WATCH ADS TO GET POINTS — YOU SELL
OUT." That honesty is the brand.

## What a sponsor buys

- A **slot in the Sellout Menu** (the catalog in `Scoring.adMenu`),
  sold by **length**: 5 / 10 / 15 / 20 / 30 / 60 seconds.
- Longer slots cost more **in total and per second** — a 60-second
  slot outbids a 30-second one twice over. Players are paid more for
  longer watches, so attention is genuinely bought, not begged.
- **Premium placement** costs extra on top of length: top of the
  menu, gold-framed, the first thing every player sees.
- Every watch is **unskippable and completion-counted** — a sponsor
  never pays for an ad nobody finished. Watches are capped at
  **10 per player per day**, which keeps attention scarce and real.

## Founding rates (monthly placement, per slot)

| Slot | Player payout (per watch) | Founding sponsor price |
|---|---|---|
| ★ Premium 60s (top, gold frame) | $7.2 TRILLION | **$499/mo** |
| 30s | $3 TRILLION | **$249/mo** |
| 20s | $1.5 TRILLION | **$149/mo** |
| 15s | $1 TRILLION | **$99/mo** |
| 10s | $600 BILLION | **$59/mo** |
| 5s | $250 BILLION | **$29/mo** |

Founding rates are deliberately cheap while the audience grows;
they rise with downloads. We sell **placement** (a guaranteed slot in
the catalog), not impressions, until there's an audience large
enough to price impressions honestly.

## House ads (unsold inventory)

Until a slot sells, it runs a **house ad** — one of our own parody
brands (Bolex, WackDonald's, ADIDASS, N&N's World, Planet Fatness,
Mama's Planet Insurance Co.) — and the menu tags it
"HOUSE AD — THIS SLOT IS FOR SALE," so the inventory advertises
itself. The moment a real sponsor signs, their entry replaces the
house entry at the same tier. In the current build **all six slots
are house ads** (`house: true` in `Scoring.adMenu`).

## How a sponsor gets in (build notes)

1. Sign → agree slot + start month.
2. Swap the tier's `AdOffer` in `Scoring.adMenu`: real brand name,
   real slogan, `house: false`. Update the inventory assertion in
   `testCatalogIsComplete` (it counts house ads).
3. Today the ad plays as a branded card for the slot's duration.
   Real sponsor video = an AVPlayer swap-in behind the same slot
   system — scheduled when the first sponsor signs; the menu,
   payouts, caps, and counting do not change.
4. Sponsors are billed monthly, outside the game (invoice/Stripe).
   No in-app purchase involvement: players spend nothing, ever.

## Who to pitch

Local and indie first: game-adjacent indie titles, local businesses
in the game's launch cities, streamers, and any brand with a sense
of humor about a kaiju game whose ad product is literally called
selling out. Mama's pitch writes itself.
