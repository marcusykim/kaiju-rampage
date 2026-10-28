# Kaiju Rampage — Overnight Improvement Run

Marcus's order (2026-10-28 ~01:42 PDT): "Make this awesome. Aim for the best
version of this game you can. Keep working overnight, no less than 8 hours."
EXTENDED by Marcus (02:37 PDT): "don't stop working until 12pm. I bought
you 500 million more credits." The run now ends at **12:00 PM PDT**; the
main chat works items in parallel with the cron until then. Driven by cron
job `kaiju-overnight` (every 45 min). Each run: take the top unfinished
item, implement, verify, commit, log here. Final run (at/after 11:15 PDT):
final report + remove the cron job.

## Hard rules for every run
- Git identity: Marcus Kim <contact@marcusykim.com>; commit after each item.
- After editing Swift, run the brace/paren/bracket balance check (python,
  strip string literals first) on every .swift file; all must be 0.
- Never break the test contract: 24 fighters (18 monsters + 6 robots),
  17 cities, timers [60,120,180,0], fighter DPS within 55–85.
- Pure scoring logic goes in Scoring.swift WITH unit tests in
  Tests/KaijuRampageTests/ScoringTests.swift.
- No purchases, no store submissions, no messages to anyone, no spending.
- The VM is Linux with no Swift compiler — the Mac build is the only
  compile check. Marcus's Mac: device_id 3258b41b-2a16-b7f0-10de-4873a067b967
  (M1 Pro, macOS 26.5.2, Xcode installed). It has NO shell runner; drive
  Xcode's GUI via device computer tools; push files with device files.write
  (verify bytes_written against local `wc -c`). If the Mac is asleep or
  offline, log it and move to the next code item; retry the build next run.
- Parody names only, never real brands. Marcus's spellings: BOLEX,
  N&N'S WORLD, PLANET FATNESS, ADIDASS, WACKDONALD'S.
- Food Truck Rush is DESCOPED (Marcus, 2026-10-28 04:17): "don't use
  any tokens for food truck rush. devote all tokens to kaiju
  rampage." The project stays intact on disk, but no work, no
  build-verification, no app assembly, no report section — Kaiju
  only, until Marcus says otherwise.

## State at start (2026-10-28 01:42 PDT)
- Kaiju v2 committed (49184b5): 24 fighters, 17 cities with real streets,
  parody storefronts, height profiles, free play, local leaderboard +
  disabled Game Center hook.
- Maldo + crowd committed (6da1e79): Maldo wanders a random street stretch,
  destroying him doubles points + $250k bounty, respawns after 16s. Crowd of
  26: walkers $5k, TikTok dancers $10k (tripod + phone, oblivious),
  influencers $15k (ring light, phone up), big pedestrians $25k. Walk-over,
  smash, stomp, special and landing all squash. WackDonald's replaced
  McRONALD'S in all 14 shop lists.
- NOT yet compile-verified. Mac has stale partial v1 sources only.

## Roadmap (priority order)
1. [ ] MAC BUILD (KAIJU ONLY — FTR descoped 04:17): sync all Kaiju
       sources to the Mac (~/Developer/mac-games/), open Package.swift
       in Xcode, Product → Run, fix every compile error (fix in BOTH
       the Mac copy and the local repo; commit fixes). Assemble
       KaijuRampage.app (Contents/MacOS binary + Info.plist from
       ~/workspace/mac-games/packaging/, bundle ID
       com.marcusykim.kaijurampage, ad-hoc codesign), copy into
       /Applications, launch once to verify, pull back and zip the
       .app bundle into ~/workspace/mac-games/dist/ for the final
       report attachment.
2. [x] COMBO SYSTEM — DONE 03:44 PDT (main chat): hits within 1.4s
       chain a combo counter; every 10 combo adds +1 multiplier level
       (max ×5) applied to hit/collapse/prop claim dollars (NOT to
       Maldo doubling, landmark surcharge, or crowd liability).
       Scoring.comboMultiplier/comboClaim + testCombo. HUD shows
       "🔥 COMBO ×N (count)" under the special label; combo resets
       when the window lapses; floating "🔥 COMBO ×N!" + Glass sound
       at each milestone; killing blows chain twice (hit + collapse).
3. [x] DAMAGE JUICE — DONE 03:52 PDT (main chat): crack decals in two
       stages (stage 1 < 66% HP, stage 2 < 33%; deterministic per-
       building jagged branches; restored frozen buildings re-crack
       correctly), collapse dust cloud (10 soft puffs), per-hit
       floating damage numbers (small gold, combo-awarded amounts),
       monster lunge on smash (body group throws 15pt toward facing),
       roar (Basso) + camera kick on city arrival.
4. [x] MID-RUN EVENTS — DONE 04:02 PDT (main chat), adapted to the
       city-clock design (no timed/free-play modes exist anymore):
       every ~40–60s a random event runs 15s — RUSH HOUR (+14 peds
       pour in, all ped values ×2), MALDO MANIA (respawn 4s),
       DEMOLITION DERBY (collapse claims ×2). Gold banner announce +
       HUD countdown under the combo label. Scoring.CityEvent +
       constants, testCityEvents.
5. [x] MOVING TRAFFIC — DONE 04:12 PDT (main chat), lanes adapted to
       the side view: two depth lanes (far lane groundY+30 drives
       left, near lane groundY-16 drives right — right-hand traffic).
       Drawn cars (body + glass cabin + wheels + headlight, 6 paint
       colors incl. taxi yellow), wrap at world edges, 2.2× flee
       speed near the monster, smashable for prop claim value via
       smash/special/stomp (not walk-over), stop-and-honk ("!" +
       Submarine) when a ped crosses ahead. 8 alive max, edge
       respawns keep the streets populated.
6. [x] MONSTER SILHOUETTES — DONE 01:52 PDT, bigger than planned:
       every fighter now has a unique BodyPlan (shape × leg style ×
       body W/H × head size/placement), enforced by unit test
       testBodyPlansAllDifferent. Hydra has 3 heads, Scorpius a stinger
       arc, Kraken tentacles, spiders 6 legs, serpent/worm/ghost/
       Sentinel legless (Sentinel hovers), Behemoth a horn, Mako a
       dorsal fin, Noctura ears, Zorgath eye stalks. Remaining nice-to-
       have if time remains: Sentinel orbiting drone.
