import Foundation

/// Platform-neutral RGB color so game data stays testable without AppKit.
public struct ColorRGB {
    public let r: Double, g: Double, b: Double
    public init(_ r: Double, _ g: Double, _ b: Double) { self.r = r; self.g = g; self.b = b }
}

// MARK: - Fighters (monsters, creatures, and robots)

public struct FighterSpec {
    public let name: String
    public let species: String
    public let emoji: String
    public let speed: Double
    public let power: Int
    public let attackInterval: Double
    public let scale: Double
    public let specialName: String
    public let body: ColorRGB
    public let accent: ColorRGB
    public let blurb: String
    public let isRobot: Bool
}

public enum MonsterKind: Int, CaseIterable {
    // Monsters & creatures
    case razorback, bruno, voltina, pyra, krawl, yetira
    case gorgo, kraken, hydra, scorpius, behemoth, noctura
    case magmor, mako, arachnia, dunemaw, spectra, zorgath
    // Robots
    case mechaRex, titan9, crusher, scrapjack, voltbot, sentinel

    public var spec: FighterSpec {
        switch self {
        case .razorback: return FighterSpec(name: "ROSE", species: "Giant Lizard", emoji: "🦎", speed: 300, power: 22, attackInterval: 0.34, scale: 1.00, specialName: "Atomic Roar", body: ColorRGB(0.25, 0.62, 0.30), accent: ColorRGB(0.95, 0.85, 0.35), blurb: "Sweet as pie. Ate the pie shop, then the street.", isRobot: false)
        case .bruno: return FighterSpec(name: "BONNIE", species: "Giant Ape", emoji: "🦍", speed: 235, power: 38, attackInterval: 0.50, scale: 1.15, specialName: "Ground Slam", body: ColorRGB(0.42, 0.30, 0.20), accent: ColorRGB(0.78, 0.62, 0.47), blurb: "A perfect lady. Knuckles first, questions never.", isRobot: false)
        case .voltina: return FighterSpec(name: "RUBY", species: "Electric Serpent", emoji: "🐍", speed: 390, power: 15, attackInterval: 0.22, scale: 0.92, specialName: "Lightning Burst", body: ColorRGB(0.95, 0.78, 0.18), accent: ColorRGB(0.30, 0.65, 1.00), blurb: "Shocking manners. Shocks everything else too.", isRobot: false)
        case .pyra: return FighterSpec(name: "PETUNIA", species: "Fire Dragon", emoji: "🐉", speed: 285, power: 30, attackInterval: 0.42, scale: 1.05, specialName: "Inferno Breath", body: ColorRGB(0.88, 0.28, 0.16), accent: ColorRGB(1.00, 0.62, 0.20), blurb: "Pretty as a flower. Breathes like a crematorium.", isRobot: false)
        case .krawl: return FighterSpec(name: "HAZEL", species: "Giant Crab", emoji: "🦀", speed: 250, power: 33, attackInterval: 0.46, scale: 1.10, specialName: "Seismic Snap", body: ColorRGB(0.90, 0.38, 0.18), accent: ColorRGB(0.98, 0.75, 0.45), blurb: "One giant claw for hugs. Nobody survives hugs.", isRobot: false)
        case .yetira: return FighterSpec(name: "GLADYS", species: "Ice Yeti", emoji: "🦣", speed: 275, power: 24, attackInterval: 0.36, scale: 1.08, specialName: "Blizzard Blast", body: ColorRGB(0.82, 0.90, 0.97), accent: ColorRGB(0.40, 0.80, 1.00), blurb: "Brought the blizzard. Didn't bring you a coat.", isRobot: false)
        case .gorgo: return FighterSpec(name: "GERTRUDE", species: "T-Rex Titan", emoji: "🦖", speed: 260, power: 36, attackInterval: 0.48, scale: 1.18, specialName: "Chompquake", body: ColorRGB(0.30, 0.48, 0.26), accent: ColorRGB(0.92, 0.88, 0.74), blurb: "Extinct? Darling, she's just getting started.", isRobot: false)
        case .kraken: return FighterSpec(name: "AGNES", species: "Deep-Sea Kraken", emoji: "🦑", speed: 240, power: 31, attackInterval: 0.44, scale: 1.12, specialName: "Ink Tempest", body: ColorRGB(0.42, 0.24, 0.55), accent: ColorRGB(0.30, 0.85, 0.78), blurb: "Eight arms, all for squeezing. Permanently.", isRobot: false)
        case .hydra: return FighterSpec(name: "MILDRED", species: "Three-Headed Hydra", emoji: "🐲", speed: 270, power: 28, attackInterval: 0.38, scale: 1.06, specialName: "Triple Terror", body: ColorRGB(0.16, 0.58, 0.44), accent: ColorRGB(0.98, 0.80, 0.30), blurb: "Three heads. All three are furious with you.", isRobot: false)
        case .scorpius: return FighterSpec(name: "NANCY", species: "Desert Scorpion", emoji: "🦂", speed: 320, power: 26, attackInterval: 0.34, scale: 1.00, specialName: "Venom Tailstrike", body: ColorRGB(0.76, 0.58, 0.30), accent: ColorRGB(0.15, 0.13, 0.12), blurb: "The tail settles every argument. Fatally.", isRobot: false)
        case .behemoth: return FighterSpec(name: "BERTHA", species: "Rhino Behemoth", emoji: "🦏", speed: 225, power: 40, attackInterval: 0.55, scale: 1.20, specialName: "Horn Rush", body: ColorRGB(0.48, 0.50, 0.55), accent: ColorRGB(0.93, 0.90, 0.82), blurb: "Big Bertha. The argument ends when she sits down.", isRobot: false)
        case .noctura: return FighterSpec(name: "VERA", species: "Night Bat", emoji: "🦇", speed: 360, power: 17, attackInterval: 0.24, scale: 0.94, specialName: "Sonic Screech", body: ColorRGB(0.30, 0.24, 0.48), accent: ColorRGB(0.90, 0.40, 0.75), blurb: "You hear her first. Then the roof comes off.", isRobot: false)
        case .magmor: return FighterSpec(name: "ETHEL", species: "Lava Golem", emoji: "🗿", speed: 210, power: 35, attackInterval: 0.50, scale: 1.16, specialName: "Magma Core", body: ColorRGB(0.22, 0.20, 0.20), accent: ColorRGB(1.00, 0.45, 0.12), blurb: "A volcano in a lovely cardigan of ash.", isRobot: false)
        case .mako: return FighterSpec(name: "MABEL", species: "Land Shark", emoji: "🦈", speed: 335, power: 25, attackInterval: 0.32, scale: 1.02, specialName: "Feeding Frenzy", body: ColorRGB(0.45, 0.55, 0.65), accent: ColorRGB(0.95, 0.96, 0.97), blurb: "Nobody told Mabel sharks need water. She thrives.", isRobot: false)
        case .arachnia: return FighterSpec(name: "PRUDENCE", species: "Queen Spider", emoji: "🕷", speed: 310, power: 23, attackInterval: 0.30, scale: 1.04, specialName: "Websnare Slam", body: ColorRGB(0.16, 0.14, 0.18), accent: ColorRGB(0.90, 0.22, 0.25), blurb: "Eight legs, zero mercy, immaculate webbing.", isRobot: false)
        case .dunemaw: return FighterSpec(name: "MYRTLE", species: "Sandworm", emoji: "🪱", speed: 255, power: 32, attackInterval: 0.46, scale: 1.14, specialName: "Dune Dive", body: ColorRGB(0.78, 0.64, 0.46), accent: ColorRGB(0.85, 0.55, 0.50), blurb: "The ground was never safe. Myrtle is why.", isRobot: false)
        case .spectra: return FighterSpec(name: "PEARL", species: "Ghost Kaiju", emoji: "👻", speed: 300, power: 21, attackInterval: 0.28, scale: 0.98, specialName: "Phase Fright", body: ColorRGB(0.85, 0.82, 0.95), accent: ColorRGB(0.45, 0.95, 0.90), blurb: "Already dead. Still the rudest guest at the party.", isRobot: false)
        case .zorgath: return FighterSpec(name: "DOLORES", species: "Cosmic Invader", emoji: "👾", speed: 280, power: 29, attackInterval: 0.40, scale: 1.08, specialName: "Saucer Slam", body: ColorRGB(0.50, 0.30, 0.72), accent: ColorRGB(0.45, 0.95, 0.45), blurb: "Came a million light-years to ruin your street.", isRobot: false)
        case .mechaRex: return FighterSpec(name: "DORIS", species: "Mecha T-Rex", emoji: "🤖", speed: 265, power: 34, attackInterval: 0.44, scale: 1.14, specialName: "Rocket Jaw", body: ColorRGB(0.55, 0.58, 0.62), accent: ColorRGB(0.92, 0.25, 0.22), blurb: "Mama built Doris from a tank and a grudge.", isRobot: true)
        case .titan9: return FighterSpec(name: "CONSTANCE", species: "Military Mech", emoji: "🦾", speed: 230, power: 39, attackInterval: 0.52, scale: 1.18, specialName: "Missile Salvo", body: ColorRGB(0.40, 0.44, 0.34), accent: ColorRGB(0.98, 0.70, 0.25), blurb: "Built to defend the city. She had other plans.", isRobot: true)
        case .crusher: return FighterSpec(name: "HARRIET", species: "Construction Mech", emoji: "⚙️", speed: 245, power: 36, attackInterval: 0.50, scale: 1.12, specialName: "Wrecking Ball Protocol", body: ColorRGB(0.92, 0.70, 0.16), accent: ColorRGB(0.13, 0.13, 0.13), blurb: "Demolition was always Harriet's love language.", isRobot: true)
        case .scrapjack: return FighterSpec(name: "WINIFRED", species: "Junkyard Bot", emoji: "🔩", speed: 295, power: 24, attackInterval: 0.34, scale: 1.00, specialName: "Magnet Crunch", body: ColorRGB(0.62, 0.38, 0.26), accent: ColorRGB(0.30, 0.75, 0.72), blurb: "Held together by spite, magnets, and Mama's hope.", isRobot: true)
        case .voltbot: return FighterSpec(name: "FLORENCE", species: "Storm Bot", emoji: "🔋", speed: 350, power: 19, attackInterval: 0.26, scale: 0.96, specialName: "Arc Overload", body: ColorRGB(0.22, 0.38, 0.75), accent: ColorRGB(0.98, 0.85, 0.25), blurb: "Overcharged, out of warranty, out of patience.", isRobot: true)
        case .sentinel: return FighterSpec(name: "EDITH", species: "Orbital Sentinel", emoji: "🛰", speed: 275, power: 30, attackInterval: 0.42, scale: 1.10, specialName: "Orbital Strike", body: ColorRGB(0.88, 0.89, 0.92), accent: ColorRGB(0.98, 0.52, 0.18), blurb: "Fell from orbit. Kept the attitude. Added panels.", isRobot: true)
        }
    }

