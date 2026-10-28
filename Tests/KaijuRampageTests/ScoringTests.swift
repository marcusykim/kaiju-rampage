import XCTest
@testable import KaijuRampage

final class ScoringTests: XCTestCase {
    func testClaimMath() {
        // Real-scale money: flattening 100% of a city pays exactly
        // its realistic total asset value (hits ⅔ + collapse ⅓).
        let rate = Scoring.claimRate(cityValue: 12_000_000_000_000, totalHP: 6_000)
        XCTAssertEqual(rate, 2_000_000_000, accuracy: 1)
        XCTAssertEqual(Scoring.hitClaimDollars(hpDealt: 300, rate: rate), 400_000_000_000)
        XCTAssertEqual(Scoring.collapseClaimDollars(maxHP: 300, rate: rate), 200_000_000_000)
        XCTAssertEqual(Scoring.hitClaimDollars(hpDealt: 300, rate: rate)
            + Scoring.collapseClaimDollars(maxHP: 300, rate: rate), 600_000_000_000)
        XCTAssertEqual(Scoring.propClaimDollars(rate: rate), 40_000_000_000)
        XCTAssertEqual(Scoring.landmarkSurcharge(cityValue: 12_000_000_000_000), 600_000_000_000)
        XCTAssertEqual(Scoring.claimRate(cityValue: 100, totalHP: 0), 0)
    }

    func testPercentDestroyed() {
        XCTAssertEqual(Scoring.percentDestroyed(destroyedValue: 50, totalValue: 100), 50)
        XCTAssertEqual(Scoring.percentDestroyed(destroyedValue: 150, totalValue: 100), 100)
        XCTAssertEqual(Scoring.percentDestroyed(destroyedValue: 10, totalValue: 0), 0)
    }