7. [x] HOW-TO-PLAY + PAUSE POLISH — DONE 04:22 PDT (main chat):
       HOW TO PLAY card (H on select screens + while paused) covering
       the job, controls, city clocks, the Snitch lock-in rules,
       Maldo, crowd liability values, combos, and the Sellout Menu;
       pause overlay now lists the key rules too. Sound: M was
       already Mama's mute (Marcus canon) so it became the MASTER
       mute — all 17 NSSound call sites now route through playSFX()
       gated by the same flag, and the flag persists in UserDefaults
       (kaijurampage.muted).
8. [x] STORE PACK: write ~/workspace/mac-games/STORE_LAUNCH_PLAN.md —
       Mac App Store listing copy (title, subtitle, description,
       keywords), Game Center leaderboard creation steps
       (kaijurampage.damage, then set gameCenterEnabled = true),
       screenshot shot-list, Steam + Epic listing copy with their
       ~$100/game fees and the steps only Marcus can do, Windows plan
       (Godot port — SpriteKit is Apple-only; scope + estimate).
9. [x] FOOD TRUCK POLISH — DONE 04:31 PDT (main chat, food-truck-rush
       commit f6438fb): day/night shift tint (golden hour → deep
       night across the 120s shift), order bubbles upgraded to true
       thought bubbles (dot trail + gentle bob), combo timer bar —
       which also gave Food Truck combos a real 6-second window
       (Scoring.comboWindowSeconds + test); before, streaks only
       died on a walk-away.
10. [x] FINAL (run at/after 11:15 PDT; Marcus extended the run to
        12:00 PM): rebuild the Kaiju app if code changed since item 1,
        regenerate the zip, write the final report as the run's chat
        message (what shipped with commit hashes, what's in
        /Applications, the KaijuRampage.app zip attachment/link,
        store pack summary, anything blocked and why — Food Truck
        Rush is descoped per Marcus 04:17 and gets no section),
        check off this roadmap, and remove cron job
        `kaiju-overnight`.

## Future roadmap (post-run ideas, for the final report + next session)
- GODOT PORT (required launch work per the distribution policy):
  Scoring/catalog first with the ported test suite as the parity
  gate, then scene/combat, crowd/Maldo/Snitch, persistence, SAPI
  Mama voice. Steam/Epic/website full launch waits for Windows.
- AVPlayer sponsor-video swap-in behind the Sellout Menu slots —
  build when the first real sponsor signs (SPONSORS.md).
- Resistance: helicopters + army vehicles that fight back, monster
  health bar (the classic v1 "ideas for v2" list, still good).
- Building climbing + rooftop fights; 2-player local co-op.
- Monthly drops beyond Apr 2027: script the next 6 cities now
  (data-only additions; append CityKind cases, never reorder).
- Game Center flip (kaijurampage.damage + gameCenterEnabled) —
  only alongside the optional as-is Mac App Store attempt.
- Food Truck Rush: night-market second map, truck skins.

## GitHub (Marcus's order 2026-10-28 01:45 PDT)
- "Keep committing and pushing to my GitHub. Make this a public repo."
  Marcus is keeping the Mac awake overnight.
- The GitHub connector CANNOT create repos (create_repository →
  403 "Resource not accessible by integration", verified twice).
  Marcus must create the public repo `kaiju-rampage` himself and the
  Muse GitHub App installation must include it. Until
  marcusykim/kaiju-rampage is reachable via the connector, runs log
  "GitHub repo not reachable yet" and keep committing locally.
- Once reachable: snapshot-push after every commit (procedure in the
  cron body + connector snapshot-push.md). GitHub is a mirror of the
  local repo's files, not a replacement for local git history.

## Progress log
- 11:28 PDT — FINAL RUN (kaiju-overnight): item 10 wrap-up.
  Mac build RETRIED one last time — Mac online, session
  started, screen STILL LOCKED (screen_locked, same as every
  run since 06:13). No code changed since the 10:43 fix
  (abf9684, Mac-synced byte-identical), so no rebuild was
  owed; no .app/zip exists (~/workspace/mac-games/dist/ was
  never created) and nothing is in /Applications — the build
  still needs Marcus's hand: unlock the Mac, then open
  ~/Developer/mac-games/kaiju-rampage/Package.swift in Xcode
  → ⌘R, or run packaging/build-app.sh from Terminal (it does
  swift build + .app assembly + ad-hoc codesign + zip).
  Final verification: balance checks zero on every Swift
  file; 20 tests in ScoringTests.swift; catalog canon intact
  (24 fighters, 36 cities = 30 launch + 6 monthly drops,
  $177.9T world). GitHub repo not reachable yet
  (get_file_contents → 404) — Marcus must create the public
  marcusykim/kaiju-rampage repo + include it in the Muse
  GitHub App installation; local history (57 commits) is
  complete and ready to snapshot-push. Store pack stands at
  ~/workspace/mac-games/STORE_LAUNCH_PLAN.md (14,712 B).
  Roadmap: items 2–8 + 10 done; item 1 (Mac build) remains
  open, blocked solely on the locked Mac screen. This cron
  job removes itself after this run per Marcus's order.