    public var name: String { spec.name }
    public var species: String { spec.species }
    public var emoji: String { spec.emoji }
    public var speed: Double { spec.speed }
    public var power: Int { spec.power }
    public var attackInterval: Double { spec.attackInterval }
    public var scale: Double { spec.scale }
    public var specialName: String { spec.specialName }
    public var bodyColor: ColorRGB { spec.body }
    public var accentColor: ColorRGB { spec.accent }
    public var blurb: String { spec.blurb }
    public var isRobot: Bool { spec.isRobot }
}

// MARK: - Body plans — every fighter a different shape and size

public enum BodyShape { case standard, round, long, tall, wide, dome, flat }
public enum LegStyle { case two, four, spider, tentacles, none }

/// The physical build of a fighter: silhouette, legs, torso dimensions,
/// head size and placement. No two fighters share a plan.
public struct BodyPlan {
    public let shape: BodyShape
    public let legs: LegStyle
    public let bodyW: Double
    public let bodyH: Double
    public let headR: Double
    public let headAtFront: Bool
}

extension MonsterKind {
    public var bodyPlan: BodyPlan {
        switch self {
        case .razorback: return BodyPlan(shape: .long, legs: .four, bodyW: 150, bodyH: 56, headR: 25, headAtFront: true)
        case .bruno: return BodyPlan(shape: .wide, legs: .two, bodyW: 120, bodyH: 108, headR: 34, headAtFront: false)
        case .voltina: return BodyPlan(shape: .long, legs: .none, bodyW: 172, bodyH: 34, headR: 22, headAtFront: true)
        case .pyra: return BodyPlan(shape: .standard, legs: .two, bodyW: 88, bodyH: 112, headR: 30, headAtFront: false)
        case .krawl: return BodyPlan(shape: .flat, legs: .spider, bodyW: 156, bodyH: 52, headR: 19, headAtFront: true)
        case .yetira: return BodyPlan(shape: .round, legs: .two, bodyW: 112, bodyH: 118, headR: 32, headAtFront: false)
        case .gorgo: return BodyPlan(shape: .long, legs: .two, bodyW: 128, bodyH: 78, headR: 30, headAtFront: true)
        case .kraken: return BodyPlan(shape: .dome, legs: .tentacles, bodyW: 106, bodyH: 96, headR: 28, headAtFront: false)
        case .hydra: return BodyPlan(shape: .tall, legs: .two, bodyW: 76, bodyH: 108, headR: 24, headAtFront: false)
        case .scorpius: return BodyPlan(shape: .flat, legs: .spider, bodyW: 128, bodyH: 48, headR: 20, headAtFront: true)
        case .behemoth: return BodyPlan(shape: .wide, legs: .four, bodyW: 152, bodyH: 84, headR: 30, headAtFront: true)
        case .noctura: return BodyPlan(shape: .round, legs: .two, bodyW: 84, bodyH: 78, headR: 29, headAtFront: false)
        case .magmor: return BodyPlan(shape: .tall, legs: .two, bodyW: 88, bodyH: 134, headR: 26, headAtFront: false)
        case .mako: return BodyPlan(shape: .long, legs: .two, bodyW: 158, bodyH: 56, headR: 24, headAtFront: true)
        case .arachnia: return BodyPlan(shape: .flat, legs: .spider, bodyW: 116, bodyH: 62, headR: 21, headAtFront: true)
        case .dunemaw: return BodyPlan(shape: .long, legs: .none, bodyW: 178, bodyH: 44, headR: 29, headAtFront: true)
        case .spectra: return BodyPlan(shape: .dome, legs: .none, bodyW: 92, bodyH: 104, headR: 26, headAtFront: false)
        case .zorgath: return BodyPlan(shape: .tall, legs: .two, bodyW: 80, bodyH: 112, headR: 33, headAtFront: false)
        case .mechaRex: return BodyPlan(shape: .long, legs: .two, bodyW: 148, bodyH: 66, headR: 29, headAtFront: true)
        case .titan9: return BodyPlan(shape: .wide, legs: .two, bodyW: 118, bodyH: 132, headR: 30, headAtFront: false)
        case .crusher: return BodyPlan(shape: .standard, legs: .two, bodyW: 104, bodyH: 116, headR: 27, headAtFront: false)
        case .scrapjack: return BodyPlan(shape: .round, legs: .two, bodyW: 96, bodyH: 88, headR: 24, headAtFront: false)
        case .voltbot: return BodyPlan(shape: .tall, legs: .two, bodyW: 68, bodyH: 128, headR: 23, headAtFront: false)
        case .sentinel: return BodyPlan(shape: .dome, legs: .none, bodyW: 112, bodyH: 84, headR: 25, headAtFront: false)
        }
    }
}

// MARK: - Cities

public enum LandmarkStyle {
    case tower, wheel, spire, needle, tiers, clock, statue, shells, bridge, sails
    case pyramid, dome
}

/// One city's progress within a season. Every city gets ONE HOUR of
/// destruction per season; leaving freezes the city exactly as it
/// stands — clock, rubble, and all — until the player returns.
public struct CityProgress: Codable {
    /// Seconds of the city's hour already spent.
    public var elapsed: Double = 0
    /// Building index → HP remaining, for damaged buildings only.
    public var buildingHP: [String: Int] = [:]
    /// Indices of props already smashed.
    public var deadProps: [Int] = []
    /// Claim dollars from this city already folded into the hunt bank
    /// by autosaves, so a crash never double-pays or loses them.
    public var damageFolded: Int = 0
    /// The Snitch was crushed in this city; the lock-in lands when
    /// the visit ends, even if that's a later return trip.
    public var snitchCaught: Bool = false
    public var snitchDay: Int = 0
    public init() {}
    // Tolerant decoding: a season saved by an older build may lack
    // keys added later (snitchDay arrived after the first city-clock
    // build). Synthesized Codable would fail the WHOLE decode on a
    // missing key and loadCityProgress would wipe every city's
    // frozen progress — decode each field with its default instead.
    private enum CodingKeys: String, CodingKey {
        case elapsed, buildingHP, deadProps, damageFolded, snitchCaught, snitchDay
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        elapsed = try c.decodeIfPresent(Double.self, forKey: .elapsed) ?? 0
        buildingHP = try c.decodeIfPresent([String: Int].self, forKey: .buildingHP) ?? [:]
        deadProps = try c.decodeIfPresent([Int].self, forKey: .deadProps) ?? []
        damageFolded = try c.decodeIfPresent(Int.self, forKey: .damageFolded) ?? 0
        snitchCaught = try c.decodeIfPresent(Bool.self, forKey: .snitchCaught) ?? false
        snitchDay = try c.decodeIfPresent(Int.self, forKey: .snitchDay) ?? 0
    }
    /// The hour is gone — the city is closed for the season.
    public var spent: Bool { elapsed >= 3599.5 }
}

/// Everything that makes a city *that city*: the real district and street
/// being rampaged, its true building-height profile (Paris is uniform
/// Haussmann, Dubai is scattered supertalls…), the parody storefronts that
/// line the street (no real brands — Bolex, not Rolex), the street
/// furniture/vehicles that belong there, and its cross streets.
public struct CitySpec {
    public let name: String
    public let tagline: String
    public let icon: String
    public let district: String
    public let streetName: String
    public let skyTop: ColorRGB
    public let skyBottom: ColorRGB
    public let ground: ColorRGB
    public let palette: [ColorRGB]
    public let buildingNames: [String]
    public let minBuildingH: Double
    public let maxBuildingH: Double
    public let shops: [String]
    public let propEmojis: [String]
    public let crossStreets: [String]
    public let landmark: String
    public let landmarkStyle: LandmarkStyle
    public let backdropSign: String?
    /// The crowd that actually lives here: skin tones weighted to the
    /// city's real demographics, the clothes its people wear, and how
    /// dense its streets feel (the on-screen crowd target).
    public let crowdSkin: [ColorRGB]
    public let crowdClothes: [ColorRGB]
    public let crowdDensity: Int
    /// What this city is actually WORTH — a realistic estimate of its
    /// total built-asset value in dollars. Flattening 100% of the
    /// city pays out exactly this much claim money (see Scoring's
    /// claim rate). Across all cities the values sum to roughly the
    /// real world's total real-estate wealth.
    public let destructionValue: Int
    /// Monthly city drops: "YYYY-MM" (zero-padded) of the month
    /// this city unlocks (midnight on the 1st). Launch cities are
    /// all "2026-10". Zero-padding is load-bearing: it keeps the
    /// strings sortable and comparable as-is.
    public let releaseMonth: String
}

public enum CityKind: Int, CaseIterable {
    case paris, tokyo, newYork, london
    case shanghai, vegas, losAngeles, dubai
    case chicago, hongKong, singapore, seoul
    case sydney, rio, toronto, berlin, sanFrancisco
    case rome, madrid, amsterdam, bangkok, mumbai
    case beijing, mexicoCity, saoPaulo, buenosAires, miami
    case seattle, washingtonDC, cairo, istanbul, moscow
    case athens, prague, capeTown, auckland

