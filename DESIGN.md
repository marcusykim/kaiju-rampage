# KAIJU RAMPAGE — macOS

**Marcus's brief (2026-10-28):** control a giant monster, destroy real-world
cities — Paris, Las Vegas, New York, Los Angeles — pick from a bunch of
different monsters and creatures, set a timer at the beginning, and destroy
as much of the city as possible before it runs out.

*The design has grown far past the brief (same night, Marcus-directed).
What follows is the CURRENT design. The living canon — every ruling and
its history — is the progress log in `OVERNIGHT.md`.*

## The premise

All 18 monsters are one alien **MAMA's** daughters; the 6 robots are her
builds. Mama took out an insurance policy on planet Earth. Her kids wreck
it and collect — unless the **Golden Snitch** (a cholo with little golden
wings, out on a street somewhere talking to a cop) informs the **alien
cops** first. Crush him or the policy pays nothing. Mama chimes in from
the heavens at random while you play, in her own voice. She is not
polite. (M mutes her.)

## Flow

1. **Choose your fighter** — 24 of Mama's girls, paged cards (keys 1–8).
2. **Choose your city** — 30 unlocked + locked monthly drops (paged).
   The Sellout Menu (A) and leaderboard (L) live here too.
3. **RAMPAGE** — one hour on that city's season clock. Leave any time
   (Q/F): the city freezes exactly as you left it.
4. **Results** — run damage folds into the hunt bank. Only a run that
   crushes the Snitch produces a leaderboard score.

## The fighters

24 fighters, each with a unique **BodyPlan** (body shape × leg style ×
width/height × head size/placement — unit-tested pairwise-distinct, no
near-twins), drawn signature features (Mildred's three heads, Hazel's
one giant claw, Harriet's wrecking ball, Winifred's magnet, Edith's
solar panels + orbiting drone…), and a gruesome pass: snarls, furious
brows, drool, battle scars, clawed fists — under sweet 50s names:
Rose, Bonnie, Nancy, Petunia, Bertha, Gertrude, Agnes, Mildred, Ruby,
Vera, Ethel, Mabel, Prudence, Myrtle, Pearl, Dolores, Hazel, Gladys,
and robots Doris, Constance, Harriet, Winifred, Florence, Edith.
Stats differ (speed/power/pace) but DPS is tuned into a fair 55–85
band, test-enforced. Specials (E, 6s cooldown) hit everything near for
double damage in the fighter's element color.

## The cities

36 cities: 30 at launch + 6 locked monthly drops (Istanbul Nov 2026 →
Auckland Apr 2027, gated by `releaseMonth`; the Snitch never hides in a
locked city). Each is a 3,600-pt side-view street the camera follows:
real street name, district, true building height profile, ≥8 parody
storefronts, local transit entrances, props, backdrop sign where
iconic, a landmark with its own drawn style (tower, wheel, spire,
needle, tiers, clock, statue, shells, bridge, sails, pyramid, dome),
and a crowd weighted to the city's real demographics and dress.
Generation is **seeded per city + season** (SplitMix64), so a city is
identical on every visit and frozen rubble lines back up.

## The economy (all unit-tested in `Scoring.swift`)

- **Real scale:** each city carries its real built-asset value
  (`destructionValue`). `claimRate` converts HP → dollars so 100%
  destruction pays exactly that (hits pay ⅔ as they land, collapse the
  final ⅓, landmark topple adds a 5%-of-city surcharge). World total
  $177.9T; Earth's ≈$5 quadrillion appraisal is the thematic ceiling.
- **Hunt bank + season:** runs bank damage into a persistent hunt
  bank. A Snitch crush locks **(bank + run) × 10** as ONE leaderboard
  entry, minus **2% per day after the 1st** of the calendar-month
  season. No crush = no entry, ever. Unclaimed banks evaporate at
  rollover; a new Snitch hides in a different unlocked city.
- **City clocks:** 3,600s per city per season, persisted per season
  (elapsed, per-building HP, dead props, damage already folded —
  no double-paying). Spent cities close until next season.
- **Maldo:** wandering striped menace; destroy him = current run
  damage doubles (bounty = the same amount again) + he respawns in
  16s. Crowd liability: walker $10M, dancer $15M, influencer $25M,
  big $50M. Traffic: two lanes of drawn cars, smashable for prop
  claims, they flee monsters and honk for pedestrians.
- **Combos:** hits within 1.4s chain; every 10 combo = +1 multiplier
  (max ×5) on hit/collapse/prop claims — never on Maldo or surcharges.
- **Mid-run events:** every ~40–60s, 15s of Rush Hour (double ped
  pay, +14 peds), Maldo Mania (4s respawns), or Demolition Derby
  (double collapse claims).
- **Sellout Menu:** opt-in ads from real sponsors (parody house ads
  fill unsold slots). Payouts are claim dollars into the hunt bank;
  longer slots pay more total AND per second; one premium slot on
  top; unskippable once started; 10/day cap. Rate card: `SPONSORS.md`.
- Rank by % destroyed still shows per run: S ≥ 85%, A ≥ 65%, B ≥ 45%,
  C ≥ 25%, D below.

## Controls

Move A/D or ←/→ · Jump W/↑/Space · Stomp ↓/S in the air · Smash J or
click · Special E · Leave city Q/F · Pause P/Esc · Sellout Menu A
(city select) · Leaderboard L · How-to-play H · Mute M (persisted) ·
Results: R again, Enter to selection.