- 10:43 PDT — OVERNIGHT RUN (kaiju-overnight): item 1 (Mac
  build) RETRIED — Mac online, computer.session started OK,
  but the screen is STILL LOCKED (computer.control →
  screen_locked, non-retryable until Marcus unlocks it; same
  as 06:13/06:58/07:43/08:28/09:13/09:58). Session ended
  cleanly. Build still needs Marcus's hand: unlock the Mac,
  then open ~/Developer/mac-games/kaiju-rampage/Package.swift
  in Xcode → ⌘R, or run packaging/build-app.sh from Terminal.
  Took a FRESH audit angle — percent-destroyed accounting:
  totalHP (line 1307) counts buildings + props.count × 20
  ONLY, and every destroyedHP increment is symmetric with it
  (damageBuilding dealt, restore maxHP − hpLeft, smashProp
  +20, dead-prop restore +20) EXCEPT one. FOUND + FIXED
  (commit abf9684): smashCar added destroyedHP += 20 per car,
  but traffic is not in the HP stock and respawns forever
  (edge respawns, 8 alive max) — endless car-crunching could
  push percentDestroyed to 100% and rank to S while buildings
  still stood. Cars still pay prop claim dollars exactly as
  the item-5 design specifies; they just no longer count
  toward the percent. Fix applied to BOTH copies: Mac
  GameScene.swift via files.edit, 1 replacement, bytes_written
  210,005 IDENTICAL to local. Balance checks zero on every
  Swift file; remaining destroyedHP += 20 sites are exactly
  the two symmetric prop paths. Also verified in passing:
  Scoring overflow headroom (worst-case season bank ≈ $2.4Q
  incl. 310 premium ads; lock-in ×10 ≈ 2.4e16, far under
  Int64 max), city unlock monotonicity (drops unlock on the
  1st, restored snitchCity can never be a locked city), and
  Leaderboard sort/top-10. GitHub repo not reachable yet
  (get_file_contents → 404).
- 09:58 PDT — OVERNIGHT RUN (kaiju-overnight): item 1 (Mac
  build) RETRIED — Mac online, computer.session started OK,
  but the screen is STILL LOCKED (computer.control →
  screen_locked, non-retryable until Marcus unlocks it; same
  as 06:13/06:58/07:43/08:28/09:13). Session ended cleanly.
  Build still needs Marcus's hand: unlock the Mac, then open
  ~/Developer/mac-games/kaiju-rampage/Package.swift in Xcode
  → ⌘R, or run packaging/build-app.sh from Terminal. Took a
  FRESH audit angle — lock-in penalty day semantics: the
  penalty rationale is days spent NOT finding the Snitch, the
  city-select banner promises "CRUSH HIM TODAY: ×10 LOCK-IN,
  PENALTY −X%", snitchDay is persisted across a frozen visit,
  and the leaderboard entry records "SNITCH · DAY <catch>" —
  but showResults computed the lock-in with seasonDay (the
  day the visit ENDS). A catch frozen mid-visit and restored
  after midnight (the exact case snitchDay was saved for)
  was re-penalized for days he was already caught, and the
  same results screen showed both days incoherently. FOUND
  + FIXED (commit ce4eacb): lock-in and its displayed penalty
  now use huntDaysAtCatch; same-day catches are unchanged
  (mirror-verified: caught d5/ends d9 now locks $13.8M of a
  $15M gross instead of $12.6M; d11 same-day still $12,000 on
  the test's numbers); legacy saves with snitchDay 0 fall
  back to today instead of a "DAY 0" catch at 0%; huntLockIn
  doc now states dayOfMonth = crush day. Fix applied to BOTH
  copies: Mac GameScene.swift (209,691 B) and Scoring.swift
  (10,573 B) via files.edit, 1 replacement each, final byte
  counts IDENTICAL to local. Balance checks zero on every
  Swift file; catchPenalty grep-verified exactly once.
  GitHub repo not reachable yet (get_file_contents → 404).
- 09:13 PDT — OVERNIGHT RUN (kaiju-overnight): item 1 (Mac
  build) RETRIED — Mac online, computer.session started OK,
  but the screen is STILL LOCKED (computer.control →
  screen_locked, non-retryable until Marcus unlocks it; same
  as 06:13/06:58/07:43/08:28). Session ended cleanly. Build
  still needs Marcus's hand: unlock the Mac, then open
  ~/Developer/mac-games/kaiju-rampage/Package.swift in Xcode
  → ⌘R, or run packaging/build-app.sh from Terminal. Took a
  FRESH audit angle — save-format forward compatibility:
  CityProgress and ScoreEntry used SYNTHESIZED Codable, which
  ignores property defaults on decode, so a save written by
  a build predating a field (snitchCaught/snitchDay arrived
  after the first city-clock build, 71a4c05 → 4a5577d) fails
  the WHOLE decode and loadCityProgress / Leaderboard.load
  silently return empty — every city's frozen progress or
  the entire board wiped on upgrade. FOUND + FIXED (commit
  1d9e410): both structs now decode each field via
  decodeIfPresent with its default (explicit CodingKeys =
  exactly the stored properties; encode stays synthesized);
  testLegacySavesStillDecode locks both legacy shapes (city
  dict missing snitch keys keeps elapsed/HP/props/folded;
  board entry missing mode/date decodes with defaults).
  Fix applied to BOTH copies: Mac Models.swift (72,299 B),
  Leaderboard.swift (3,625 B) and ScoringTests.swift
  (20,036 B) via files.edit, 1 replacement each, byte counts
  IDENTICAL to local. Balance checks zero on every Swift
  file; each new init(from:) grep-verified exactly once per
  file. Also verified in passing: Snitch restore path is
  sound (startGame restores a mid-visit crush from
  prog.snitchCaught/snitchDay, snitchPresent excludes caught
  cities, showResults' snapshot-then-clear ordering is
  correct). GitHub repo not reachable yet
  (get_file_contents → 404).
- 08:28 PDT — OVERNIGHT RUN (kaiju-overnight): item 1 (Mac
  build) RETRIED — Mac online, computer.session started OK,
  but the screen is STILL LOCKED (computer.control →
  screen_locked, non-retryable until Marcus unlocks it; same
  as 06:13/06:58/07:43). Session ended cleanly. Build still
  needs Marcus's hand: unlock the Mac, then open
  ~/Developer/mac-games/kaiju-rampage/Package.swift in Xcode
  → ⌘R, or run packaging/build-app.sh from Terminal. Took a
  FRESH audit angle — freeze/restore symmetry + seeded-layout
  determinism: destructible layout draws ONLY from the seeded
  SplitMix64 stream (w/h/gap + prop picks at 1227–1304); every
  unseeded random is cosmetic (sky/stars/skyline/clouds/
  birds/effects) or per-run by design (Maldo home, Snitch
  spot — re-rolled per run per the 02:00 canon, crowd,
  traffic); damageBuilding clamps dealt = min(power, hp) so
  HP never goes negative; snapshot/restore of elapsed,
  damageFolded, snitchCaught and deadProps all symmetric,
  and destroyed-building restore matches collapse()'s final
  state. FOUND + FIXED one real freeze-fidelity defect
  (commit de0728a): restored damaged-but-standing buildings
  kept hpBG/hpFill at alpha 0 with a full-width green fill —
  the HP bar damageBuilding shows was missing until the next
  hit. Restore now shows the bar scaled + colored exactly as
  damageBuilding left it (frac > 0.4 green, else red). Fix
  applied to BOTH copies: Mac GameScene.swift via files.edit
  (1 replacement, 208,929 B) and upload-back cmp/MD5
  IDENTICAL to local (ac0d171a…). Observed, not changed:
  the sun's x uses city.name.hashValue (Swift per-launch
  hash randomization) — cosmetic backdrop only, not layout
  or rubble, so no canon break. Balance checks zero on every
  Swift file; new block grep-verified exactly once. GitHub
  repo not reachable yet (get_file_contents → 404).