    public var spec: CitySpec {
        switch self {
        case .paris: return CitySpec(name: "PARIS", tagline: "The City of Light. Turn it off.", icon: "🗼",
            district: "8E ARRONDISSEMENT", streetName: "AVENUE DES CHAMPS-ÉLYSÉES",
            skyTop: ColorRGB(0.16, 0.18, 0.38), skyBottom: ColorRGB(0.55, 0.45, 0.62), ground: ColorRGB(0.30, 0.29, 0.33),
            palette: [ColorRGB(0.87, 0.80, 0.68), ColorRGB(0.80, 0.72, 0.60), ColorRGB(0.76, 0.66, 0.55), ColorRGB(0.90, 0.84, 0.72)],
            buildingNames: ["CAFÉ LUMIÈRE", "BOULANGERIE", "HÔTEL RIVE", "LIBRAIRIE", "RÉSIDENCE", "PÂTISSERIE", "MUSÉE"],
            minBuildingH: 165, maxBuildingH: 215,
            shops: ["LOUIS BUTTON", "CARTIRE", "CHANELLE", "DIORA", "SAPHORA", "MACARON & FILS", "GALERIES LAFAILLETTE", "MONOPRIXE", "WACKDONALD'S", "STARBOCK'S"],
            propEmojis: ["🚗", "🛵", "🚲", "🚙"], crossStreets: ["RUE DU FAUBOURG", "AV. MONTAIGNE", "ROND-POINT", "PLACE DE LA CONCORDE"],
            landmark: "EIFFEL TOWER", landmarkStyle: .tower, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.36, 0.24, 0.16), ColorRGB(0.93, 0.76, 0.62)], crowdClothes: [ColorRGB(0.13, 0.13, 0.16), ColorRGB(0.85, 0.83, 0.8), ColorRGB(0.45, 0.16, 0.2), ColorRGB(0.2, 0.26, 0.42), ColorRGB(0.55, 0.48, 0.4)], crowdDensity: 26, destructionValue: 9000000000000, releaseMonth: "2026-10")
        case .tokyo: return CitySpec(name: "TOKYO", tagline: "Neon jungle. Bring earplugs.", icon: "🗾",
            district: "SHIBUYA CITY", streetName: "SHIBUYA CROSSING",
            skyTop: ColorRGB(0.07, 0.06, 0.25), skyBottom: ColorRGB(0.45, 0.20, 0.50), ground: ColorRGB(0.20, 0.19, 0.26),
            palette: [ColorRGB(0.70, 0.72, 0.80), ColorRGB(0.85, 0.45, 0.60), ColorRGB(0.35, 0.75, 0.80), ColorRGB(0.60, 0.62, 0.72)],
            buildingNames: ["SHIBUYA HOTEL", "RAMEN-YA", "KARAOKE BOX", "MANGA KISSA", "PACHINKO", "SENTŌ"],
            minBuildingH: 200, maxBuildingH: 380,
            shops: ["UNIQLOH", "MUJII", "DON QUIHOTAY", "TOWERING RECORDS", "SHIBUYA 110", "LOFTY", "DAISOH", "7-TWELVE", "STARBOCK'S", "ABC-MARKET"],
            propEmojis: ["🚕", "🚗", "🚚", "🛵"], crossStreets: ["DOGENZAKA", "CENTER GAI", "MIYAMASU", "HARAJUKU"],
            landmark: "TOKYO SKYTREE", landmarkStyle: .needle, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.62, 0.44, 0.3)], crowdClothes: [ColorRGB(0.15, 0.15, 0.18), ColorRGB(0.9, 0.9, 0.92), ColorRGB(0.3, 0.35, 0.55), ColorRGB(0.75, 0.7, 0.75), ColorRGB(0.25, 0.45, 0.4)], crowdDensity: 34, destructionValue: 14000000000000, releaseMonth: "2026-10")
        case .newYork: return CitySpec(name: "NEW YORK", tagline: "The city that never sleeps. Nap time.", icon: "🗽",
            district: "MIDTOWN MANHATTAN", streetName: "FIFTH AVENUE",
            skyTop: ColorRGB(0.12, 0.20, 0.42), skyBottom: ColorRGB(0.85, 0.55, 0.40), ground: ColorRGB(0.22, 0.23, 0.27),
            palette: [ColorRGB(0.55, 0.58, 0.65), ColorRGB(0.45, 0.50, 0.60), ColorRGB(0.65, 0.60, 0.55), ColorRGB(0.38, 0.44, 0.55)],
            buildingNames: ["MIDTOWN OFFICES", "WALL ST BANK", "BROADWAY HOTEL", "LIBERTY TOWER", "THE CHRONICLE", "GRAND TERMINAL HOTEL"],
            minBuildingH: 260, maxBuildingH: 450,
            shops: ["BOLEX", "N&N'S WORLD", "PLANET FATNESS", "PEAR STORE", "MIKE TOWN", "STARBOCK'S", "GIFFANY & CO.", "GOOCHI", "PRAVDA", "BLOGO STORE", "WACKDONALD'S", "ZABA", "SACKS FIFTH AVENUE", "ADIDASS"],
            propEmojis: ["🚕", "🚕", "🚗", "🚌", "🚲"], crossStreets: ["W 34TH ST", "W 42ND ST", "W 50TH ST", "W 57TH ST"],
            landmark: "EMPIRE TOWER", landmarkStyle: .spire, backdropSign: nil,
            crowdSkin: [ColorRGB(0.36, 0.24, 0.16), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.62, 0.44, 0.3)], crowdClothes: [ColorRGB(0.1, 0.1, 0.12), ColorRGB(0.25, 0.27, 0.32), ColorRGB(0.85, 0.85, 0.87), ColorRGB(0.55, 0.15, 0.15), ColorRGB(0.15, 0.3, 0.55)], crowdDensity: 32, destructionValue: 12000000000000, releaseMonth: "2026-10")
        case .london: return CitySpec(name: "LONDON", tagline: "Mind the gap. And the monster.", icon: "🎡",
            district: "WESTMINSTER", streetName: "OXFORD STREET",
            skyTop: ColorRGB(0.22, 0.28, 0.40), skyBottom: ColorRGB(0.62, 0.55, 0.50), ground: ColorRGB(0.26, 0.26, 0.28),
            palette: [ColorRGB(0.72, 0.64, 0.55), ColorRGB(0.58, 0.56, 0.58), ColorRGB(0.66, 0.58, 0.48), ColorRGB(0.52, 0.54, 0.60)],
            buildingNames: ["THE CROWN INN", "TEA & CO.", "BOOKBINDERS", "TUBE HOTEL", "REGENT OFFICES", "FISH & CHIPS"],
            minBuildingH: 170, maxBuildingH: 260,
            shops: ["MARKS & SPARKLES", "SELFFRIDGES", "NARRODS", "BURBERKY", "PRIMARKET", "TESCOS", "PRETTY A MANGER", "BOOTHS", "WATER-ROCKS BOOKS", "STARBOCK'S"],
            propEmojis: ["🚕", "🚌", "🚗", "☎️"], crossStreets: ["REGENT ST", "SOHO SQ", "MARBLE ARCH", "PICCADILLY"],
            landmark: "BIG BEN", landmarkStyle: .clock, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.36, 0.24, 0.16), ColorRGB(0.85, 0.66, 0.5)], crowdClothes: [ColorRGB(0.16, 0.17, 0.22), ColorRGB(0.35, 0.36, 0.4), ColorRGB(0.45, 0.2, 0.22), ColorRGB(0.2, 0.32, 0.25), ColorRGB(0.8, 0.78, 0.75)], crowdDensity: 28, destructionValue: 11000000000000, releaseMonth: "2026-10")
        case .shanghai: return CitySpec(name: "SHANGHAI", tagline: "The Bund meets the beast.", icon: "🏙",
            district: "HUANGPU · THE BUND", streetName: "NANJING ROAD",
            skyTop: ColorRGB(0.30, 0.16, 0.42), skyBottom: ColorRGB(0.90, 0.55, 0.45), ground: ColorRGB(0.26, 0.23, 0.28),
            palette: [ColorRGB(0.65, 0.68, 0.78), ColorRGB(0.80, 0.62, 0.55), ColorRGB(0.45, 0.62, 0.72), ColorRGB(0.72, 0.66, 0.60)],
            buildingNames: ["JADE HOTEL", "TEA HOUSE", "PEARL OFFICES", "NOODLE HOUSE", "BUND BANK", "SILK & CO."],
            minBuildingH: 220, maxBuildingH: 400,
            shops: ["PEAS HOTEL", "PEAR STORE", "MIKE", "SWOTCH", "CARTIRE", "OMEGAH", "STARBOCK'S RESERVÉ", "WACKDONALD'S", "ZABA", "H&N"],
            propEmojis: ["🚕", "🚗", "🚌", "🛵"], crossStreets: ["THE BUND", "PEOPLE'S SQ", "HENAN RD", "XIZANG RD"],
            landmark: "ORIENTAL PEARL", landmarkStyle: .needle, backdropSign: nil,
            crowdSkin: [ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.85, 0.66, 0.5)], crowdClothes: [ColorRGB(0.2, 0.2, 0.24), ColorRGB(0.88, 0.88, 0.9), ColorRGB(0.7, 0.25, 0.3), ColorRGB(0.3, 0.45, 0.7), ColorRGB(0.95, 0.75, 0.3)], crowdDensity: 34, destructionValue: 10000000000000, releaseMonth: "2026-10")
        case .vegas: return CitySpec(name: "LAS VEGAS", tagline: "What happens here gets demolished here.", icon: "🎡",
            district: "THE STRIP", streetName: "LAS VEGAS BLVD",
            skyTop: ColorRGB(0.10, 0.06, 0.28), skyBottom: ColorRGB(0.62, 0.25, 0.55), ground: ColorRGB(0.24, 0.20, 0.30),
            palette: [ColorRGB(0.95, 0.75, 0.30), ColorRGB(0.85, 0.35, 0.55), ColorRGB(0.30, 0.80, 0.85), ColorRGB(0.70, 0.45, 0.95)],
            buildingNames: ["LUCKY SEVENS", "NEON DOME CASINO", "DESERT ROSE", "GOLDEN SPUR", "THE VAULT CASINO", "PALM ROYALE"],
            minBuildingH: 200, maxBuildingH: 380,
            shops: ["BELLAGIOH", "SEEZAR'S PALACE", "NBN GRAND", "PARIS LAS VEGAS-ISH", "PLANET HOLLYWOULD", "HARD ROK CAFÉ", "WACKDONALD'S", "STARBOCK'S", "PEAR STORE", "LUCKY SLOTS"],
            propEmojis: ["🚕", "🚗", "🎰", "🚌"], crossStreets: ["TROPICANA AVE", "FLAMINGO RD", "HARMON AVE", "SAHARA AVE"],
            landmark: "HIGH ROLLER WHEEL", landmarkStyle: .wheel, backdropSign: "WELCOME TO FABULOUS LAS VEGAS",
            crowdSkin: [ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.36, 0.24, 0.16), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.85, 0.66, 0.5)], crowdClothes: [ColorRGB(0.98, 0.3, 0.55), ColorRGB(0.2, 0.85, 0.9), ColorRGB(0.98, 0.8, 0.25), ColorRGB(0.65, 0.3, 0.95), ColorRGB(0.95, 0.95, 0.97)], crowdDensity: 28, destructionValue: 1500000000000, releaseMonth: "2026-10")
        case .losAngeles: return CitySpec(name: "LOS ANGELES", tagline: "City of Angels. Send in a monster.", icon: "🌴",
            district: "HOLLYWOOD", streetName: "HOLLYWOOD BLVD",
            skyTop: ColorRGB(0.98, 0.55, 0.30), skyBottom: ColorRGB(0.99, 0.80, 0.50), ground: ColorRGB(0.36, 0.30, 0.27),
            palette: [ColorRGB(0.93, 0.85, 0.72), ColorRGB(0.88, 0.76, 0.62), ColorRGB(0.80, 0.70, 0.66), ColorRGB(0.95, 0.90, 0.80)],
            buildingNames: ["SUNSET STUDIOS", "HOLLYWOOD HOTEL", "PALMS APARTMENTS", "ECHO PARK LOFTS", "STUDIO CITY INN", "VINE ST RECORDS"],
            minBuildingH: 150, maxBuildingH: 300,
            shops: ["TLC CHINESE THEATRE", "DOLBEE THEATRE", "EL CAPTAIN", "STARBOCK'S", "WACKDONALD'S", "PLANET FATNESS", "PEAR STORE", "MIKE", "ZABA", "SAPHORA", "HOLLYWOOD WAXY MUSEUM"],
            propEmojis: ["🚗", "🚕", "🚌", "🌴"], crossStreets: ["VINE ST", "HIGHLAND AVE", "LA BREA AVE", "FAIRFAX AVE"],
            landmark: "CAPITOL TOWER", landmarkStyle: .spire, backdropSign: "HOLLYWOOD",
            crowdSkin: [ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.36, 0.24, 0.16), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.72, 0.55, 0.38)], crowdClothes: [ColorRGB(0.95, 0.6, 0.3), ColorRGB(0.3, 0.8, 0.85), ColorRGB(0.95, 0.9, 0.85), ColorRGB(0.9, 0.4, 0.45), ColorRGB(0.45, 0.75, 0.45)], crowdDensity: 26, destructionValue: 7000000000000, releaseMonth: "2026-10")
        case .dubai: return CitySpec(name: "DUBAI", tagline: "Tallest city. Biggest target.", icon: "🌇",
            district: "DOWNTOWN DUBAI", streetName: "SHEIKH ZAYED ROAD",
            skyTop: ColorRGB(0.35, 0.55, 0.80), skyBottom: ColorRGB(0.98, 0.78, 0.55), ground: ColorRGB(0.55, 0.47, 0.36),
            palette: [ColorRGB(0.88, 0.82, 0.70), ColorRGB(0.78, 0.82, 0.88), ColorRGB(0.92, 0.86, 0.72), ColorRGB(0.70, 0.76, 0.84)],
            buildingNames: ["SANDS HOTEL", "GOLD SOUK", "OASIS TOWER", "PALM OFFICES", "SPICE TRADERS", "DUNE BANK"],
            minBuildingH: 280, maxBuildingH: 480,
            shops: ["DUBAII MALL", "PEAR STORE", "MIKE", "BLOOMING DALES", "HARVEY NICKELS", "CARTIRE", "BOLEX", "STARBOCK'S", "TIM HORTONN'S", "CARREFOURR"],
            propEmojis: ["🚕", "🚗", "🚙", "🚌"], crossStreets: ["FINANCIAL CENTRE", "AL SAFA", "EMIRATES TOWERS", "BURJ BLVD"],
            landmark: "BURJ KHALIFA", landmarkStyle: .tiers, backdropSign: nil,
            crowdSkin: [ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.36, 0.24, 0.16), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.72, 0.55, 0.38)], crowdClothes: [ColorRGB(0.92, 0.92, 0.94), ColorRGB(0.85, 0.8, 0.7), ColorRGB(0.15, 0.15, 0.18), ColorRGB(0.3, 0.4, 0.65), ColorRGB(0.7, 0.55, 0.25)], crowdDensity: 24, destructionValue: 4000000000000, releaseMonth: "2026-10")
        case .chicago: return CitySpec(name: "CHICAGO", tagline: "The Windy City gets windier.", icon: "🎷",
            district: "THE LOOP", streetName: "MICHIGAN AVENUE",
            skyTop: ColorRGB(0.15, 0.28, 0.50), skyBottom: ColorRGB(0.80, 0.60, 0.48), ground: ColorRGB(0.24, 0.25, 0.28),
            palette: [ColorRGB(0.52, 0.55, 0.60), ColorRGB(0.42, 0.46, 0.52), ColorRGB(0.62, 0.58, 0.52), ColorRGB(0.36, 0.40, 0.46)],
            buildingNames: ["DEEP DISH CO.", "JAZZ CLUB NINE", "LOOP OFFICES", "WINDY HOTEL", "TRIBUNE PRESS", "EL TRAIN DINER"],
            minBuildingH: 240, maxBuildingH: 420,
            shops: ["PEAR STORE", "MIKE CHICAGO", "ZABA", "NORDSTROMM", "MACEE'S", "GARRETT POPCORNN", "STARBOCK'S", "WACKDONALD'S", "PLANET FATNESS", "BLOGO STORE"],
            propEmojis: ["🚕", "🚗", "🚌", "🚲"], crossStreets: ["CHICAGO RIVER", "MADISON ST", "STATE ST", "WACKER DR"],
            landmark: "WILLIS TOWER", landmarkStyle: .spire, backdropSign: nil,
            crowdSkin: [ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.36, 0.24, 0.16), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.62, 0.44, 0.3)], crowdClothes: [ColorRGB(0.15, 0.2, 0.35), ColorRGB(0.6, 0.15, 0.2), ColorRGB(0.3, 0.32, 0.36), ColorRGB(0.85, 0.84, 0.82), ColorRGB(0.2, 0.4, 0.3)], crowdDensity: 26, destructionValue: 5000000000000, releaseMonth: "2026-10")
        case .hongKong: return CitySpec(name: "HONG KONG", tagline: "Harbour views, monster news.", icon: "⛴",
            district: "TSIM SHA TSUI", streetName: "NATHAN ROAD",
            skyTop: ColorRGB(0.08, 0.22, 0.32), skyBottom: ColorRGB(0.30, 0.55, 0.55), ground: ColorRGB(0.20, 0.24, 0.26),
            palette: [ColorRGB(0.60, 0.66, 0.72), ColorRGB(0.50, 0.60, 0.66), ColorRGB(0.70, 0.64, 0.58), ColorRGB(0.44, 0.54, 0.62)],
            buildingNames: ["DRAGON DIM SUM", "HARBOUR HOTEL", "JADE MARKET", "STAR FERRY INN", "PEAK OFFICES", "LANTAU BANK"],
            minBuildingH: 240, maxBuildingH: 420,
            shops: ["HARBOUR CITI", "LOUIS BUTTON", "CHANELLE", "BOLEX", "PEAR STORE", "SOGOH", "WATSONNS", "STARBOCK'S", "WACKDONALD'S", "7-TWELVE"],
            propEmojis: ["🚕", "🚌", "🚗", "⛴"], crossStreets: ["SALISBURY RD", "AUSTIN RD", "JORDAN RD", "WATERLOO RD"],
            landmark: "ICC SKY TOWER", landmarkStyle: .spire, backdropSign: nil,
            crowdSkin: [ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5)], crowdClothes: [ColorRGB(0.18, 0.18, 0.22), ColorRGB(0.9, 0.9, 0.9), ColorRGB(0.65, 0.3, 0.35), ColorRGB(0.35, 0.5, 0.75), ColorRGB(0.25, 0.55, 0.45)], crowdDensity: 32, destructionValue: 8000000000000, releaseMonth: "2026-10")
        case .singapore: return CitySpec(name: "SINGAPORE", tagline: "The Lion City says hi. Then bye.", icon: "🦁",
            district: "ORCHARD", streetName: "ORCHARD ROAD",
            skyTop: ColorRGB(0.20, 0.30, 0.55), skyBottom: ColorRGB(0.95, 0.62, 0.45), ground: ColorRGB(0.26, 0.28, 0.26),
            palette: [ColorRGB(0.80, 0.84, 0.86), ColorRGB(0.70, 0.78, 0.80), ColorRGB(0.86, 0.80, 0.70), ColorRGB(0.62, 0.72, 0.76)],
            buildingNames: ["MERLION HOTEL", "HAWKER HALL", "ORCHARD OFFICES", "SATAY & CO.", "GARDEN INN", "STRAITS BANK"],
            minBuildingH: 200, maxBuildingH: 360,
            shops: ["ION ORCHARDD", "TAKASHIMAYAH", "LOUIS BUTTON", "PEAR ORCHARD", "UNIQLOH", "STARBOCK'S", "WACKDONALD'S", "SAPHORA", "MIKE", "DIN TAI FUNGG"],
            propEmojis: ["🚕", "🚗", "🚌", "🌴"], crossStreets: ["SCOTTS RD", "SOMERSET", "DHOBY GHAUT", "TANGLIN RD"],
            landmark: "MARINA BAY SANDS", landmarkStyle: .sails, backdropSign: nil,
            crowdSkin: [ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.36, 0.24, 0.16)], crowdClothes: [ColorRGB(0.9, 0.9, 0.92), ColorRGB(0.95, 0.55, 0.3), ColorRGB(0.3, 0.7, 0.6), ColorRGB(0.85, 0.35, 0.4), ColorRGB(0.4, 0.45, 0.7)], crowdDensity: 30, destructionValue: 6000000000000, releaseMonth: "2026-10")
        case .seoul: return CitySpec(name: "SEOUL", tagline: "Gangnam style, kaiju pile.", icon: "🏯",
            district: "GANGNAM", streetName: "GANGNAM-DAERO",
            skyTop: ColorRGB(0.25, 0.30, 0.55), skyBottom: ColorRGB(0.92, 0.65, 0.60), ground: ColorRGB(0.27, 0.26, 0.28),
            palette: [ColorRGB(0.68, 0.70, 0.76), ColorRGB(0.78, 0.66, 0.60), ColorRGB(0.56, 0.62, 0.70), ColorRGB(0.74, 0.70, 0.66)],
            buildingNames: ["KIMCHI HOUSE", "PC BANG", "SEOUL STAY", "HANGANG OFFICES", "BBQ BROS", "TTEOK HOUSE"],
            minBuildingH: 220, maxBuildingH: 400,
            shops: ["PEAR GANGNAM", "MIKE SEOUL", "OLIVE YOUNGG", "STARBOCK'S", "WACKDONALD'S", "ZABA", "LINE FRIENNDS", "SHAKE SHACKK", "PLANET FATNESS", "GS26"],
            propEmojis: ["🚕", "🚗", "🚌", "🛵"], crossStreets: ["TEHERAN-RO", "NONHYEON", "SADANG", "SEOCHO"],
            landmark: "LOTTE WORLD TOWER", landmarkStyle: .needle, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.62, 0.44, 0.3)], crowdClothes: [ColorRGB(0.16, 0.16, 0.2), ColorRGB(0.92, 0.92, 0.94), ColorRGB(0.7, 0.62, 0.55), ColorRGB(0.45, 0.55, 0.75), ColorRGB(0.85, 0.7, 0.72)], crowdDensity: 30, destructionValue: 6000000000000, releaseMonth: "2026-10")
        case .sydney: return CitySpec(name: "SYDNEY", tagline: "G'day. Goodbye, Opera House.", icon: "🦘",
            district: "CBD · CIRCULAR QUAY", streetName: "GEORGE STREET",
            skyTop: ColorRGB(0.30, 0.55, 0.85), skyBottom: ColorRGB(0.98, 0.80, 0.55), ground: ColorRGB(0.40, 0.36, 0.30),
            palette: [ColorRGB(0.88, 0.84, 0.76), ColorRGB(0.78, 0.80, 0.84), ColorRGB(0.90, 0.86, 0.78), ColorRGB(0.72, 0.76, 0.80)],
            buildingNames: ["HARBOUR INN", "SURF & TURF", "BONDI LOFTS", "OPAL OFFICES", "FLAT WHITE CO.", "REEF BANK"],
            minBuildingH: 180, maxBuildingH: 340,
            shops: ["QUEEN VIC BUILDING", "PEAR STORE", "MYERR", "DAVID JONESS", "WOOLWORTHSS", "STARBOCK'S", "WACKDONALD'S", "ZABA", "MIKE"],
            propEmojis: ["🚕", "🚗", "🚌", "🚲"], crossStreets: ["CIRCULAR QUAY", "MARTIN PLACE", "KING ST", "HUNTER ST"],
            landmark: "OPERA HOUSE", landmarkStyle: .shells, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.85, 0.66, 0.5)], crowdClothes: [ColorRGB(0.3, 0.65, 0.8), ColorRGB(0.95, 0.85, 0.6), ColorRGB(0.9, 0.9, 0.9), ColorRGB(0.35, 0.55, 0.35), ColorRGB(0.95, 0.5, 0.3)], crowdDensity: 22, destructionValue: 4000000000000, releaseMonth: "2026-10")
        case .rio: return CitySpec(name: "RIO DE JANEIRO", tagline: "Carnival of destruction.", icon: "🏖",
            district: "COPACABANA", streetName: "AVENIDA ATLÂNTICA",
            skyTop: ColorRGB(0.85, 0.45, 0.35), skyBottom: ColorRGB(0.99, 0.75, 0.50), ground: ColorRGB(0.38, 0.33, 0.28),
            palette: [ColorRGB(0.92, 0.86, 0.74), ColorRGB(0.86, 0.78, 0.66), ColorRGB(0.80, 0.74, 0.68), ColorRGB(0.94, 0.88, 0.78)],
            buildingNames: ["SAMBA SUITES", "COCONUT CO.", "COPACABANA INN", "AÇAÍ HOUSE", "RIO OFFICES", "BEACH BANK"],
            minBuildingH: 170, maxBuildingH: 280,
            shops: ["COPACABANA PALACEE", "HAVAIANASS", "STARBOCK'S", "WACKDONALD'S", "FARMM", "OSKLENN", "PEAR STORE", "SAPHORA"],
            propEmojis: ["🚕", "🚗", "🚌", "🏖"], crossStreets: ["POSTO 5", "SANTA CLARA", "FIGUEIREDO", "POSTO 2"],
            landmark: "CHRIST THE REDEEMER", landmarkStyle: .statue, backdropSign: nil,
            crowdSkin: [ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.36, 0.24, 0.16), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.36, 0.24, 0.16)], crowdClothes: [ColorRGB(0.98, 0.75, 0.2), ColorRGB(0.2, 0.8, 0.5), ColorRGB(0.95, 0.4, 0.35), ColorRGB(0.3, 0.75, 0.95), ColorRGB(0.95, 0.95, 0.95)], crowdDensity: 28, destructionValue: 3000000000000, releaseMonth: "2026-10")
        case .toronto: return CitySpec(name: "TORONTO", tagline: "Sorry, not sorry, Toronto.", icon: "🍁",
            district: "DOWNTOWN", streetName: "YONGE STREET",
            skyTop: ColorRGB(0.18, 0.32, 0.55), skyBottom: ColorRGB(0.85, 0.65, 0.50), ground: ColorRGB(0.25, 0.27, 0.30),
            palette: [ColorRGB(0.58, 0.62, 0.68), ColorRGB(0.48, 0.54, 0.62), ColorRGB(0.68, 0.62, 0.56), ColorRGB(0.40, 0.48, 0.58)],
            buildingNames: ["MAPLE HOTEL", "POUTINE CO.", "YONGE OFFICES", "LAKEVIEW INN", "NORTH BANK", "HARBOUR LOFTS"],
            minBuildingH: 230, maxBuildingH: 410,
            shops: ["EATIN' CENTRE", "PEAR STORE", "MIKE", "HUDSON'S BAE", "TIM HORTONN'S", "STARBOCK'S", "WACKDONALD'S", "PLANET FATNESS", "BLOGO STORE"],
            propEmojis: ["🚕", "🚗", "🚌", "🚲"], crossStreets: ["QUEEN ST W", "DUNDAS ST W", "BLOOR ST W", "COLLEGE ST"],
            landmark: "CN TOWER", landmarkStyle: .needle, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.36, 0.24, 0.16), ColorRGB(0.93, 0.76, 0.62)], crowdClothes: [ColorRGB(0.18, 0.22, 0.35), ColorRGB(0.7, 0.2, 0.2), ColorRGB(0.35, 0.37, 0.42), ColorRGB(0.88, 0.87, 0.85), ColorRGB(0.25, 0.45, 0.35)], crowdDensity: 26, destructionValue: 4000000000000, releaseMonth: "2026-10")
        case .berlin: return CitySpec(name: "BERLIN", tagline: "The Wall fell. Now everything.", icon: "🐻",
            district: "MITTE", streetName: "FRIEDRICHSTRASSE",
            skyTop: ColorRGB(0.24, 0.30, 0.42), skyBottom: ColorRGB(0.70, 0.60, 0.52), ground: ColorRGB(0.27, 0.27, 0.28),
            palette: [ColorRGB(0.70, 0.66, 0.60), ColorRGB(0.60, 0.62, 0.64), ColorRGB(0.66, 0.60, 0.54), ColorRGB(0.54, 0.58, 0.62)],
            buildingNames: ["BRATWURST HAUS", "TECHNO KELLER", "MAUER HOTEL", "PRENZL OFFICES", "DÖNER & CO.", "SPREE BANK"],
            minBuildingH: 170, maxBuildingH: 280,
            shops: ["GALERIES LAFAILLETTE", "PEAR STORE", "MIKE BERLIN", "SATURNN", "STARBOCK'S", "WACKDONALD'S", "ZABA", "DÖNER & CO.", "ROSSMANNN"],
            propEmojis: ["🚕", "🚗", "🚌", "🚲"], crossStreets: ["UNTER DEN LINDEN", "CHECKPOINT CHARLIE", "LEIPZIGER STR", "TORSTRASSE"],
            landmark: "FERNSEHTURM", landmarkStyle: .needle, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.48, 0.33, 0.22)], crowdClothes: [ColorRGB(0.12, 0.12, 0.14), ColorRGB(0.3, 0.3, 0.33), ColorRGB(0.5, 0.48, 0.45), ColorRGB(0.85, 0.84, 0.82), ColorRGB(0.4, 0.3, 0.55)], crowdDensity: 24, destructionValue: 4000000000000, releaseMonth: "2026-10")
        case .sanFrancisco: return CitySpec(name: "SAN FRANCISCO", tagline: "Fog, hills, and total ruin.", icon: "🌉",
            district: "FISHERMAN'S WHARF", streetName: "JEFFERSON STREET",
            skyTop: ColorRGB(0.45, 0.50, 0.58), skyBottom: ColorRGB(0.95, 0.70, 0.52), ground: ColorRGB(0.32, 0.30, 0.28),
            palette: [ColorRGB(0.84, 0.80, 0.74), ColorRGB(0.76, 0.74, 0.72), ColorRGB(0.88, 0.82, 0.74), ColorRGB(0.70, 0.72, 0.76)],
            buildingNames: ["FOG CITY INN", "SOURDOUGH CO.", "WHARF HOTEL", "MISSION OFFICES", "CABLE CAR CAFÉ", "BAY BANK"],
            minBuildingH: 150, maxBuildingH: 280,
            shops: ["GHIRADELLI SQUARE", "BOUDINN BAKERY", "PEAR STORE", "STARBOCK'S", "WACKDONALD'S", "PLANET FATNESS", "IN-N-OUTT", "HARD ROK CAFÉ", "SAPHORA"],
            propEmojis: ["🚕", "🚗", "🚌", "🚲"], crossStreets: ["TAYLOR ST", "MASON ST", "POWELL ST", "HYDE ST"],
            landmark: "GOLDEN GATE", landmarkStyle: .bridge, backdropSign: nil,
            crowdSkin: [ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.62, 0.44, 0.3)], crowdClothes: [ColorRGB(0.3, 0.35, 0.55), ColorRGB(0.55, 0.58, 0.62), ColorRGB(0.15, 0.15, 0.17), ColorRGB(0.9, 0.88, 0.86), ColorRGB(0.7, 0.4, 0.3)], crowdDensity: 24, destructionValue: 5000000000000, releaseMonth: "2026-10")
        case .rome: return CitySpec(name: "ROME", tagline: "All roads lead here. End of the road.", icon: "🏛️",
            district: "CENTRO STORICO", streetName: "VIA DEI FORI IMPERIALI",
            skyTop: ColorRGB(0.25, 0.20, 0.35), skyBottom: ColorRGB(0.80, 0.55, 0.40), ground: ColorRGB(0.35, 0.30, 0.28),
            palette: [ColorRGB(0.85, 0.72, 0.55), ColorRGB(0.78, 0.62, 0.45), ColorRGB(0.88, 0.78, 0.62), ColorRGB(0.70, 0.55, 0.42)],
            buildingNames: ["TRATTORIA", "HOTEL ROMA", "PALAZZO", "GELATERIA", "ENOTECA", "PASTICCERIA"],
            minBuildingH: 120, maxBuildingH: 190,
            shops: ["GOOCHI", "PRAVDA", "FENDY", "BULGARY", "ARMANIA", "VESPA & FIGLI", "SAPORITO", "WACKDONALD'S", "STARBOCK'S", "GELATO & CO."],
            propEmojis: ["🚗", "🛵", "🚲", "🚕"], crossStreets: ["VIA DEL CORSO", "VIA VENETO", "VIA NAZIONALE", "VIA CAVOUR"],
            landmark: "COLOSSEUM", landmarkStyle: .tiers, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.93, 0.76, 0.62)], crowdClothes: [ColorRGB(0.13, 0.13, 0.16), ColorRGB(0.55, 0.2, 0.2), ColorRGB(0.85, 0.83, 0.8), ColorRGB(0.3, 0.35, 0.3), ColorRGB(0.6, 0.5, 0.35)], crowdDensity: 26, destructionValue: 5000000000000, releaseMonth: "2026-10")
        case .madrid: return CitySpec(name: "MADRID", tagline: "La Movida never stopped. It will now.", icon: "🐂",
            district: "CENTRO", streetName: "GRAN VÍA",
            skyTop: ColorRGB(0.15, 0.25, 0.50), skyBottom: ColorRGB(0.85, 0.60, 0.35), ground: ColorRGB(0.32, 0.28, 0.26),
            palette: [ColorRGB(0.82, 0.65, 0.48), ColorRGB(0.75, 0.55, 0.40), ColorRGB(0.88, 0.75, 0.58), ColorRGB(0.68, 0.50, 0.38)],
            buildingNames: ["HOTEL GRAN VÍA", "TABERNA", "MERCADO", "CAFÉ CENTRAL", "LIBRERÍA", "FARMACIA"],
            minBuildingH: 150, maxBuildingH: 230,
            shops: ["ZABA", "MANGOH", "EL CORTE INGLAZE", "MERCADONUT", "BERSHKAA", "PULL&BEER", "TELEPHONICA", "WACKDONALD'S", "STARBOCK'S"],
            propEmojis: ["🚗", "🚕", "🚌", "🛵"], crossStreets: ["CALLE DE ALCALÁ", "FUENCARRAL", "PRECIADOS", "CALLE MAYOR"],
            landmark: "PUERTA DE ALCALÁ", landmarkStyle: .tower, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.85, 0.66, 0.5)], crowdClothes: [ColorRGB(0.6, 0.15, 0.2), ColorRGB(0.15, 0.15, 0.18), ColorRGB(0.9, 0.88, 0.85), ColorRGB(0.25, 0.4, 0.6), ColorRGB(0.7, 0.55, 0.3)], crowdDensity: 27, destructionValue: 4000000000000, releaseMonth: "2026-10")
        case .amsterdam: return CitySpec(name: "AMSTERDAM", tagline: "Mind the canals. Or don't.", icon: "🚲",
            district: "CENTRUM", streetName: "DAMRAK",
            skyTop: ColorRGB(0.30, 0.38, 0.50), skyBottom: ColorRGB(0.60, 0.65, 0.70), ground: ColorRGB(0.30, 0.30, 0.32),
            palette: [ColorRGB(0.55, 0.38, 0.30), ColorRGB(0.45, 0.30, 0.26), ColorRGB(0.65, 0.48, 0.38), ColorRGB(0.40, 0.32, 0.30)],
            buildingNames: ["CANAL HOUSE", "HOTEL AMSTEL", "CAFÉ BRUIN", "BOEKENWINKEL", "FIETSEN", "BLOEMEN"],
            minBuildingH: 110, maxBuildingH: 160,
            shops: ["HEMAA", "ALBERT HINE", "BOL DOT COM", "FEEBO", "RIJKSHOP", "TULIP & CO.", "WACKDONALD'S", "STARBOCK'S", "KAAS & CO."],
            propEmojis: ["🚲", "🚲", "🚗", "🛶"], crossStreets: ["HERENGRACHT", "KEIZERSGRACHT", "PRINSENGRACHT", "LEIDSESTRAAT"],
            landmark: "RIJKSMUSEUM", landmarkStyle: .clock, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.85, 0.66, 0.5)], crowdClothes: [ColorRGB(0.9, 0.5, 0.1), ColorRGB(0.15, 0.15, 0.17), ColorRGB(0.3, 0.4, 0.55), ColorRGB(0.85, 0.85, 0.87), ColorRGB(0.4, 0.5, 0.4)], crowdDensity: 24, destructionValue: 2500000000000, releaseMonth: "2026-10")
        case .bangkok: return CitySpec(name: "BANGKOK", tagline: "One night was never going to be enough.", icon: "🛕",
            district: "RATTANAKOSIN", streetName: "KHAO SAN ROAD",
            skyTop: ColorRGB(0.20, 0.12, 0.35), skyBottom: ColorRGB(0.90, 0.50, 0.30), ground: ColorRGB(0.28, 0.24, 0.26),
            palette: [ColorRGB(0.85, 0.68, 0.35), ColorRGB(0.35, 0.65, 0.60), ColorRGB(0.85, 0.50, 0.55), ColorRGB(0.70, 0.72, 0.75)],
            buildingNames: ["KHAO SAN INN", "NOODLE HOUSE", "TUK TUK TOURS", "SILK SHOP", "MASSAGE", "ROTI CART"],
            minBuildingH: 200, maxBuildingH: 420,
            shops: ["7-TWELVE", "CENTRALEE", "MBKAY", "CHATUCHAK CO.", "THAI SILK & SONS", "TUK TUK MART", "WACKDONALD'S", "STARBOCK'S"],
            propEmojis: ["🛺", "🚗", "🛵", "🚕"], crossStreets: ["RAMBUTTRI", "SOI RAMKHAMHAENG", "CHAKRABONGSE", "PHRA ATHIT"],
            landmark: "GRAND PALACE", landmarkStyle: .spire, backdropSign: nil,
            crowdSkin: [ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.48, 0.33, 0.22)], crowdClothes: [ColorRGB(0.9, 0.6, 0.15), ColorRGB(0.85, 0.3, 0.35), ColorRGB(0.2, 0.6, 0.5), ColorRGB(0.9, 0.88, 0.85), ColorRGB(0.3, 0.35, 0.6)], crowdDensity: 32, destructionValue: 3000000000000, releaseMonth: "2026-10")
        case .mumbai: return CitySpec(name: "MUMBAI", tagline: "Maximum city. Maximum damage.", icon: "🎬",
            district: "BANDRA WEST", streetName: "LINKING ROAD",
            skyTop: ColorRGB(0.25, 0.18, 0.30), skyBottom: ColorRGB(0.85, 0.55, 0.35), ground: ColorRGB(0.30, 0.26, 0.24),
            palette: [ColorRGB(0.85, 0.75, 0.60), ColorRGB(0.70, 0.60, 0.48), ColorRGB(0.88, 0.82, 0.70), ColorRGB(0.45, 0.65, 0.62)],
            buildingNames: ["BOLLYWOOD HOTEL", "CHAI HOUSE", "TEXTILE CO.", "BANDRA CAFÉ", "SPICE MART", "JEWELLERS"],
            minBuildingH: 220, maxBuildingH: 450,
            shops: ["RELYANCE", "TATAA", "BIG BAZARRE", "JIOH", "ZUDIOH", "CHAI POINTY", "WACKDONALD'S", "STARBOCK'S"],
            propEmojis: ["🛺", "🚗", "🚕", "🛵"], crossStreets: ["WATERFIELD RD", "TURNER RD", "CARTER RD", "HILL RD"],
            landmark: "GATEWAY OF INDIA", landmarkStyle: .dome, backdropSign: nil,
            crowdSkin: [ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.62, 0.44, 0.3)], crowdClothes: [ColorRGB(0.9, 0.45, 0.1), ColorRGB(0.2, 0.55, 0.35), ColorRGB(0.85, 0.25, 0.4), ColorRGB(0.9, 0.85, 0.8), ColorRGB(0.3, 0.3, 0.6)], crowdDensity: 34, destructionValue: 4000000000000, releaseMonth: "2026-10")
        case .beijing: return CitySpec(name: "BEIJING", tagline: "Twenty-one million people. One bad evening.", icon: "🏯",
            district: "DONGCHENG", streetName: "WANGFUJING",
            skyTop: ColorRGB(0.20, 0.25, 0.42), skyBottom: ColorRGB(0.75, 0.60, 0.45), ground: ColorRGB(0.30, 0.28, 0.27),
            palette: [ColorRGB(0.70, 0.68, 0.72), ColorRGB(0.80, 0.62, 0.45), ColorRGB(0.62, 0.60, 0.66), ColorRGB(0.85, 0.55, 0.35)],
            buildingNames: ["WANGFUJING HOTEL", "TEA HOUSE", "BOOK CITY", "SILK MARKET", "NOODLE KING", "APOTHECARY"],
            minBuildingH: 170, maxBuildingH: 330,
            shops: ["JD DOT COME", "BAIDU BAZAAR", "MOUTAI & SONS", "PEKING DUCK CO.", "WACKDONALD'S", "STARBOCK'S", "HUTONG MART", "JADE & CO."],
            propEmojis: ["🚗", "🚕", "🛵", "🚲"], crossStreets: ["DENGSHIKOU", "JINYU HUTONG", "DONGSI", "WUSI"],
            landmark: "FORBIDDEN CITY", landmarkStyle: .tiers, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62)], crowdClothes: [ColorRGB(0.15, 0.15, 0.18), ColorRGB(0.7, 0.2, 0.2), ColorRGB(0.3, 0.35, 0.55), ColorRGB(0.88, 0.87, 0.85), ColorRGB(0.45, 0.5, 0.45)], crowdDensity: 32, destructionValue: 9000000000000, releaseMonth: "2026-10")
        case .mexicoCity: return CitySpec(name: "MEXICO CITY", tagline: "Built on a lake. Drained by a kaiju.", icon: "🌮",
            district: "POLANCO", streetName: "AV. PRESIDENTE MASARYK",
            skyTop: ColorRGB(0.22, 0.25, 0.45), skyBottom: ColorRGB(0.88, 0.58, 0.35), ground: ColorRGB(0.30, 0.27, 0.25),
            palette: [ColorRGB(0.85, 0.70, 0.52), ColorRGB(0.90, 0.60, 0.40), ColorRGB(0.65, 0.70, 0.68), ColorRGB(0.78, 0.55, 0.48)],
            buildingNames: ["HOTEL MASARYK", "TAQUERÍA", "MEZCALERÍA", "PANADERÍA", "MERCADO", "CANTINA"],
            minBuildingH: 160, maxBuildingH: 380,
            shops: ["LIVERPUL", "OXXOH", "SANBORNZ", "TELCELL", "WACKDONALD'S", "STARBOCK'S", "PALACIO DE HIEROH", "TAQUERÍA EL FARO"],
            propEmojis: ["🚗", "🚕", "🚌", "🛵"], crossStreets: ["ARQUÍMEDES", "TAINE", "SÉNECA", "HORACIO"],
            landmark: "ÁNGEL DE LA INDEPENDENCIA", landmarkStyle: .statue, backdropSign: nil,
            crowdSkin: [ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.62, 0.44, 0.3)], crowdClothes: [ColorRGB(0.2, 0.6, 0.3), ColorRGB(0.85, 0.3, 0.3), ColorRGB(0.9, 0.88, 0.85), ColorRGB(0.3, 0.3, 0.55), ColorRGB(0.9, 0.65, 0.15)], crowdDensity: 30, destructionValue: 4000000000000, releaseMonth: "2026-10")
        case .saoPaulo: return CitySpec(name: "SÃO PAULO", tagline: "Concrete jungle, meet actual monster.", icon: "🏙️",
            district: "JARDINS", streetName: "AVENIDA PAULISTA",
            skyTop: ColorRGB(0.18, 0.22, 0.40), skyBottom: ColorRGB(0.70, 0.55, 0.45), ground: ColorRGB(0.28, 0.27, 0.28),
            palette: [ColorRGB(0.72, 0.70, 0.74), ColorRGB(0.80, 0.66, 0.52), ColorRGB(0.62, 0.64, 0.68), ColorRGB(0.85, 0.72, 0.58)],
            buildingNames: ["HOTEL PAULISTA", "PADARIA", "CHURRASCARIA", "FARMÁCIA", "LIVRARIA", "CAFÉ"],
            minBuildingH: 220, maxBuildingH: 420,
            shops: ["MAGAZINE LUIZAA", "CASAS BAHIAA", "HAVANN", "WACKDONALD'S", "STARBOCK'S", "PAULISTA BOOKS", "AÇAÍ & CO.", "SAMBA SHOES", "FEIJOADA HOUSE"],
            propEmojis: ["🚗", "🚕", "🚌", "🛵"], crossStreets: ["AUGUSTA", "CONSOLAÇÃO", "BELAS ARTES", "TRIANON"],
            landmark: "COPAN BUILDING", landmarkStyle: .tower, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.36, 0.24, 0.16), ColorRGB(0.72, 0.55, 0.38)], crowdClothes: [ColorRGB(0.2, 0.65, 0.3), ColorRGB(0.95, 0.8, 0.15), ColorRGB(0.2, 0.35, 0.7), ColorRGB(0.9, 0.88, 0.85), ColorRGB(0.85, 0.3, 0.35)], crowdDensity: 32, destructionValue: 5000000000000, releaseMonth: "2026-10")
        case .buenosAires: return CitySpec(name: "BUENOS AIRES", tagline: "Don't cry for it. It's already rubble.", icon: "💃",
            district: "RECOLETA", streetName: "AVENIDA SANTA FE",
            skyTop: ColorRGB(0.20, 0.28, 0.48), skyBottom: ColorRGB(0.80, 0.58, 0.42), ground: ColorRGB(0.30, 0.28, 0.27),
            palette: [ColorRGB(0.86, 0.78, 0.66), ColorRGB(0.78, 0.68, 0.55), ColorRGB(0.88, 0.82, 0.72), ColorRGB(0.70, 0.62, 0.52)],
            buildingNames: ["HOTEL RECOLETA", "CONFITERÍA", "LIBRERÍA", "PARRILLA", "FARMACIA", "CAFÉ TORTONI 2"],
            minBuildingH: 150, maxBuildingH: 300,
            shops: ["GALERÍAS PACIFIKO", "HAVANNAA", "WACKDONALD'S", "STARBOCK'S", "FRAVEGAA", "MATE & CO.", "TANGO SHOES", "EMPANADA HOUSE", "MALBEC & CO."],
            propEmojis: ["🚗", "🚕", "🚌", "🛵"], crossStreets: ["CALLAO", "JUNÍN", "AYACUCHO", "PUEYRREDÓN"],
            landmark: "OBELISCO", landmarkStyle: .needle, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.85, 0.66, 0.5)], crowdClothes: [ColorRGB(0.45, 0.65, 0.85), ColorRGB(0.9, 0.88, 0.85), ColorRGB(0.15, 0.15, 0.18), ColorRGB(0.6, 0.2, 0.25), ColorRGB(0.3, 0.4, 0.3)], crowdDensity: 27, destructionValue: 2500000000000, releaseMonth: "2026-10")
        case .miami: return CitySpec(name: "MIAMI", tagline: "Welcome to Miami. Mind the monster.", icon: "🌴",
            district: "SOUTH BEACH", streetName: "OCEAN DRIVE",
            skyTop: ColorRGB(0.15, 0.35, 0.55), skyBottom: ColorRGB(0.95, 0.65, 0.40), ground: ColorRGB(0.35, 0.32, 0.28),
            palette: [ColorRGB(0.95, 0.75, 0.80), ColorRGB(0.65, 0.90, 0.80), ColorRGB(0.95, 0.90, 0.75), ColorRGB(0.70, 0.80, 0.95)],
            buildingNames: ["ART DECO HOTEL", "PALMS INN", "CAFÉ CUBANO", "BEACH CLUB", "BODEGA", "SURF SHOP"],
            minBuildingH: 180, maxBuildingH: 480,
            shops: ["VERSACEE", "OCEAN DRIVE OUTFITTERS", "CUBAN COFFEE CO.", "PALM & CO.", "NEON NIGHTS", "HAVANA CLUBB", "WACKDONALD'S", "STARBOCK'S"],
            propEmojis: ["🚗", "🚕", "🛵", "🚲"], crossStreets: ["COLLINS AVE", "WASHINGTON AVE", "MERIDIAN AVE", "5TH ST"],
            landmark: "FREEDOM TOWER", landmarkStyle: .tower, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.36, 0.24, 0.16)], crowdClothes: [ColorRGB(0.95, 0.5, 0.65), ColorRGB(0.4, 0.9, 0.8), ColorRGB(0.95, 0.9, 0.3), ColorRGB(0.9, 0.88, 0.85), ColorRGB(0.3, 0.6, 0.9)], crowdDensity: 25, destructionValue: 3000000000000, releaseMonth: "2026-10")
        case .seattle: return CitySpec(name: "SEATTLE", tagline: "It was already raining debris.", icon: "☕",
            district: "DOWNTOWN", streetName: "PINE STREET",
            skyTop: ColorRGB(0.25, 0.32, 0.38), skyBottom: ColorRGB(0.55, 0.62, 0.60), ground: ColorRGB(0.28, 0.30, 0.30),
            palette: [ColorRGB(0.55, 0.60, 0.62), ColorRGB(0.45, 0.55, 0.50), ColorRGB(0.68, 0.58, 0.50), ColorRGB(0.50, 0.55, 0.65)],
            buildingNames: ["PIKE PLACE INN", "COFFEE HOUSE", "BOOKSHOP", "BREW PUB", "OUTFITTERS", "BAKERY"],
            minBuildingH: 200, maxBuildingH: 420,
            shops: ["STARBOCK'S (THE FIRST ONE)", "NORDSTROMM", "AMAZONIA BOOKS", "REII", "SUB POPPY RECORDS", "PIKE PLACE FISH CO.", "WACKDONALD'S", "PCCC MARKETS", "ELLIOTT BAY BOOK CO."],
            propEmojis: ["🚗", "🚕", "🚲", "🚌"], crossStreets: ["1ST AVE", "4TH AVE", "WESTLAKE", "OLIVE WAY"],
            landmark: "SPACE NEEDLE", landmarkStyle: .needle, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.93, 0.76, 0.62)], crowdClothes: [ColorRGB(0.3, 0.4, 0.35), ColorRGB(0.25, 0.3, 0.45), ColorRGB(0.5, 0.45, 0.4), ColorRGB(0.15, 0.15, 0.17), ColorRGB(0.6, 0.55, 0.5)], crowdDensity: 24, destructionValue: 3000000000000, releaseMonth: "2026-10")
        case .washingtonDC: return CitySpec(name: "WASHINGTON DC", tagline: "The monument was load-bearing. Emotionally.", icon: "🏛️",
            district: "DOWNTOWN", streetName: "PENNSYLVANIA AVENUE",
            skyTop: ColorRGB(0.20, 0.28, 0.45), skyBottom: ColorRGB(0.70, 0.60, 0.50), ground: ColorRGB(0.30, 0.30, 0.30),
            palette: [ColorRGB(0.90, 0.88, 0.84), ColorRGB(0.82, 0.80, 0.76), ColorRGB(0.75, 0.72, 0.68), ColorRGB(0.88, 0.84, 0.78)],
            buildingNames: ["FEDERAL HOTEL", "ARCHIVES INN", "CAFÉ", "BOOKSELLER", "MUSEUM SHOP", "DELI"],
            minBuildingH: 120, maxBuildingH: 170,
            shops: ["SMITHSONIANA STORE", "CAPITOL GIFTS", "LOBBY & CO.", "ARCHIVE OUTFITTERS", "WACKDONALD'S", "STARBOCK'S", "UNION STATION SHOPS", "GEORGETOWN CUPCAKEY", "POLITICS & PROSEY"],
            propEmojis: ["🚗", "🚕", "🚌", "🚲"], crossStreets: ["7TH ST NW", "9TH ST NW", "CONSTITUTION AVE", "E ST NW"],
            landmark: "WASHINGTON MONUMENT", landmarkStyle: .needle, backdropSign: nil,
            crowdSkin: [ColorRGB(0.36, 0.24, 0.16), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.72, 0.55, 0.38)], crowdClothes: [ColorRGB(0.15, 0.18, 0.3), ColorRGB(0.4, 0.1, 0.15), ColorRGB(0.85, 0.84, 0.8), ColorRGB(0.3, 0.3, 0.32), ColorRGB(0.55, 0.5, 0.45)], crowdDensity: 25, destructionValue: 3500000000000, releaseMonth: "2026-10")
        case .cairo: return CitySpec(name: "CAIRO", tagline: "The pyramids survived 4,500 years. Then you visited.", icon: "🐪",
            district: "ZAMALEK", streetName: "CORNICHE EL NIL",
            skyTop: ColorRGB(0.30, 0.25, 0.35), skyBottom: ColorRGB(0.90, 0.65, 0.40), ground: ColorRGB(0.40, 0.35, 0.28),
            palette: [ColorRGB(0.85, 0.75, 0.58), ColorRGB(0.78, 0.66, 0.48), ColorRGB(0.88, 0.80, 0.65), ColorRGB(0.70, 0.60, 0.45)],
            buildingNames: ["NILE HOTEL", "AHWA COFFEE", "BAZAAR", "KHAN SHOP", "FALAFEL HOUSE", "BOOKBINDERY"],
            minBuildingH: 130, maxBuildingH: 260,
            shops: ["KHAN EL-KHALILY TRADERS", "NILE TEXTILES", "PAPYRUS & CO.", "SPICE SONS", "WACKDONALD'S", "STARBOCK'S", "ATTABA BOOKS", "FELUCCA TOURS", "CAIRO TOWER GIFTS"],
            propEmojis: ["🚗", "🚕", "🚌", "🐪"], crossStreets: ["GEZIRA ST", "BRAZIL ST", "ABOU EL FIDA", "EL NILE ST"],
            landmark: "PYRAMIDS OF GIZA", landmarkStyle: .pyramid, backdropSign: nil,
            crowdSkin: [ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.72, 0.55, 0.38)], crowdClothes: [ColorRGB(0.9, 0.88, 0.85), ColorRGB(0.25, 0.3, 0.5), ColorRGB(0.6, 0.45, 0.25), ColorRGB(0.15, 0.15, 0.17), ColorRGB(0.7, 0.3, 0.3)], crowdDensity: 30, destructionValue: 2000000000000, releaseMonth: "2026-10")
        case .istanbul: return CitySpec(name: "ISTANBUL", tagline: "Two continents. Zero survivors.", icon: "🕌",
            district: "BEYOĞLU", streetName: "İSTİKLAL CADDESİ",
            skyTop: ColorRGB(0.22, 0.20, 0.38), skyBottom: ColorRGB(0.85, 0.55, 0.38), ground: ColorRGB(0.32, 0.28, 0.26),
            palette: [ColorRGB(0.82, 0.68, 0.52), ColorRGB(0.75, 0.58, 0.44), ColorRGB(0.86, 0.74, 0.60), ColorRGB(0.65, 0.55, 0.48)],
            buildingNames: ["PERA HOTEL", "MEYHANE", "KİTABEVİ", "TATLICI", "ÇİÇEK PASAJI", "HAMAM"],
            minBuildingH: 140, maxBuildingH: 280,
            shops: ["LC WAIKIKIKI", "MADOH", "GRAND BAZAAR TRADERS", "TURKISH DELIGHT & SONS", "WACKDONALD'S", "STARBOCK'S", "NARGILE & CO.", "PERA PALACE GIFTS", "SIMIT SARAYII"],
            propEmojis: ["🚗", "🚕", "🚃", "🛵"], crossStreets: ["TAKSIM", "GALATA", "SIRASELVILER", "MEŞRUTİYET"],
            landmark: "HAGIA SOPHIA", landmarkStyle: .dome, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38)], crowdClothes: [ColorRGB(0.5, 0.15, 0.2), ColorRGB(0.2, 0.25, 0.4), ColorRGB(0.88, 0.86, 0.82), ColorRGB(0.15, 0.15, 0.17), ColorRGB(0.65, 0.5, 0.3)], crowdDensity: 30, destructionValue: 3000000000000, releaseMonth: "2026-11")
        case .moscow: return CitySpec(name: "MOSCOW", tagline: "Winter is coming. So is she.", icon: "🧅",
            district: "TVERSKOY", streetName: "TVERSKAYA",
            skyTop: ColorRGB(0.20, 0.24, 0.40), skyBottom: ColorRGB(0.60, 0.55, 0.55), ground: ColorRGB(0.32, 0.32, 0.34),
            palette: [ColorRGB(0.75, 0.72, 0.70), ColorRGB(0.68, 0.62, 0.58), ColorRGB(0.82, 0.75, 0.60), ColorRGB(0.60, 0.60, 0.65)],
            buildingNames: ["HOTEL METROPOL", "KNIGI BOOKS", "KAFE", "TEATR", "MAGAZIN", "PEKARNYA"],
            minBuildingH: 150, maxBuildingH: 320,
            shops: ["GUMM", "TSUMM", "MATRYOSHKA & CO.", "CAVIAR HOUSE", "WACKDONALD'S", "STARBOCK'S", "RED SQUARE SOUVENIRS", "USHANKA & CO.", "BLINI HOUSE"],
            propEmojis: ["🚗", "🚕", "🚌", "🚙"], crossStreets: ["KAMERGERSKY", "STRATOY PEREULOK", "GAZETNY", "BOLSHAYA NIKITSKAYA"],
            landmark: "ST. BASIL'S CATHEDRAL", landmarkStyle: .dome, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5)], crowdClothes: [ColorRGB(0.25, 0.2, 0.3), ColorRGB(0.5, 0.15, 0.18), ColorRGB(0.35, 0.35, 0.38), ColorRGB(0.15, 0.15, 0.17), ColorRGB(0.6, 0.5, 0.4)], crowdDensity: 28, destructionValue: 4000000000000, releaseMonth: "2026-12")
        case .athens: return CitySpec(name: "ATHENS", tagline: "Democracy's hometown. Now rubble's.", icon: "🏺",
            district: "PLAKA", streetName: "ERMOU",
            skyTop: ColorRGB(0.20, 0.30, 0.50), skyBottom: ColorRGB(0.85, 0.65, 0.42), ground: ColorRGB(0.34, 0.31, 0.28),
            palette: [ColorRGB(0.92, 0.90, 0.85), ColorRGB(0.85, 0.78, 0.65), ColorRGB(0.78, 0.70, 0.58), ColorRGB(0.65, 0.72, 0.80)],
            buildingNames: ["PLAKA HOTEL", "TAVERNA", "OUZERİ", "BOOKSHOP", "BAKERY", "SANDAL MAKER"],
            minBuildingH: 110, maxBuildingH: 170,
            shops: ["ATTIKAA", "OLIVE & CO.", "MONASTIRAKI TRADERS", "EVZONE GIFTS", "WACKDONALD'S", "STARBOCK'S", "FLEA MARKET FINDS", "BOUGATSA & SONS", "MARBLE MINIATURES"],
            propEmojis: ["🚗", "🛵", "🚕", "🚲"], crossStreets: ["ADRIANOU", "PANDROSSOU", "MITROPOLEOS", "ATHINAS"],
            landmark: "ACROPOLIS", landmarkStyle: .tiers, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.93, 0.76, 0.62)], crowdClothes: [ColorRGB(0.25, 0.4, 0.7), ColorRGB(0.9, 0.88, 0.85), ColorRGB(0.55, 0.5, 0.4), ColorRGB(0.2, 0.5, 0.4), ColorRGB(0.15, 0.15, 0.17)], crowdDensity: 26, destructionValue: 2000000000000, releaseMonth: "2027-01")
        case .prague: return CitySpec(name: "PRAGUE", tagline: "A fairy tale, until the screaming starts.", icon: "🏰",
            district: "STARÉ MĚSTO", streetName: "PAŘÍŽSKÁ",
            skyTop: ColorRGB(0.25, 0.22, 0.38), skyBottom: ColorRGB(0.70, 0.55, 0.45), ground: ColorRGB(0.30, 0.28, 0.28),
            palette: [ColorRGB(0.80, 0.70, 0.58), ColorRGB(0.72, 0.60, 0.48), ColorRGB(0.85, 0.76, 0.64), ColorRGB(0.60, 0.52, 0.46)],
            buildingNames: ["HOTEL PAŘÍŽ", "PIVNICE", "KAVÁRNA", "KNIHKUPECTVÍ", "HODINÁŘ", "PEKAŘSTVÍ"],
            minBuildingH: 120, maxBuildingH: 180,
            shops: ["BOHEMIA CRYSTAL CO.", "TRDELNÍK & SONS", "PRAGUE CLOCK GIFTS", "ALCHEMY SHOP", "WACKDONALD'S", "STARBOCK'S", "GARNET & GOLD", "OLD TOWN PUPPETS", "ABSINTH & CO."],
            propEmojis: ["🚗", "🚕", "🚃", "🚲"], crossStreets: ["DLOUHÁ", "ŠIROKÁ", "KAPROVA", "MELANTRICHOVA"],
            landmark: "CHARLES BRIDGE", landmarkStyle: .bridge, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5)], crowdClothes: [ColorRGB(0.35, 0.25, 0.2), ColorRGB(0.2, 0.3, 0.5), ColorRGB(0.6, 0.55, 0.5), ColorRGB(0.15, 0.15, 0.17), ColorRGB(0.5, 0.2, 0.2)], crowdDensity: 25, destructionValue: 1800000000000, releaseMonth: "2027-02")
        case .capeTown: return CitySpec(name: "CAPE TOWN", tagline: "The mountain watched for a million years. Then blinked.", icon: "⛰️",
            district: "CITY BOWL", streetName: "LONG STREET",
            skyTop: ColorRGB(0.18, 0.30, 0.48), skyBottom: ColorRGB(0.75, 0.60, 0.45), ground: ColorRGB(0.32, 0.30, 0.28),
            palette: [ColorRGB(0.90, 0.60, 0.55), ColorRGB(0.55, 0.80, 0.70), ColorRGB(0.95, 0.85, 0.60), ColorRGB(0.60, 0.70, 0.90)],
            buildingNames: ["LONG ST HOTEL", "BOOK LOUNGE", "CAFÉ", "BACKPACKERS", "CURIO SHOP", "BAKERY"],
            minBuildingH: 130, maxBuildingH: 240,
            shops: ["WOOLWORTHSS", "KIRSTENBOSCH GIFTS", "BO-KAAP COLORS", "SURF & CO.", "WACKDONALD'S", "STARBOCK'S", "LONG ST BOOKS", "SAFARI OUTFITTERS", "ROOIBOS & CO."],
            propEmojis: ["🚗", "🚕", "🚌", "🛵"], crossStreets: ["WALE ST", "LOOP ST", "BUITENSINGEL", "KLOOF ST"],
            landmark: "TABLE MOUNTAIN", landmarkStyle: .tiers, backdropSign: nil,
            crowdSkin: [ColorRGB(0.36, 0.24, 0.16), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.48, 0.33, 0.22), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.36, 0.24, 0.16)], crowdClothes: [ColorRGB(0.9, 0.6, 0.15), ColorRGB(0.2, 0.6, 0.4), ColorRGB(0.85, 0.3, 0.35), ColorRGB(0.3, 0.4, 0.7), ColorRGB(0.9, 0.88, 0.85)], crowdDensity: 24, destructionValue: 1500000000000, releaseMonth: "2027-03")
        case .auckland: return CitySpec(name: "AUCKLAND", tagline: "City of sails. Sea of rubble.", icon: "⛵",
            district: "CBD", streetName: "QUEEN STREET",
            skyTop: ColorRGB(0.20, 0.30, 0.45), skyBottom: ColorRGB(0.65, 0.62, 0.55), ground: ColorRGB(0.30, 0.30, 0.30),
            palette: [ColorRGB(0.70, 0.72, 0.75), ColorRGB(0.62, 0.65, 0.70), ColorRGB(0.80, 0.75, 0.65), ColorRGB(0.55, 0.62, 0.68)],
            buildingNames: ["QUEEN ST HOTEL", "CAFÉ", "BOOKSHOP", "OUTDOOR OUTFITTERS", "BAKERY", "FISH & CHIPS"],
            minBuildingH: 150, maxBuildingH: 300,
            shops: ["FARMERSS", "KIWI MART", "PAKNSAVEE", "JADE & CO.", "WACKDONALD'S", "STARBOCK'S", "QUEEN ST ARCADE", "MANUKA & CO.", "HARBOUR FISH MARKET"],
            propEmojis: ["🚗", "🚕", "🚌", "⛵"], crossStreets: ["CUSTOMS ST", "SHORTLAND ST", "FORT ST", "MAYORAL DR"],
            landmark: "SKY TOWER", landmarkStyle: .needle, backdropSign: nil,
            crowdSkin: [ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.72, 0.55, 0.38), ColorRGB(0.62, 0.44, 0.3), ColorRGB(0.93, 0.76, 0.62), ColorRGB(0.85, 0.66, 0.5), ColorRGB(0.48, 0.33, 0.22)], crowdClothes: [ColorRGB(0.15, 0.15, 0.17), ColorRGB(0.3, 0.45, 0.6), ColorRGB(0.2, 0.55, 0.35), ColorRGB(0.85, 0.84, 0.8), ColorRGB(0.65, 0.25, 0.3)], crowdDensity: 22, destructionValue: 1600000000000, releaseMonth: "2027-04")
        }
    }

    public var name: String { spec.name }
    public var tagline: String { spec.tagline }
    public var icon: String { spec.icon }
    public var district: String { spec.district }
    public var destructionValue: Int { spec.destructionValue }
    public var releaseMonth: String { spec.releaseMonth }
    /// Monthly city drops: a city unlocks at midnight on the 1st of
    /// its release month and stays unlocked forever after.
    public func isAvailable(now: Date = Date()) -> Bool {
        let parts = spec.releaseMonth.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 2 else { return true }
        let c = Calendar.current.dateComponents([.year, .month], from: now)
        let cy = c.year ?? 9999, cm = c.month ?? 12
        return cy > parts[0] || (cy == parts[0] && cm >= parts[1])
    }
    public var streetName: String { spec.streetName }
    public var skyTop: ColorRGB { spec.skyTop }
    public var skyBottom: ColorRGB { spec.skyBottom }
    public var groundColor: ColorRGB { spec.ground }
    public var buildingPalette: [ColorRGB] { spec.palette }
    public var buildingNames: [String] { spec.buildingNames }
    public var minBuildingH: Double { spec.minBuildingH }
    public var maxBuildingH: Double { spec.maxBuildingH }
    public var shops: [String] { spec.shops }
    public var propEmojis: [String] { spec.propEmojis }
    public var crossStreets: [String] { spec.crossStreets }
    public var landmarkName: String { spec.landmark }
    public var landmarkStyle: LandmarkStyle { spec.landmarkStyle }
    public var backdropSign: String? { spec.backdropSign }
    public var crowdSkin: [ColorRGB] { spec.crowdSkin }
    public var crowdClothes: [ColorRGB] { spec.crowdClothes }
    public var crowdDensity: Int { spec.crowdDensity }
}

// MARK: - Timer options

public enum TimerOption: Int, CaseIterable {
    case sixty = 60
    case oneTwenty = 120
    case oneEighty = 180
    case freePlay = 0

    public var isFreePlay: Bool { self == .freePlay }
    public var label: String { isFreePlay ? "FREE PLAY" : "\(rawValue) SECONDS" }
}
