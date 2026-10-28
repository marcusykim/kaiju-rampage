import Foundation

/// Destruction scoring — pure logic, unit-tested.
///
/// THE MONEY IS REAL-SCALE. Every city carries a realistic estimate
/// of its total built-asset value (Tokyo ≈ $14 trillion, New York
/// ≈ $12 trillion — in line with global real-estate wealth data).
/// The claim rate converts HP into dollars so flattening 100% of a
/// city pays its full value; the on-screen street stands in for the
/// whole city, the way a run "destroys a city in about an hour."
/// Bank a season of flattened cities, lock it in at ×10, and totals
/// climb toward the appraised value of the entire planet — about
/// $5 quadrillion (Greg Laughlin's valuation of Earth). Mama's
/// policy limit, conveniently.
public enum Scoring {
    /// Every city gets exactly one hour of destruction per season.
    /// Leave whenever you like — the clock freezes until you return.
    public static let cityBudgetSeconds: Double = 3600

    /// Special moves deal this multiple of the fighter's power.
    public static let specialMultiplier = 2

    /// Sellout economics: a menu of advertisers buy ad slots in
    /// the game. Points in this game ARE dollars — insurance-claim
    /// dollars that land in the hunt bank (and count once the
    /// Snitch is crushed and the bank locks in). Longer ads pay
    /// the player more, and advertisers pay more per second to
    /// buy the long slots — premium placement, like real ads.
    public struct AdOffer {
        public let brand: String
        public let emoji: String
        public let slogan: String
        public let seconds: Int
        public let payout: Int
        /// Premium placement: the advertiser paid extra to sit at
        /// the top of the Sellout Menu, gold-framed. It costs more
        /// because every player sees it first, every time.
        public let premium: Bool
        /// House ads fill slots no real sponsor has bought yet —
        /// our own parody brands keep the menu full and funny until
        /// a real company pays for the slot. When a sponsor signs,
        /// their entry replaces a house entry (same length/price
        /// tier, house: false) — see SPONSORS.md for the rate card.
        public let house: Bool
        public init(brand: String, emoji: String, slogan: String,
                    seconds: Int, payout: Int, premium: Bool = false,
                    house: Bool = false) {
            self.brand = brand
            self.emoji = emoji
            self.slogan = slogan
            self.seconds = seconds
            self.payout = payout
            self.premium = premium
            self.house = house
        }
    }
    /// The Sellout Menu, best slots first. A 60-second advertiser
    /// outbids a 30-second one twice over: more total payout AND a
    /// higher per-second rate — and premium placement costs extra
    /// on top of length.
    public static let adMenu: [AdOffer] = [
        AdOffer(brand: "ADIDASS", emoji: "👟", slogan: "Impossible is nothing. Rubble is everything.",
                seconds: 60, payout: 7_200_000_000_000, premium: true, house: true),
        AdOffer(brand: "MAMA'S PLANET INSURANCE CO.", emoji: "🏦", slogan: "We insure worlds. No questions asked. No refunds.",
                seconds: 30, payout: 3_000_000_000_000, house: true),
        AdOffer(brand: "PLANET FATNESS", emoji: "🏋️", slogan: "Get huge. Get destructive. Get insured.",
                seconds: 20, payout: 1_500_000_000_000, house: true),
        AdOffer(brand: "N&N'S WORLD", emoji: "🍬", slogan: "Melts in your city, not in your hand.",
                seconds: 15, payout: 1_000_000_000_000, house: true),
        AdOffer(brand: "WACKDONALD'S", emoji: "🍔", slogan: "Now with 30% more wack.",
                seconds: 10, payout: 600_000_000_000, house: true),
        AdOffer(brand: "BOLEX", emoji: "⌚", slogan: "Because time is money, and money is Mama's.",
                seconds: 5, payout: 250_000_000_000, house: true),
    ]
    /// Max ads per day, any mix — Mama raised a dignified family;
    /// there's only so much selling out one day can hold.
    public static let dailyAdCap = 10

    /// Combo system: hits (building hits, collapses, smashed
    /// props) landing within comboWindowSeconds of the previous
    /// hit chain the counter. Every 10 combo raises the claim
    /// multiplier one level, up to ×5. Applies to hit/collapse
    /// claim dollars only — never to the Maldo bounty, its
    /// doubling, landmark surcharges, or crowd liability.
    public static let comboWindowSeconds: Double = 1.4
    public static func comboMultiplier(combo: Int) -> Int {
        min(5, 1 + max(0, combo) / 10)
    }
    public static func comboClaim(base: Int, combo: Int) -> Int {
        base * comboMultiplier(combo: combo)
    }

    /// Mid-run events: every ~40–60 seconds, 15 seconds of chaos.
    public enum CityEvent: String, CaseIterable {
        case rushHour = "RUSH HOUR"
        case maldoMania = "MALDO MANIA"
        case demolitionDerby = "DEMOLITION DERBY"
    }
    public static let eventDurationSeconds: Double = 15
    /// Rush Hour: pedestrian liability pays double.
    public static let eventPedMultiplier = 2
    /// Rush Hour: this many extra pedestrians pour into the street.
    public static let rushHourExtraPeds = 14
    /// Maldo Mania: his respawn delay while the event runs.
    public static let maldoManiaRespawnSeconds: Double = 4