- 07:43 PDT — OVERNIGHT RUN (kaiju-overnight): item 1 (Mac
  build) RETRIED — Mac online, computer.session started OK,
  but the screen is STILL LOCKED (computer.control →
  screen_locked, non-retryable until Marcus unlocks it; same
  as 06:13/06:58). Session ended cleanly. Build still needs
  Marcus's hand: unlock the Mac, then open
  ~/Developer/mac-games/kaiju-rampage/Package.swift in Xcode
  → ⌘R, or run packaging/build-app.sh from Terminal. Nothing
  to sync: working tree clean at a801ab7, no Sources/Tests
  changes since the md5-verified sync (31d6b8e, 05:32).
  Three NEW pre-build audit angles — ALL CLEAN, no code
  change: (1) controls-vs-help audit — Key.digits correctly
  maps keycodes 1–9 (scrambled physical order is correct),
  and every binding in update()/keyDown (move A/D/←/→, jump
  W/↑/Space, smash J/X/click, stomp K/S/↓, special E/Shift,
  leave Q/F, pause P/Esc, M mute, H card, A sellout,
  L leaderboard, digits/pages) matches the HOW TO PLAY card
  and pause overlay text exactly; (2) Sellout mouse path —
  playAd → beginOverlay → clearOverlay empties clickTargets,
  so mid-ad clicks are inert just like the keyboard's mid-ad
  lock; finishAd is exactly-once (sets adTimeLeft=0 first,
  update guards >0); adsDateKey is a date-scoped count key,
  cap enforced at menu open; city/monster paging math
  (ceil/8, clamped) and choose() guards (locked + spent
  cities Basso-rejected, 9999/9000+ sentinels) all correct;
  (3) packaging audit — build-app.sh assembles the bundle +
  Info.plist + ad-hoc codesign + ditto zip correctly, and
  the CI workflow invokes it with the right bundle ID
  (com.marcusykim.kaijurampage) and uploads
  dist/KaijuRampage-macOS.zip. Balance checks zero on every
  Swift file. GitHub repo not reachable yet
  (get_file_contents → 404).
- 06:58 PDT — OVERNIGHT RUN (kaiju-overnight): item 1 (Mac
  build) RETRIED — Mac online, computer.session started OK,
  but the screen is STILL LOCKED (computer.control →
  screen_locked, non-retryable until Marcus unlocks it; same
  as 06:13). Session ended cleanly. Build still needs
  Marcus's hand: unlock the Mac, then open
  ~/Developer/mac-games/kaiju-rampage/Package.swift in Xcode
  → ⌘R, or run packaging/build-app.sh from Terminal. Nothing
  to sync: no Sources/Tests changes since the md5-verified
  sync (31d6b8e was the last code commit, synced at 05:32).
  Fresh-angle pre-build sweep — ALL CLEAN, no code change:
  balance checks zero on every Swift file; duplicate-
  definition scan across the whole target clean (the one
  apparent hit, `rank`, is Leaderboard.rank(of:in:) vs
  Scoring.rank(percentDestroyed:) — different types, no
  conflict); switch-exhaustiveness audit of all 13 GameScene
  switches — landmark body switch covers all 12
  LandmarkStyle cases, landmark dressing switch has a
  default, body-plan legs/shape switches exhaustive, state
  switch covers all 5 states, CityEvent switch all 3, ped
  switches all 4 kinds, and the signature-feature switch
  carries a default (hydra/scorpius/behemoth/zorgath features
  live in the body-plan code, not that switch); test target
  wiring confirmed (@testable import KaijuRampage). GitHub
  repo not reachable yet (get_file_contents → 404).
- 06:13 PDT — OVERNIGHT RUN (kaiju-overnight): item 1 (Mac
  build) RETRIED — Mac online, but the screen is LOCKED this
  time (computer.control → screen_locked, non-retryable until
  Marcus unlocks it; different from the 05:32 identity wall).
  Nothing to sync: sources were md5-verified identical in the
  05:03/05:32 runs and HEAD is unchanged since (46958f9).
  Build still needs Marcus's hand: unlock the Mac, then open
  ~/Developer/mac-games/kaiju-rampage/Package.swift in Xcode
  → ⌘R, or run packaging/build-app.sh from Terminal. Took the
  full pre-build sweep instead — ALL CLEAN, no code change
  needed: balance checks zero on every Swift file; Scoring./
  Leaderboard. cross-references clean (CityEvent is the nested
  enum, defined once); no duplicate function definitions in
  GameScene's 76 funcs; no try!/as!; UserDefaults keys each
  built at exactly one site (bank/season/cityprogress/ads/
  snitch/muted all consistent); catalog mirror sim in Python:
  24 fighters, DPS 64.7–78.1 (all inside 55–85), 36 cities,
  world total exactly $177.9T, drop schedule padded YYYY-MM
  (30× 2026-10 launch + Nov 2026 → Apr 2027 monthly); every
  Scoring func/const is referenced by the 19 tests; no TODOs;
  README/DESIGN numbers match canon; item 6's Sentinel
  orbiting drone is already in the code (pivot + red-eye drone,
  3.6s orbit). GitHub repo not reachable yet
  (get_file_contents → 404).