    func testRanks() {
        XCTAssertEqual(Scoring.rank(percentDestroyed: 90), "S")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 70), "A")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 50), "B")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 30), "C")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 5), "D")
    }

    func testRankBoundariesAndVerdicts() {
        // Rank thresholds are inclusive at the floor of each band.
        XCTAssertEqual(Scoring.rank(percentDestroyed: 100), "S")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 85), "S")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 84), "A")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 65), "A")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 64), "B")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 45), "B")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 44), "C")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 25), "C")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 24), "D")
        XCTAssertEqual(Scoring.rank(percentDestroyed: 0), "D")
        // Every rank has its own verdict line, in Mama's spirit.
        XCTAssertEqual(Scoring.verdict(rank: "S"), "TOTAL ANNIHILATION. THE MAP NEEDS REDRAWING.")
        XCTAssertEqual(Scoring.verdict(rank: "A"), "THE CITY WILL NEVER RECOVER. GREAT WORK.")
        XCTAssertEqual(Scoring.verdict(rank: "B"), "SERIOUS STRUCTURAL REGRET ACROSS THE CITY.")
        XCTAssertEqual(Scoring.verdict(rank: "C"), "A RESPECTABLE RAMPAGE. THE CITY NOTICED.")
        XCTAssertEqual(Scoring.verdict(rank: "D"), "MILD VANDALISM. THE CITY BARELY WOKE UP.")
        XCTAssertEqual(Scoring.verdict(rank: "?"), "MILD VANDALISM. THE CITY BARELY WOKE UP.")
    }

    func testPercentDestroyedClampsLow() {
        // The contract is 0...100 both ways: a negative destroyed
        // value (never in normal play) must not show a negative %.
        XCTAssertEqual(Scoring.percentDestroyed(destroyedValue: -50, totalValue: 100), 0)
        XCTAssertEqual(Scoring.percentDestroyed(destroyedValue: 0, totalValue: 100), 0)
    }

    func testFormatDollarsEdges() {
        XCTAssertEqual(Scoring.formatDollars(0), "$0")
        XCTAssertEqual(Scoring.formatDollars(999_999), "$999,999")
        XCTAssertEqual(Scoring.formatDollars(1_000_000), "$1 MILLION")
        XCTAssertEqual(Scoring.formatDollars(1_000_000_000), "$1 BILLION")
        XCTAssertEqual(Scoring.formatDollars(1_000_000_000_000), "$1 TRILLION")
        XCTAssertEqual(Scoring.formatDollars(10_500_000_000), "$10.5 BILLION")
    }

    func testCrowdRepresentsEachCity() {
        // Every city's crowd is drawn from its own demographic mix —
        // weighted skin tones, local clothes, and its street density.
        for city in CityKind.allCases {
            XCTAssertGreaterThanOrEqualTo(city.crowdSkin.count, 6, city.name)
            XCTAssertGreaterThanOrEqualTo(city.crowdClothes.count, 4, city.name)
            XCTAssertTrue((18...36).contains(city.crowdDensity), city.name)
        }
        // No two cities share the exact same skin mix — Tokyo is not Rio.
        let mixes = Set(CityKind.allCases.map { $0.crowdSkin.map { "\($0.r)" }.joined(separator: ",") })
        XCTAssertEqual(mixes.count, CityKind.allCases.count)
        // Across the whole world the full human range shows up.
        let allTones = CityKind.allCases.flatMap { $0.crowdSkin }
        let lum = allTones.map { 0.3 * $0.r + 0.5 * $0.g + 0.2 * $0.b }
        XCTAssertLessThan(lum.min()!, 0.30)
        XCTAssertGreaterThan(lum.max()!, 0.75)
        // Density tracks real crowding: Tokyo/Shanghai top the table.
        XCTAssertGreaterThanOrEqualTo(CityKind.tokyo.crowdDensity, 32)
        XCTAssertLessThan(CityKind.sydney.crowdDensity, CityKind.tokyo.crowdDensity)
    }

    func testSnitchReward() {
        // The hunt lock-in: banked points from every run of the hunt
        // plus the final run, all multiplied by 10 when — and only
        // when — the Golden Snitch is crushed.
        XCTAssertEqual(Scoring.snitchMultiplier, 10)
        // The month clock: 2% penalty per day after the 1st.
        XCTAssertEqual(Scoring.snitchPenaltyPercent(dayOfMonth: 1), 0)
        XCTAssertEqual(Scoring.snitchPenaltyPercent(dayOfMonth: 11), 20)
        XCTAssertEqual(Scoring.snitchPenaltyPercent(dayOfMonth: 31), 60)
        XCTAssertEqual(Scoring.huntLockIn(bank: 1_000, runDamage: 500, dayOfMonth: 1), 15_000)
        XCTAssertEqual(Scoring.huntLockIn(bank: 1_000, runDamage: 500, dayOfMonth: 11), 12_000)
        XCTAssertEqual(Scoring.huntLockIn(bank: 0, runDamage: 250_000, dayOfMonth: 31), 1_000_000)
        XCTAssertEqual(Scoring.huntLockIn(bank: 0, runDamage: 0, dayOfMonth: 15), 0)
    }

    func testMaldoReward() {
        // Doubling + bounty: the reward equals everything earned so
        // far (that's the doubling) PLUS the flat $1 BILLION bounty
        // from the realistic-money scale. (A stale $250k-bounty
        // version of this test survived the money rescale — caught
        // by the 03:13 overnight run; implementation was right.)
        XCTAssertEqual(Scoring.maldoBounty, 1_000_000_000)
        XCTAssertEqual(Scoring.maldoReward(currentDamage: 0), Scoring.maldoBounty)
        XCTAssertEqual(Scoring.maldoReward(currentDamage: 100_000), 1_000_100_000)
        XCTAssertEqual(Scoring.maldoReward(currentDamage: 100_000) + 100_000, 1_000_200_000)
    }

    func testPedestrianValues() {
        // The bigger the squash, the bigger the payout.
        XCTAssertLessThan(Scoring.pedestrianValue, Scoring.dancerValue)
        XCTAssertLessThan(Scoring.dancerValue, Scoring.influencerValue)
        XCTAssertLessThan(Scoring.influencerValue, Scoring.bigPedestrianValue)
    }

    func testBodyPlansAllDifferent() {
        // Marcus's rule: every monster a different shape and size.
        var seen = Set<String>()
        for m in MonsterKind.allCases {
            let p = m.bodyPlan
            let key = "\(p.shape)-\(p.legs)-\(p.bodyW)-\(p.bodyH)-\(p.headR)-\(p.headAtFront)"
            XCTAssertFalse(seen.contains(key), "Duplicate body plan: \(m.name)")
            seen.insert(key)
            XCTAssertGreaterThan(p.bodyW, 0, m.name)
            XCTAssertGreaterThan(p.bodyH, 0, m.name)
            XCTAssertGreaterThan(p.headR, 0, m.name)
        }
        XCTAssertEqual(seen.count, 24)
        // VERY different (Marcus, 2026-10-28): no near-twins. Any two
        // fighters sharing shape, legs, and head placement must still
        // differ by at least 18% on some body dimension.
        let all = MonsterKind.allCases
        for i in all.indices {
            for j in all.indices where j > i {
                let a = all[i].bodyPlan, b = all[j].bodyPlan
                if a.shape == b.shape && a.legs == b.legs && a.headAtFront == b.headAtFront {
                    let dW = Double(abs(a.bodyW - b.bodyW)) / Double(min(a.bodyW, b.bodyW))
                    let dH = Double(abs(a.bodyH - b.bodyH)) / Double(min(a.bodyH, b.bodyH))
                    let dR = Double(abs(a.headR - b.headR)) / Double(min(a.headR, b.headR))
                    XCTAssertTrue(dW >= 0.18 || dH >= 0.18 || dR >= 0.18,
                                  "Near-twins: \(all[i].name) vs \(all[j].name)")
                }
            }
        }
        let widths = MonsterKind.allCases.map { $0.bodyPlan.bodyW }
        XCTAssertLessThanOrEqualTo(widths.min()!, 80)
        XCTAssertGreaterThanOrEqualTo(widths.max()!, 170)
        let heights = MonsterKind.allCases.map { $0.bodyPlan.bodyH }
        XCTAssertLessThanOrEqualTo(heights.min()!, 40)
        XCTAssertGreaterThanOrEqualTo(heights.max()!, 120)
        // Real variety in how they move: at least 4 leg styles in use,
        // and the serpent, worm, ghost, and hover-bot truly have no legs.
        XCTAssertGreaterThanOrEqualTo(Set(MonsterKind.allCases.map { "\($0.bodyPlan.legs)" }).count, 4)
        for m in [MonsterKind.voltina, .dunemaw, .spectra, .sentinel] {
            XCTAssertEqual(m.bodyPlan.legs, .none, m.name)
        }
    }

    func testCityProgress() {
        // One hour per city per season; leaving freezes it; the
        // frozen state round-trips through Codable untouched.
        XCTAssertEqual(Scoring.cityBudgetSeconds, 3600)
        var p = CityProgress()
        XCTAssertFalse(p.spent)
        p.elapsed = 1800
        XCTAssertFalse(p.spent)
        p.elapsed = 3600
        XCTAssertTrue(p.spent)
        p.buildingHP = ["3": 0, "7": 120]
        p.deadProps = [1, 2]
        p.damageFolded = 5_000_000_000
        let data = try! JSONEncoder().encode(p)
        let back = try! JSONDecoder().decode(CityProgress.self, from: data)
        XCTAssertEqual(back.buildingHP["7"], 120)
        XCTAssertEqual(back.deadProps, [1, 2])
        XCTAssertEqual(back.damageFolded, 5_000_000_000)
        XCTAssertTrue(back.spent)
    }

    func testLegacySavesStillDecode() {
        // Saves written before snitchCaught/snitchDay existed lack
        // those keys; synthesized Codable would fail the whole
        // decode and wipe every city's frozen progress. Tolerant
        // decoding must keep the fields that ARE there.
        let legacyCity = """
        {"3":{"elapsed":1200.5,"buildingHP":{"7":120},"deadProps":[1,2],"damageFolded":5000000000}}
        """
        let cities = try! JSONDecoder().decode(
            [Int: CityProgress].self, from: Data(legacyCity.utf8))
        XCTAssertEqual(cities[3]?.elapsed, 1200.5)
        XCTAssertEqual(cities[3]?.buildingHP["7"], 120)
        XCTAssertEqual(cities[3]?.deadProps, [1, 2])
        XCTAssertEqual(cities[3]?.damageFolded, 5_000_000_000)
        XCTAssertEqual(cities[3]?.snitchCaught, false)
        XCTAssertEqual(cities[3]?.snitchDay, 0)
        // Same for the leaderboard: an entry missing newer keys
        // decodes with defaults instead of emptying the board.
        let legacyBoard = """
        [{"damage":42000000000,"percent":55,"monster":"Rose","city":"Paris"}]
        """
        let board = try! JSONDecoder().decode(
            [ScoreEntry].self, from: Data(legacyBoard.utf8))
        XCTAssertEqual(board.count, 1)
        XCTAssertEqual(board[0].damage, 42_000_000_000)
        XCTAssertEqual(board[0].monster, "Rose")
        XCTAssertEqual(board[0].mode, "")
    }

    func testCatalogIsComplete() {
        XCTAssertEqual(MonsterKind.allCases.count, 24)
        XCTAssertEqual(MonsterKind.allCases.filter { $0.isRobot }.count, 6)
        XCTAssertEqual(MonsterKind.allCases.filter { !$0.isRobot }.count, 18)
        XCTAssertEqual(CityKind.allCases.count, 36)
        XCTAssertEqual(TimerOption.allCases.map { $0.rawValue }, [60, 120, 180, 0])
        XCTAssertTrue(TimerOption.freePlay.isFreePlay)
        XCTAssertFalse(TimerOption.sixty.isFreePlay)
        for m in MonsterKind.allCases {
            XCTAssertGreaterThan(m.power, 0, m.name)
            XCTAssertGreaterThan(m.speed, 0, m.name)
            XCTAssertGreaterThan(m.attackInterval, 0, m.name)
            XCTAssertFalse(m.specialName.isEmpty, m.name)
            // Roster-wide fairness: every fighter's DPS stays in one band.
            let dps = Double(m.power) / m.attackInterval
            XCTAssertTrue((55...85).contains(dps), "\(m.name) DPS \(dps) out of band")
        }
        for c in CityKind.allCases {
            XCTAssertFalse(c.buildingNames.isEmpty, c.name)
            XCTAssertFalse(c.landmarkName.isEmpty, c.name)
            XCTAssertGreaterThanOrEqualTo(c.buildingPalette.count, 3, c.name)
            // The completeness spec: every city ships its real street,
            // parody storefronts, street furniture, and cross streets.
            XCTAssertFalse(c.streetName.isEmpty, c.name)
            XCTAssertFalse(c.district.isEmpty, c.name)
            XCTAssertGreaterThanOrEqualTo(c.shops.count, 8, c.name)
            XCTAssertGreaterThanOrEqualTo(c.propEmojis.count, 3, c.name)
            XCTAssertGreaterThanOrEqualTo(c.crossStreets.count, 3, c.name)
            XCTAssertLessThan(c.minBuildingH, c.maxBuildingH, c.name)
            // Real-scale money: every city carries a realistic total
            // asset value (hundreds of billions at the very least).
            XCTAssertGreaterThanOrEqualTo(c.destructionValue, 300_000_000_000, c.name)
        }
        // The whole world on the board is worth real money — the
        // catalog's cities sum to at least $100 trillion of assets.
        XCTAssertGreaterThanOrEqualTo(CityKind.allCases.reduce(0) { $0 + $1.destructionValue },
                                      100_000_000_000_000)
        // Marcus's named NYC parodies, spelled his way.
        let nyc = CityKind.newYork
        XCTAssertTrue(nyc.shops.contains("BOLEX"))
        XCTAssertTrue(nyc.shops.contains("N&N'S WORLD"))
        XCTAssertTrue(nyc.shops.contains("PLANET FATNESS"))
        XCTAssertTrue(nyc.shops.contains("ADIDASS"))
        // Monthly city drops: 30 cities playable at launch (Oct
        // 2026); the rest unlock at midnight on the 1st of their
        // release month and stay unlocked.
        let gcal = Calendar(identifier: .gregorian)
        let oct2026 = gcal.date(from: DateComponents(year: 2026, month: 10, day: 15))!
        let nov2026 = gcal.date(from: DateComponents(year: 2026, month: 11, day: 15))!
        XCTAssertEqual(CityKind.allCases.filter { $0.isAvailable(now: oct2026) }.count, 30)
        XCTAssertTrue(CityKind.paris.isAvailable(now: oct2026))
        XCTAssertFalse(CityKind.istanbul.isAvailable(now: oct2026))
        XCTAssertTrue(CityKind.istanbul.isAvailable(now: nov2026))
        XCTAssertFalse(CityKind.auckland.isAvailable(now: nov2026))
        // Sellout menu: six advertisers, best slots first. Longer
        // ads pay the player strictly more in total AND per second —
        // a 60-second slot outbids a 30-second one twice over. The
        // single premium placement sits on top and pays the most.
        XCTAssertEqual(Scoring.adMenu.count, 6)
        XCTAssertEqual(Scoring.dailyAdCap, 10)
        // Inventory snapshot: every slot is currently a house ad.
        // When the first real sponsor signs, flip their entry to
        // house: false and update this count (see SPONSORS.md).
        XCTAssertEqual(Scoring.adMenu.filter { $0.house }.count, 6)
        XCTAssertTrue(Scoring.adMenu[0].premium)
        XCTAssertEqual(Scoring.adMenu.filter { $0.premium }.count, 1)
        XCTAssertEqual(Scoring.adMenu[0].seconds, 60)
        XCTAssertEqual(Scoring.adMenu[0].payout, 7_200_000_000_000)
        for (a, b) in zip(Scoring.adMenu, Scoring.adMenu.dropFirst()) {
            XCTAssertGreaterThan(a.seconds, b.seconds)
            XCTAssertGreaterThan(a.payout, b.payout)
            XCTAssertGreaterThanOrEqualTo(Double(a.payout) / Double(a.seconds),
                                          Double(b.payout) / Double(b.seconds))
        }
    }

    func testMonthlyDropSchedule() {
        // The drop calendar is canon: exactly one new city on the
        // 1st of each month, Nov 2026 through Apr 2027, in order.
        XCTAssertEqual(CityKind.istanbul.releaseMonth, "2026-11")
        XCTAssertEqual(CityKind.moscow.releaseMonth, "2026-12")
        XCTAssertEqual(CityKind.athens.releaseMonth, "2027-01")
        XCTAssertEqual(CityKind.prague.releaseMonth, "2027-02")
        XCTAssertEqual(CityKind.capeTown.releaseMonth, "2027-03")
        XCTAssertEqual(CityKind.auckland.releaseMonth, "2027-04")
        // Every releaseMonth is zero-padded YYYY-MM so the strings
        // sort and compare correctly as-is.
        for c in CityKind.allCases {
            let parts = c.releaseMonth.split(separator: "-")
            XCTAssertEqual(parts.count, 2, c.name)
            XCTAssertEqual(parts[0].count, 4, c.name)
            XCTAssertEqual(parts[1].count, 2, c.name)
        }
        // 30 launch cities + exactly 6 distinct drop months, and
        // the enum order is the drop order.
        let drops = CityKind.allCases.map { $0.releaseMonth }.filter { $0 != "2026-10" }
        XCTAssertEqual(drops.count, 6)
        XCTAssertEqual(Set(drops).count, 6)
        XCTAssertEqual(drops.sorted(), drops)
        // The world total is exactly $177.9 trillion — no drift.
        XCTAssertEqual(CityKind.allCases.reduce(0) { $0 + $1.destructionValue },
                       177_900_000_000_000)
    }

    func testLeaderboardKeepsTopTenByDamage() {
        let board = (1...14).map {
            ScoreEntry(damage: $0 * 10_000, percent: $0, monster: "TEST", city: "PARIS", mode: "120 SECONDS", date: Date())
        }
        var result: [ScoreEntry] = []
        for entry in board { result = Leaderboard.record(entry) }
        XCTAssertEqual(result.count, 10)
        XCTAssertEqual(result.first?.damage, 140_000)
        XCTAssertTrue(result.allSatisfy { $0.damage >= 50_000 })
        XCTAssertEqual(result.map { $0.damage }, result.map { $0.damage }.sorted(by: >))
    }

    func testFormatDollars() {
        XCTAssertEqual(Scoring.formatDollars(250_000), "$250,000")
        XCTAssertEqual(Scoring.formatDollars(843_000_000), "$843 MILLION")
        XCTAssertEqual(Scoring.formatDollars(1_250_000), "$1.25 MILLION")
        XCTAssertEqual(Scoring.formatDollars(2_500_000_000_000), "$2.5 TRILLION")
        XCTAssertEqual(Scoring.formatDollars(14_000_000_000_000), "$14 TRILLION")
        XCTAssertEqual(Scoring.formatDollars(1_250_000_000_000_000), "$1.25 QUADRILLION")
        XCTAssertEqual(Scoring.formatDollars(5_000_000_000_000_000), "$5 QUADRILLION")
    }

    func testCombo() {
        // Every 10 chained hits raise the multiplier a level, ×5 max.
        XCTAssertEqual(Scoring.comboWindowSeconds, 1.4)
        XCTAssertEqual(Scoring.comboMultiplier(combo: 0), 1)
        XCTAssertEqual(Scoring.comboMultiplier(combo: 9), 1)
        XCTAssertEqual(Scoring.comboMultiplier(combo: 10), 2)
        XCTAssertEqual(Scoring.comboMultiplier(combo: 29), 3)
        XCTAssertEqual(Scoring.comboMultiplier(combo: 40), 5)
        XCTAssertEqual(Scoring.comboMultiplier(combo: 900), 5)
        XCTAssertEqual(Scoring.comboClaim(base: 100, combo: 0), 100)
        XCTAssertEqual(Scoring.comboClaim(base: 100, combo: 10), 200)
        XCTAssertEqual(Scoring.comboClaim(base: 100, combo: 45), 500)
    }

    func testSpecialMultiplier() {
        XCTAssertEqual(Scoring.specialMultiplier, 2)
    }

    func testCityEvents() {
        XCTAssertEqual(Scoring.CityEvent.allCases.count, 3)
        XCTAssertEqual(Scoring.eventDurationSeconds, 15)
        XCTAssertEqual(Scoring.eventPedMultiplier, 2)
        XCTAssertEqual(Scoring.rushHourExtraPeds, 14)
        XCTAssertEqual(Scoring.maldoManiaRespawnSeconds, 4)
    }
}