    /// Dollars per HP destroyed, set per city at build time.
    public static func claimRate(cityValue: Int, totalHP: Int) -> Double {
        guard totalHP > 0 else { return 0 }
        return Double(cityValue) / Double(totalHP)
    }
    /// Hits pay two-thirds of a building's value as you damage it…
    public static func hitClaimDollars(hpDealt: Int, rate: Double) -> Int {
        Int(Double(hpDealt) * rate * 2.0 / 3.0)
    }
    /// …and the collapse pays the final third.
    public static func collapseClaimDollars(maxHP: Int, rate: Double) -> Int {
        Int(Double(maxHP) * rate / 3.0)
    }
    /// Props carry 20 HP of the city's total value; a smash pays it.
    public static func propClaimDollars(rate: Double) -> Int {
        Int(20.0 * rate)
    }
    /// Toppling the landmark adds a surcharge of 5% of the city's
    /// whole value — icons are expensive.
    public static func landmarkSurcharge(cityValue: Int) -> Int { cityValue / 20 }

    /// Crowd squash values — big pedestrians pay out the most.
    /// The Golden Snitch: the cholo hiding somewhere in one city in
    /// the whole world, out talking to a cop. THE GAME DOESN'T END
    /// UNTIL YOU CRUSH HIM: every run just banks its points into the
    /// hunt, and the crush locks the whole bank in at 10×.
    public static let snitchMultiplier = 10

    /// The season penalty. The hunt runs on a calendar-month clock —
    /// midnight on the 1st to midnight on the 1st — and every day
    /// spent racking up points instead of finding the Snitch costs
    /// 2% of the payout. Day 1: no penalty. Day 31: −60%. That is
    /// the tension: destroy more now, or find him before it grows.
    public static func snitchPenaltyPercent(dayOfMonth: Int) -> Int {
        max(0, (dayOfMonth - 1) * 2)
    }

    /// The lock-in when a hunt ends in a crush: bank + final run,
    /// times ten, minus the season penalty for taking this long.
    /// `dayOfMonth` is the day the Snitch was CRUSHED, not the day
    /// the final visit ends — the penalty stops growing at the
    /// catch. Only this number ever reaches the leaderboard.
    public static func huntLockIn(bank: Int, runDamage: Int, dayOfMonth: Int) -> Int {
        let gross = (bank + runDamage) * snitchMultiplier
        return gross * (100 - snitchPenaltyPercent(dayOfMonth: dayOfMonth)) / 100
    }

    /// Crowd squash claim values — per-person liability settlements
    /// at realistic scale (US value-of-statistical-life ≈ $10M+).
    /// Influencers cost more. Legal insisted.
    public static let pedestrianValue = 10_000_000
    public static let dancerValue = 15_000_000
    public static let influencerValue = 25_000_000
    public static let bigPedestrianValue = 50_000_000

    /// Maldo bounty: destroying Maldo doubles your points — the reward
    /// equals everything you've earned so far — plus a flat bounty so
    /// catching him early still pays.
    public static let maldoBounty = 1_000_000_000
    public static func maldoReward(currentDamage: Int) -> Int {
        currentDamage + maldoBounty
    }

    /// Percent destroyed = destroyed value / total value available, 0...100.
    public static func percentDestroyed(destroyedValue: Int, totalValue: Int) -> Int {
        guard totalValue > 0 else { return 0 }
        let pct = Double(destroyedValue) / Double(totalValue) * 100.0
        return max(0, min(100, Int(pct.rounded())))
    }

    public static func rank(percentDestroyed pct: Int) -> String {
        switch pct {
        case 85...: return "S"
        case 65...: return "A"
        case 45...: return "B"
        case 25...: return "C"
        default: return "D"
        }
    }

    public static func verdict(rank: String) -> String {
        switch rank {
        case "S": return "TOTAL ANNIHILATION. THE MAP NEEDS REDRAWING."
        case "A": return "THE CITY WILL NEVER RECOVER. GREAT WORK."
        case "B": return "SERIOUS STRUCTURAL REGRET ACROSS THE CITY."
        case "C": return "A RESPECTABLE RAMPAGE. THE CITY NOTICED."
        default: return "MILD VANDALISM. THE CITY BARELY WOKE UP."
        }
    }

    /// Money at planetary scale reads in units: $843 MILLION,
    /// $2.5 TRILLION, $1.25 QUADRILLION. Small sums stay exact.
    public static func formatDollars(_ value: Int) -> String {
        let v = Double(value)
        func trimmed(_ x: Double, _ unit: String) -> String {
            var s = String(format: "%.2f", x)
            while s.hasSuffix("0") { s.removeLast() }
            if s.hasSuffix(".") { s.removeLast() }
            return "$\(s) \(unit)"
        }
        switch v {
        case 1e15...: return trimmed(v / 1e15, "QUADRILLION")
        case 1e12...: return trimmed(v / 1e12, "TRILLION")
        case 1e9...: return trimmed(v / 1e9, "BILLION")
        case 1e6...: return trimmed(v / 1e6, "MILLION")
        default:
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.groupingSeparator = ","
            return "$" + (f.string(from: NSNumber(value: value)) ?? "\(value)")
        }
    }
}