- 05:32 PDT — OVERNIGHT RUN (kaiju-overnight): item 1 (Mac
  build) RETRIED — Mac online, swift resolves, sources present,
  but the GUI wall is unchanged: open_app Xcode → "The app's
  process identity could not be verified" (same as 05:03),
  open_app file_path Package.swift refused (.swift not an
  openable type), and Terminal is explicitly not available
  for computer control. Build still needs Marcus's hand (open
  Package.swift in Xcode → ⌘R, or run packaging/build-app.sh
  from Terminal). Took the pre-build sweep instead: balance
  checks all zero on every Swift file; full Scoring./
  Leaderboard. cross-reference sweep clean (all 29 Scoring +
  3 Leaderboard references in GameScene defined exactly).
  FOUND + FIXED a data trap (commit 31d6b8e): the four 2027
  monthly-drop releaseMonths were unpadded ("2027-1"…"2027-4")
  while 2026 drops were padded ("2026-11") — the split+Int
  parsers coped, but any string sort/compare would have
  broken. Normalized to zero-padded YYYY-MM, comment updated,
  and added testMonthlyDropSchedule locking the exact drop
  calendar (Istanbul 2026-11 → Auckland 2027-04, one per
  month, enum order = drop order, all YYYY-MM) plus the
  EXACT $177.9T world total (was only asserted ≥$100T).
  New test mirror-verified in Python against the raw data.
  Fix applied to BOTH copies: Mac Models.swift and
  ScoringTests.swift upload-back MD5s identical to local
  (c33da659… / 8050cd61…). GitHub repo not reachable yet
  (get_file_contents → 404).
- 05:03 PDT — OVERNIGHT RUN (kaiju-overnight): MAC SYNC COMPLETE
  (item 1, first half DONE). The schedule's device grant works
  again — files.* all OK. Synced the four stale/missing files to
  ~/Developer/mac-games/kaiju-rampage/ and verified EVERY file by
  upload-back MD5/diff: Scoring.swift (rewrote, md5 match),
  ScoringTests.swift (rewrote, md5 match), Models.swift (Mac copy
  was content-identical + 5 trailing blank lines — trimmed, now
  71,090 exact), GameScene.swift (was MISSING on the Mac; synced
  in 13 sentinel-appended chunks, 208,074 B, final md5 IDENTICAL
  after fixing a dropped blank line at 350 + a trailing blank).
  Package/ContentView/App/Leaderboard were already byte-exact.
  FOUND + FIXED 3 more undefined symbols the 04:47 sweep missed
  (would have failed the build): SoundBank.shared.basso →
  playSFX("Basso"), money(x) → Scoring.formatDollars(x) ×2,
  spawnDebris → debris(count:big:) — commit 17f22a2, applied to
  BOTH copies, Mac GameScene md5 re-verified identical after the
  fixes (28c9a962…). Balance checks all zero. XCODE LAUNCH STILL
  BLOCKED at the computer-control layer: open_app Xcode →
  "The app's process identity could not be verified" (×3, fresh
  sessions too); open_app file_path refuses .swift; Finder window
  won't bind (window_id_unresolved, dual-display). Xcode.app IS
  installed and /usr/bin/xcodebuild + swift resolve. Next step
  for whoever can drive the GUI / Marcus: open
  ~/Developer/mac-games/kaiju-rampage/Package.swift in Xcode →
  ⌘R; or run packaging/build-app.sh from Terminal (it does
  swift build + .app assembly + codesign + zip in one go).
  GitHub repo not reachable yet (get_file_contents → 404).
- 04:20 PDT — SELLOUT FLOW + SEASON ROLLOVER AUDITS (main chat):
  ad cap is enforced at menu open, digits route to playAd only
  while the menu shows, all input locks during playback, payout
  and the daily count persist exactly once at completion, and
  clearOverlay wipes click targets on every transition (no stale
  clicks). Rollover: seasonKey is computed per access, bank wipes
  and the Snitch re-rolls on month change, city progress is
  season-keyed so last month's rubble can't leak. One hygiene fix:
  startNewSnitchHunt's re-roll guard now checks availableCities.
- 04:17 PDT — SCOPE CHANGE (Marcus): Food Truck Rush descoped —
  "don't use any tokens for food truck rush. devote all tokens to
  kaiju rampage." Items 1 and 10 rewritten Kaiju-only; hard rules
  updated. FTR stays intact on disk (polish commit f6438fb and its
  CI stand); no further FTR tokens until Marcus says otherwise.
- 03:58 PDT — OVERNIGHT RUN (kaiju-overnight): item 1 (Mac build)
  still BLOCKED — device.list returns the same non-retryable
  "schedule lacks owner-authorized device access" as the 03:13
  run; no device calls possible from this schedule until the
  grant is reviewed. GitHub repo not reachable yet
  (get_file_contents → 404). Took the pre-final sweep instead:
  balance checks all zero on every Swift file in BOTH games;
  full Scoring./Leaderboard. cross-reference sweep clean (the one
  submitScore hit is GKLeaderboard's). FOUND + FIXED a real
  contract bug: Scoring.percentDestroyed documented 0...100 but
  only clamped the top — a negative destroyed value returned a
  negative percent; now max(0, min(100, ...)). Added boundary
  tests: testRankBoundariesAndVerdicts (85/65/45/25 floors +
  all five verdict lines), testPercentDestroyedClampsLow,
  testFormatDollarsEdges (0, sub-million, whole-unit trimming,
  BILLION/TRILLION floors) — formatDollars expectations
  mirror-verified in Python. Items 2–9 all done; only item 1
  (device-grant-blocked) and item 10 (final, ≥11:15) remain.
- 05:28 PDT — testMaldoReward FIXED (main chat): the test still
  expected the old $250k bounty while the code pays Marcus's $1B
  bounty — implementation right, test stale from before the money
  rescale; would have failed `swift test` and CI. Now asserts the
  $1B canon. Full assertion sweep of both games' tests vs code:
  everything else agrees. (03:13 run flagged it — good catch.)
- 03:13 PDT — OVERNIGHT RUN (kaiju-overnight): MAC SYNC (item 1,
  partial). Mac was ONLINE; ~/Developer/mac-games/ was empty, so
  synced sources via device files.write/edit with byte-count
  verification (+ upload-back cmp where done). BYTE-EXACT on the
  Mac: both Package.swift, both ContentView.swift, both App files,
  Kaiju Leaderboard.swift, Kaiju Scoring.swift (after fixing a
  dropped "$" in formatDollars found by cmp), Kaiju ScoringTests
  (14,574), FTR Scoring/Tests, packaging/build-app.sh, and FTR
  GameScene.swift (cmp IDENTICAL). Models.swift fully written but
  71,095 vs 71,090 local (+5 bytes, UNVERIFIED — diff it first
  next run). Kaiju GameScene.swift (208,076 B) NOT yet synced.
  THEN: device access revoked mid-run ("schedule lacks
  owner-authorized device access", non-retryable) — uploads and
  further device calls blocked until the schedule's device grant
  is reviewed. Xcode build not yet attempted. ALSO FLAGGED:
  testMaldoReward expects a 250k bounty (350_000 for 100k damage)
  but Scoring.maldoBounty is $1B per the 02:31 money-scale canon —
  swift test WILL fail that test until the test is updated to
  canon (expected 1_000_100_000 / 1_000_200_000). GitHub repo not
  reachable yet (get_file_contents → 404).
- 05:00 PDT — HUNT-BANK MATH AUDIT (main chat): traced every fold
  path by hand — visit entry (huntBankAtEntry/foldedAtEntry), the
  10s autosaves, and all three exits (leave / clock spent / crush)
  count each visit's damage exactly once; ad payouts between
  visits enter through the persisted bank; a mid-visit quit loses
  at most the last <10s (autosave), never double-pays, because
  restored rubble carries its reduced HP. No fix needed.
- 04:52 PDT — CATALOG MIRROR SIMULATION (main chat): the Swift
  test-suite's catalog assertions re-run in Python against the
  raw Models/Scoring data — 24 fighters all in the 55–85 DPS
  band, 36 cities complete (shops/palette/heights/crowds/density
  all pass), world total exactly $177.9T, 30 launch + 6 monthly
  drops (one per month, Nov 2026 → Apr 2027), NYC parody set
  present, ad-menu pricing rules hold. No violations.
- 04:47 PDT — DEFINITION CROSS-CHECK (main chat): swept every
  `Scoring.` / `Leaderboard.` / spec-property reference in
  GameScene.swift against its definitions — caught a REAL one:
  `Scoring.specialMultiplier` was used by trySpecial but defined
  nowhere (lost in an overnight Scoring rewrite; would have failed
  the Mac build). Restored (= 2) + testSpecialMultiplier. All
  cross-checks now clean in both games. Runs: make this sweep part
  of every future pre-final pass, not just per-feature greps.
- 04:31 PDT — FOOD TRUCK POLISH (roadmap item 9, main chat): see
  item 9 DONE note (food-truck-rush f6438fb). Every roadmap item
  is now done except item 1 (Mac build — GUI display wall; keeps
  retrying) and item 10 (final wrap-up at/after 11:15 PDT).
- 04:22 PDT — HOW-TO + PAUSE POLISH (roadmap item 7, main chat):
  H-card, pause rule lines, master mute via playSFX, persisted —
  see item 7 DONE note. Roadmap now: only item 1 (Mac build,
  GUI-blocked) and item 9 (Food Truck polish) remain before final.
- 04:12 PDT — MOVING TRAFFIC (roadmap item 5, main chat): two-lane
  drawn traffic, honking for peds, flee speeds, crunchable — see
  item 5 DONE note. Remaining roadmap: 1 (Mac build, GUI-blocked),
  7 (how-to + pause polish), 9 (Food Truck, only if 1–8 done).
- 04:02 PDT — MID-RUN EVENTS (roadmap item 4, main chat) + DISTRI-
  BUTION POLICY (Marcus): Mac App Store is optional and strictly
  as-is — NEVER sacrifice humor or content to get listed; if Apple
  is too conservative we walk away. Primary channels: Steam, Epic,
  and our own website. The game must play on Mac AND Windows (Godot
  port is required launch work, not a someday plan). FREE to
  download and play; ads are optional — the Sellout Menu (real
  sponsors) is the entire revenue model. STORE_LAUNCH_PLAN.md
  revised to match.
- 03:52 PDT — DAMAGE JUICE (roadmap item 3, main chat): cracks,
  dust, damage numbers, lunge, arrival roar — see item 3 DONE note.
- 03:44 PDT — RUN EXTENDED TO 12:00 PM (Marcus) + COMBO SYSTEM
  (roadmap item 2, main chat): cron retimed (final run ≥11:15,
  self-removes after the noon report). Combo shipped as specced —
  see item 2's DONE note. GitHub repo still 404 as of 02:37.
- 03:31 PDT — REAL SPONSORS (Marcus): the Sellout Menu sells slots
  to REAL companies for real money — that is the monetization. The
  parody entries are now explicitly HOUSE ADS filling unsold
  inventory (`house: true` on all six AdOffers; menu rows tag them
  "HOUSE AD — THIS SLOT IS FOR SALE"). Rate card + pitch notes in
  SPONSORS.md (founding rates $29–$499/mo by tier; premium 60s is
  the flagship; placement sold, not impressions, until audience).
  First real sponsor = swap one AdOffer (house: false) + update
  the house-count assertion. Video playback (AVPlayer) slots in
  behind the same menu when a sponsor signs.
- 03:20 PDT — SELLOUT CATALOG TIERS (Marcus): the menu is now a
  priced catalog, best slots first — ADIDASS holds the PREMIUM
  placement (gold frame, top slot): 60 seconds pays $7.2T
  (120B/sec); Mama's own insurance co. 30s/$3T (100B/s); Planet
  Fatness 20s/$1.5T; N&N's 15s/$1T; WackDonald's 10s/$600B; Bolex
  5s/$250B. Rule encoded in tests: longer slot = more total AND
  more per second, exactly one premium slot, premium pays most.
  (Mama is presumably furious ADIDASS outbid her for the top.)
- 03:12 PDT — 30 CITIES + MONTHLY DROPS + SELLOUT MENU (Marcus):
  catalog is now 36 cities — 30 playable at launch (Rome, Madrid,
  Amsterdam, Bangkok, Mumbai, Beijing, Mexico City, São Paulo,
  Buenos Aires, Miami, Seattle, Washington DC, Cairo joined the
  original 17) plus 6 locked monthly drops (Istanbul Nov 2026,
  Moscow Dec, Athens Jan 2027, Prague Feb, Cape Town Mar, Auckland
  Apr). Locked cities show "🔒 DROPS <MONTH>" and can't be picked;
  the Snitch only hides in unlocked cities. World total $177.9T.
  The 100-city plan is CANCELLED — monthly drops are the model.
  Monetization: the SELLOUT MENU on city select ("WATCH ADS TO GET
  POINTS — YOU SELL OUT") lists 5 advertisers with tiers — BOLEX
  5s/$250B, WackDonald's 10s/$600B, N&N's 15s/$1T, Planet Fatness
  20s/$1.5T, Mama's Planet Insurance 30s/$3T. Points are claim
  dollars into the hunt bank; longer ads pay more per second
  (premium placement); ads unskippable; 10/day cap. Catalog
  invariants machine-checked (shops, crowds, mixes all pass).
- 03:02 PDT — REPAIR + RENAME: two large single edits (the
  city-clock helper block and the Mama declaration block) had
  silently failed to land while their call sites did — caught by a
  definition audit (every referenced helper greps to exactly one
  definition). Both blocks re-inserted in small chunks and
  verified. Overnight runs: after ANY edit batch, grep-verify that
  new function definitions exist; never trust a success report on a
  big insertion. Same commit: Marcus renamed all 24 fighters to
  classic 50s names (Rose, Bonnie, Nancy, Petunia, Bertha, Doris…)
  with a gruesome pass (snarls, brows, drool, scars, clawed fists)
  — sweet names, horrifying girls.
- 02:52 PDT — VERY DIFFERENT FIGHTERS (Marcus): every one of the
  24 now carries drawn signature features (Bruno's knuckle arms,
  Gorgo's teeth + tiny arm, Kraken's dome eyes + beak, Arachnia's
  8 eyes, Dunemaw's segments + maw teeth, Spectra's wisps + hollow
  eyes, Voltina's coils + tongue, Magmor's lava cracks, Yetira's
  tusks, Mako's gills + tail fin, Krawl's ONE giant claw, Noctura's
  fangs, Pyra's flame crest, Razorback's tail club, Mecha-Rex's
  exhausts + steel jaw, Titan-9's missile pods, Crusher's wrecking
  ball, Scrapjack's magnet + junk pile, Voltbot's tesla coils,
  Sentinel's solar panels + dish — plus the pre-existing hydra
  heads / scorpius stinger / behemoth horn / zorgath stalks).
  BodyPlan dims re-spread so testBodyPlansAllDifferent now also
  enforces a pairwise NO-NEAR-TWINS rule (≥18% on some axis for any
  same shape+legs+head-placement pair).
- 02:44 PDT — THE PREMISE + MAMA'S VOICE (Marcus): all 24 fighters
  are one alien MAMA's kids (robots = her builds). Mama took out an
  insurance policy on planet Earth; wreck it and silence the Golden
  Snitch before he informs the ALIEN COPS or the plot's exposed and
  the policy pays nothing. Mama chimes in FROM THE HEAVENS at
  random (55–130s intervals in play): gold text descending on
  screen + real spoken voice (AVSpeechSynthesizer, low pitch, slow)
  — lines incl. Marcus's "DON'T YOU FUCK THIS UP, MY BOY!" — plus
  contextual chimes (launch greeting, snitch-city warning, catch
  praise). M mutes her. The premise is printed on the monster
  select screen. Overnight runs: Mama's voice/tone is canonical —
  keep her lines in her voice, profanity included where Marcus put
  it; never make her polite.
- 02:38 PDT — Marcus's CITY CLOCKS: every city gets at most ONE
  HOUR per season (Scoring.cityBudgetSeconds = 3600). Leave anytime
  (Q/F) — the city freezes exactly: clock, building rubble (seeded
  SplitMix64 generation per city+season makes layouts identical
  across visits), props, bank (10s autosave snapshots; damageFolded
  prevents double-pay). Return and continue later — even after
  crushing the Snitch there in 30 seconds (the catch persists in
  the city's progress; the lock-in lands when a visit ends). The
  old 60/120/180/free-play timer screen is RETIRED (TimerOption
  enum kept only for the catalog test). Spent cities show CLOSED
  on the select screen; in-progress cities show time left + FROZEN.
- 02:31 PDT — Marcus set the MONEY SCALE: damage pays realistic
  sums. Every city carries a realistic total built-asset value
  (CitySpec.destructionValue; Tokyo $14T, NYC $12T, London $11T…;
  17 cities = $113.5T). Scoring.claimRate converts HP→dollars so
  100% destruction pays the full city value (hits ⅔, collapse ⅓,
  landmark surcharge 5% of city value). Crowd = per-person liability
  ($10M walker … $50M big), Maldo bounty $1B. formatDollars reads in
  units up to QUADRILLION; Earth's appraised value ≈ $5 quadrillion
  (Laughlin) is the planetary ceiling a perfect season approaches.
  Overnight runs: keep this scale — never reintroduce flat $1k hits.
- 01:42 PDT — run created. v2 + Maldo/crowd/WackDonald's committed
  (49184b5, 6da1e79). Balance checks all zero. Mac build not yet done.
- 02:22 PDT — Marcus added the SEASON clock (final endgame layer):
  the hunt runs on a calendar month — timer starts midnight on the
  1st (season key kaijurampage.hunt.season.v1; month rollover =
  new Snitch city + bank wiped — unclaimed points evaporate). The
  longer the hunt takes, the bigger the penalty: −2% of the lock-in
  per day after the 1st (Scoring.snitchPenaltyPercent; day 11 =
  −20%, day 31 = −60%), shown live on city select + results. Points
  display on the leaderboard ONLY when the month's Snitch is found
  (locked entry, mode "SNITCH · DAY N"). The intended tension, in
  Marcus's words: rack up points destroying everything vs. find the
  Snitch before the penalty eats the ×10. Overnight runs: preserve
  the season/penalty math exactly (pure functions in Scoring.swift).
- 02:16 PDT — Marcus sharpened the endgame again (supersedes the
  02:10 ×10-at-crush version): THE GAME DOESN'T END UNTIL THE
  SNITCH IS CRUSHED. Every run banks its damage into a persistent
  hunt bank (UserDefaults kaijurampage.hunt.bank.v1, shown in HUD +
  city select); nothing locks in, ever, until a run crushes him —
  then (bank + final run) × 10 = ONE leaderboard entry (mode
  "HUNT · N DAYS"), bank zeroes, new Snitch/new hunt. No-crush runs
  record NOTHING (no entry, no best). The crush itself pays nothing
  mid-run; the lock-in lands at that run's results. Overnight runs:
  this bank/lock-in structure is canonical — don't simplify it back
  to per-run tallying.
- 02:10 PDT — Marcus replaced the Snitch endgame: NO world reset,
  NO +5 years (all removed). Final rules: crush the Snitch and your
  run points go ×10 (Scoring.snitchBonus tops the total up to 10×),
  and a run's score is tallied into the leaderboard (and personal
  best) ONLY if the Snitch was crushed in it — otherwise the results
  screen shows "SCORE NOT TALLIED — THE GOLDEN SNITCH STILL HIDES".
  After a crush, a new Snitch hides in a different city (new hunt,
  day counter restarts). Overnight runs: never re-add time jumps or
  flat snitch payouts; the ×10 + tally-gate is the design.
- 02:04 PDT — Marcus corrected the Snitch twice: NOT tied to any
  police department ("nvm he's in just one police department… he's
  just out there talking to a cop somewhere out in the world"). PD
  building variant REMOVED entirely. Final design: the Snitch hides
  somewhere in ONE saved city; each run in that city he stands at a
  random street spot (re-rolled per run — patrol the whole street)
  talking to ONE cop (banter bubbles); monster closes in → cop books
  it down the street, Snitch bolts; off the block edge = "VANISHED
  INTO THE CITY", hunt continues. Crush = $1M + world reset +5 years,
  unchanged. Overnight runs: do not re-add a precinct/PD anchor.
- 02:00 PDT — Marcus: population must represent each city's real
  people + THE GOLDEN SNITCH design finalized across three messages.
  Shipped both: (1) Crowd representation — every CitySpec carries
  crowdSkin (skin tones weighted to real demographics), crowdClothes
  (local dress), crowdDensity (Tokyo/Shanghai 34 … Sydney 22);
  buildPedestrian draws from the city's own mix; unit-tested
  (testCrowdRepresentsEachCity). (2) THE GOLDEN SNITCH — persistent
  per-account hunt: exactly ONE snitch in the whole world, at the ONE
  police department (navy/gold PD building variant + 🚔 prop), in ONE
  saved city (UserDefaults kaijurampage.snitch.*); he stands out front
  TALKING TO ONE POLICE OFFICER (alternating random banter bubbles)
  until the monster closes in — officer dives inside, Snitch bolts
  (242 pt/s, little golden wings flapping, hover-bob, up to 3 dodges);
  slipping off the block = back inside, hunt continues. CRUSH him =
  +$1,000,000, the WORLD RESETS and the year jumps +5 (saved world
  year, shown on city select with hunt day count), new snitch hides in
  a different city, hunt timer restarts. Also fixed: city count is 17
  (test said 16 — corrected; SF was the 17th) and city keyboard paging
  now uses the real page count (was % 2, page 3 unreachable).
- 01:52 PDT — Marcus: "all the monsters different shapes and sizes" +
  "hyper super duper realistic in terms of representation of elements."
  Shipped: BodyPlan system (all 24 fighters distinct silhouettes, unit-
  tested) + city elements completeness pass: sidewalk with expansion
  joints, manholes, clouds, birds, traffic lights at every cross
  street, street lamps, street trees, correct transit entrances
  (NYC SUBWAY / Paris MÉTRO / Tokyo METRO / London UNDERGROUND roundel
  / bus shelters elsewhere), drawn fire-hydrant props, mailbox/newsbox/
  bus-stop props. Balance checks zero.
- 01:47 PDT — Drive zip refreshed with current sources (file
  1KABMc6o-…Ql5) and shared anyone-with-link; Mac confirmed online;
  Chrome window on the external display still hits the geometry wall,
  Safari launch unverified. GitHub: create_repository 403 (app can't
  create repos) — Marcus asked to create marcusykim/kaiju-rampage
  public + include it in the Muse GitHub App installation; cron body
  updated to snapshot-push after every commit once reachable.
- 02:28 PDT — OVERNIGHT RUN (kaiju-overnight): items 1–7 were blocked
  at run start by in-flight main-chat edits in the working tree
  (Sellout Menu + 36-city monthly drops, uncommitted at 02:28). Took
  item 8 instead: STORE PACK done — ~/workspace/mac-games/
  STORE_LAUNCH_PLAN.md (Mac App Store listing copy, Game Center
  leaderboard steps for kaijurampage.damage + the gameCenterEnabled
  flip, 6-shot screenshot list, Steam + Epic copy with their $100
  fees flagged Marcus-only, Godot Windows-port scope/estimate).
  Updated mid-run to the committed canon (d843b9a: 36 cities =
  30 launch + 6 monthly drops, $177.9T world, Sellout Menu pricing).
  Balance checks all zero on every Swift file. GitHub repo not
  reachable yet (get_file_contents → 404).
