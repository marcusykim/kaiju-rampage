import AppKit
import AVFoundation
import SpriteKit

// MARK: - World objects

private final class Building {
    let name: String
    let isLandmark: Bool
    let maxHP: Int
    var hp: Int
    let centerX: CGFloat
    let width: CGFloat
    let height: CGFloat
    let group = SKNode()
    let body: SKShapeNode
    let baseColor: NSColor
    var destroyed = false

    init(name: String, isLandmark: Bool, maxHP: Int, centerX: CGFloat,
         width: CGFloat, height: CGFloat, body: SKShapeNode, baseColor: NSColor) {
        self.name = name
        self.isLandmark = isLandmark
        self.maxHP = maxHP
        self.hp = maxHP
        self.centerX = centerX
        self.width = width
        self.height = height
        self.body = body
        self.baseColor = baseColor
    }

    var left: CGFloat { centerX - width / 2 }
    var right: CGFloat { centerX + width / 2 }
    var hpFraction: Double { max(0, Double(hp) / Double(maxHP)) }
}

private final class Car {
    var x: CGFloat
    let dir: CGFloat
    let speed: CGFloat
    let laneY: CGFloat
    var alive = true
    var honkTimer: Double = 0
    let node = SKNode()
    init(x: CGFloat, lane: Int, groundY: CGFloat) {
        self.x = x
        // Lane 0 = far side of the street (drives left), lane 1 =
        // near side (drives right) — right-hand traffic.
        self.dir = lane == 0 ? -1 : 1
        self.laneY = groundY + (lane == 0 ? 30 : -16)
        self.speed = CGFloat.random(in: 55...85)
    }
}

private final class Prop {
    let emoji: String
    let x: CGFloat
    let node = SKNode()
    var destroyed = false
    init(emoji: String, x: CGFloat) { self.emoji = emoji; self.x = x }
}

/// One extremely squashable citizen. Dancers and influencers are too
/// busy filming to flee; big pedestrians are worth the most points.
private final class Pedestrian {
    enum Kind { case walker, dancer, influencer, big }
    let kind: Kind
    let node = SKNode()
    let bodyG = SKNode()
    let legL = SKNode()
    let legR = SKNode()
    let armL = SKNode()
    let armR = SKNode()
    var x: CGFloat
    var dir: CGFloat
    var baseSpeed: CGFloat
    var phase: Double = Double.random(in: 0...6.28)
    var alive = true
    init(kind: Kind, x: CGFloat, dir: CGFloat, baseSpeed: CGFloat) {
        self.kind = kind
        self.x = x
        self.dir = dir
        self.baseSpeed = baseSpeed
    }
}

// MARK: - Scene

final class GameScene: SKScene {

    private enum State { case monsterSelect, citySelect, timeSelect, playing, gameOver }

    private struct ClickTarget {
        let rect: CGRect // camera space
        let index: Int
    }

    // Constants
    private let worldWidth: CGFloat = 3600
    private let groundY: CGFloat = 150

    // Selection
    private var state: State = .monsterSelect
    private var selectedMonster: MonsterKind = .razorback
    private var selectedCity: CityKind = .paris
    private var monsterPage = 0
    private var cityPage = 0
    private var cityPageCount: Int { (CityKind.allCases.count + 7) / 8 }
    private var showingLeaderboard = false
    private var clickTargets: [ClickTarget] = []
    private var overlay: SKNode?

    // Camera + HUD
    private let cam = SKCameraNode()
    private let damageLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let timerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let progressLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let specialLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let comboLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let eventLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let placeLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")

    // World
    private let world = SKNode()
    private var buildings: [Building] = []
    private var props: [Prop] = []
    private var effects = SKNode()

    // Monster
    private var monster = SKNode()
    private var monsterArm = SKNode()
    private var monsterBodyGroup = SKNode()
    private var facing: CGFloat = 1
    private var monsterVelY: CGFloat = 0
    private var onGround = true
    private var walkCycle: Double = 0
    private var attackCooldown: Double = 0
    private var specialCooldown: Double = 0

    // Run state
    private var isPausedGame = false
    private var keysPressed = Set<UInt16>()
    private var lastUpdate: TimeInterval = 0
    private var timeLeft: Double = 120
    private var damageDollars = 0
    private var comboCount = 0
    private var comboLevel = 1
    private var comboTimer: Double = 0
    private var activeEvent: Scoring.CityEvent?
    private var eventTimer: Double = 0
    private var eventNextIn: Double = 35
    private var cars: [Car] = []
    private var carRespawnTimer: Double = 0
    private var destroyedHP = 0
    private var totalHP = 1
    /// Dollars per HP for the current city — set at build time from
    /// the city's realistic total asset value (see Scoring).
    private var claimRate: Double = 0
    private var buildingsToppled = 0
    private var propsSmashed = 0
    private var didBuild = false

    // Maldo — the evil one in the striped shirt, wandering somewhere in the city
    private var maldo = SKNode()
    private var maldoLegL = SKNode()
    private var maldoLegR = SKNode()
    private var maldoAlive = false
    private var maldoX: CGFloat = 0
    private var maldoHome: CGFloat = 0
    private var maldoDir: CGFloat = 1
    private var maldoPhase: Double = 0
    private var maldoRespawn: Double = 0
    private var maldoKills = 0

    // THE GOLDEN SNITCH — one per player account, hidden somewhere in
    // exactly one city in the whole world, out on the street talking
    // to a cop. The hunt persists across runs, cities, and days:
    // every run banks its points, nothing locks in, and THE GAME
    // DOESN'T END until he's crushed — then the whole bank goes
    // ×10 onto the leaderboard and a new hunt begins.
    private var snitch = SKNode()
    private var snitchLegL = SKNode()
    private var snitchLegR = SKNode()
    private var snitchWingA = SKNode()
    private var snitchWingB = SKNode()
    private var snitchCity: CityKind?
    private var snitchPresent = false
    private var snitchGone = false
    private var snitchCaughtRun = false
    private var snitchX: CGFloat = 0
    private var snitchHome: CGFloat = 0
    private var snitchDir: CGFloat = 1
    private var snitchPhase: Double = 0
    private var snitchDodges = 0
    private var huntDaysAtCatch = 1
    // The one officer the Snitch is out front talking to
    private var officer = SKNode()
    private var officerLegL = SKNode()
    private var officerLegR = SKNode()
    private var officerX: CGFloat = 0
    private var officerState = 0 // 0 = talking, 1 = booking it, 2 = gone
    private var officerPhase: Double = 0
    private var officerRunDist: CGFloat = 0
    private var talkBubble = SKNode()
    private var talkLabel = SKLabelNode()
    private var talkTimer: Double = 0
    private var talkTurn = false

    private let snitchCityKey = "kaijurampage.snitch.city.v1"
    private let snitchSeasonKey = "kaijurampage.hunt.season.v1"
    private let huntBankKey = "kaijurampage.hunt.bank.v1"
    /// Points banked by this hunt so far — every run adds its damage
    /// here, unlocked, until the Snitch is crushed and it all locks
    /// in at ×10. Persists across sessions: the game doesn't end
    /// until he's found.
    private var huntBank = 0

    // MARK: City clocks — one hour per city per season, freezable

    private enum EndReason { case leftCity, clockSpent }
    private var endReason: EndReason = .leftCity
    private var cityProgress: [Int: CityProgress] = [:]
    private var elapsedBase: Double = 0
    private var sessionElapsed: Double = 0
    private var huntBankAtEntry = 0
    private var foldedAtEntry = 0
    private var autosaveTimer: Double = 0
    private var cityProgressKey: String { "kaijurampage.cityprogress.\(seasonKey)" }
    private var rngState: UInt64 = 0x9E3779B97F4A7C15

    private func loadCityProgress() {
        guard let data = UserDefaults.standard.data(forKey: cityProgressKey),
              let decoded = try? JSONDecoder().decode([Int: CityProgress].self, from: data) else {
            cityProgress = [:]
            return
        }
        cityProgress = decoded
    }

    private func saveCityProgress() {
        if let data = try? JSONEncoder().encode(cityProgress) {
            UserDefaults.standard.set(data, forKey: cityProgressKey)
        }
    }

    /// Freeze the current city exactly as it stands — clock, rubble,
    /// bank — so leaving (or crashing) never loses or doubles a dime.
    private func snapshotProgress(bank: Int, folded: Int) {
        var prog = cityProgress[selectedCity.rawValue] ?? CityProgress()
        prog.elapsed = min(Scoring.cityBudgetSeconds, elapsedBase + sessionElapsed)
        prog.buildingHP = Dictionary(uniqueKeysWithValues:
            buildings.enumerated().compactMap { (i, b) in b.hp < b.maxHP ? (String(i), b.hp) : nil })
        prog.deadProps = props.enumerated().compactMap { $0.element.destroyed ? $0.offset : nil }
        prog.damageFolded = folded
        if snitchCaughtRun { prog.snitchCaught = true; prog.snitchDay = huntDaysAtCatch }
        cityProgress[selectedCity.rawValue] = prog
        huntBank = bank
        UserDefaults.standard.set(huntBank, forKey: huntBankKey)
        saveCityProgress()
    }

    private func clockText(_ seconds: Double) -> String {
        let t = max(0, Int(seconds.rounded()))
        return String(format: "%d:%02d", t / 60, t % 60)
    }

    // Deterministic per-city-per-season RNG (SplitMix64): a city
    // generates identically on every visit, so frozen rubble lines
    // up with the same buildings when the player returns.
    private func seedRNG() {
        let c = Calendar.current.dateComponents([.year, .month], from: Date())
        rngState = UInt64((c.year ?? 2026) * 100 + (c.month ?? 1)) &* 1_000_003
            &+ UInt64(selectedCity.rawValue &+ 1) &* 97_531 &+ 0x9E3779B97F4A7C15
    }
    private func nextRandom() -> Double {
        rngState &+= 0x9E3779B97F4A7C15
        var z = rngState
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        z = z ^ (z >> 31)
        return Double(z >> 11) / Double(1 << 53)
    }
    private func randIn(_ range: ClosedRange<CGFloat>) -> CGFloat {
        range.lowerBound + CGFloat(nextRandom()) * (range.upperBound - range.lowerBound)
    }

    // MARK: Mama — the monsters' alien mom, somewhere up in the
    // heavens. She took out the insurance policy on planet Earth;
    // her voice chimes in at random while you work. M mutes her
    // (she'll remember that).

    private let mamaSynth = AVSpeechSynthesizer()
    private var mamaMuted = false
    private var mamaTimer: Double = 0
    private var mamaNextChime: Double = 22
    private var lastMamaLine = ""

    private let mamaHurryLines = [
        "DON'T YOU FUCK THIS UP, MY BOY!",
        "HURRY UP AND FIND THAT SNITCH, BABY!",
        "THE POLICY DON'T PAY WHILE THAT CHOLO'S TALKING!",
        "MAMA'S WATCHING FROM UP HERE. ALWAYS WATCHING.",
        "EVERY DAY YOU WAIT, THEY TAKE A CUT OF MAMA'S MONEY!",
        "FROM UP HERE IT ALL LOOKS VERY FLAMMABLE, BABY.",
        "MAMA TOOK OUT A POLICY ON THIS WHOLE PLANET. DON'T EMBARRASS ME.",
        "YOUR SISTER ROSE WOULD HAVE FOUND HIM BY NOW.",
        "TICK TOCK, BABY. MAMA'S GOT BILLS.",
        "NO SNITCH, NO PAYOUT. IT'S NOT COMPLICATED.",
        "THE ALIEN COPS ARE LISTENING, BABY. HURRY.",
        "MAMA DIDN'T FLY A MILLION LIGHT-YEARS TO WATCH YOU DAWDLE.",
    ]
    private let mamaPraiseLines = [
        "THAT'S MY BABY!",
        "MAMA RAISED YOU RIGHT!",
        "LOOK AT MY BABY GO!",
        "MAMA'S RICH, BABY. MAMA'S RICH!",
    ]

    private func showMamaText(_ line: String) {
        let label = makeLabel("✨ MAMA: \(line)", size: 20,
                              color: NSColor(calibratedRed: 1, green: 0.85, blue: 0.4, alpha: 1),
                              pos: CGPoint(x: 0, y: 322))
        label.zPosition = 95
        cam.addChild(label)
        label.run(.sequence([
            .group([.moveBy(x: 0, y: -30, duration: 4.4), .fadeOut(withDuration: 4.4)]),
            .removeFromParent()
        ]))
    }

    /// Every sound effect routes through here so the M key
    /// silences the whole game, not just Mama.
    private func playSFX(_ name: String) {
        guard !mamaMuted else { return }
        NSSound(named: name)?.play()
    }

    private func mamaSays(_ line: String) {
        showMamaText(line)
        guard !mamaMuted else { return }
        let utterance = AVSpeechUtterance(string: line)
        utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-US.Samantha")
            ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.44
        utterance.pitchMultiplier = 0.72 // booming, from very far above
        utterance.volume = 0.95
        mamaSynth.speak(utterance)
    }

    private func mamaChime() {
        var line = mamaHurryLines.randomElement() ?? mamaHurryLines[0]
        if line == lastMamaLine, let i = mamaHurryLines.firstIndex(of: line) {
            line = mamaHurryLines[(i + 1) % mamaHurryLines.count]
        }
        lastMamaLine = line
        mamaSays(line)
    }

    // MARK: Sellout ads — the monetization, worn proudly on our
    // sleeve. Watch an ad, get points in the hunt bank. We say the
    // quiet part out loud: you sell out. Everyone wins.

    private var adTimeLeft: Double = 0
    private var adCountdownLabel: SKLabelNode?
    private var adMenuShowing = false
    private var currentAdPayout = 0
    private var adsDateKey: String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return "kaijurampage.ads.\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }
    private var adsToday: Int { UserDefaults.standard.integer(forKey: adsDateKey) }

    private func showAdMenu() {
        guard state == .citySelect, adTimeLeft <= 0 else { return }
        guard adsToday < Scoring.dailyAdCap else {
            playSFX("Basso")
            mamaSays("THAT'S ENOUGH SELLING OUT FOR TODAY, BABY. MAMA RAISED A DIGNIFIED FAMILY.")
            return
        }
        adMenuShowing = true
        let node = beginOverlay(title: "📺 THE SELLOUT MENU",
                                subtitle: "Real companies pay real money to be on this menu. Pick one and sell out — longer ads pay you more.")
        for (i, offer) in Scoring.adMenu.enumerated() {
            let y = 200 - CGFloat(i) * 68
            if offer.premium {
                // Premium placement: gold frame, top of the catalog.
                // They paid extra for exactly this.
                let frame = SKShapeNode(rectOf: CGSize(width: 960, height: 62), cornerRadius: 10)
                frame.position = CGPoint(x: 0, y: y - 6)
                frame.fillColor = NSColor(calibratedRed: 1, green: 0.85, blue: 0.4, alpha: 0.10)
                frame.strokeColor = NSColor(calibratedRed: 1, green: 0.85, blue: 0.4, alpha: 1)
                frame.lineWidth = 2
                node.addChild(frame)
            }
            node.addChild(makeLabel("\(i + 1) · \(offer.emoji) \(offer.brand)", size: 24,
                                    color: offer.premium
                                        ? NSColor(calibratedRed: 1, green: 0.85, blue: 0.4, alpha: 1)
                                        : .white,
                                    pos: CGPoint(x: 0, y: y)))
            let tag = offer.premium ? "★ PREMIUM PLACEMENT · " : ""
            let houseTag = offer.house ? " · HOUSE AD — THIS SLOT IS FOR SALE" : ""
            node.addChild(makeLabel("\(tag)\(offer.seconds) seconds → +\(Scoring.formatDollars(offer.payout)) in your hunt bank — “\(offer.slogan)”\(houseTag)",
                                    size: 14.5, bold: false, color: NSColor(white: 1, alpha: 0.8),
                                    pos: CGPoint(x: 0, y: y - 28)))
            clickTargets.append(ClickTarget(
                rect: CGRect(x: -470, y: y - 38, width: 940, height: 64), index: 9000 + i))
        }
        node.addChild(makeLabel("Points are claim dollars: they bank now and pay out ×10 when you crush the Snitch. Sold out ×\(adsToday) today — \(Scoring.dailyAdCap) a day, max. Esc backs out.",
                                size: 13.5, bold: false, color: NSColor(white: 1, alpha: 0.65),
                                pos: CGPoint(x: 0, y: -245)))
    }

    private func playAd(at index: Int) {
        guard Scoring.adMenu.indices.contains(index) else { return }
        let offer = Scoring.adMenu[index]
        adMenuShowing = false
        currentAdPayout = offer.payout
        let node = beginOverlay(title: "📺 A WORD FROM OUR SPONSORS",
                                subtitle: "This is the deal. You watch. They pay. You sell out.")
        node.addChild(makeLabel(offer.emoji, size: 110, pos: CGPoint(x: 0, y: 120)))
        node.addChild(makeLabel(offer.brand, size: 34,
                                color: NSColor(calibratedRed: 1, green: 0.85, blue: 0.4, alpha: 1),
                                pos: CGPoint(x: 0, y: 20)))
        node.addChild(makeLabel("“\(offer.slogan)”", size: 20, bold: false,
                                pos: CGPoint(x: 0, y: -24)))
        node.addChild(makeLabel("Reward lands in your hunt bank: \(Scoring.formatDollars(offer.payout))",
                                size: 16, bold: false, color: NSColor(white: 1, alpha: 0.75),
                                pos: CGPoint(x: 0, y: -80)))
        adCountdownLabel = makeLabel("", size: 22, pos: CGPoint(x: 0, y: -170))
        node.addChild(adCountdownLabel!)
        adTimeLeft = Double(offer.seconds)
    }

    private func finishAd() {
        adTimeLeft = 0
        adCountdownLabel = nil
        huntBank += currentAdPayout
        UserDefaults.standard.set(huntBank, forKey: huntBankKey)
        UserDefaults.standard.set(adsToday + 1, forKey: adsDateKey)
        mamaSays(["THAT'S RIGHT, BABY. SELL. SELL. SELL.",
                  "MAMA DIDN'T RAISE NO FOOL. THAT'S RENT MONEY.",
                  "NO SHAME, BABY. THE ADVERTISERS LOVE YOU."].randomElement()!)
        showCitySelect()
    }

    // The season: a calendar month. The timer starts at midnight on
    // the 1st; every day deeper into the month, the Snitch penalty
    // grows by 2% — rack up points, or find him first.
    private var seasonKey: String {
        let c = Calendar.current.dateComponents([.year, .month], from: Date())
        return "\(c.year ?? 2026)-\(c.month ?? 1)"
    }
    private var seasonDay: Int { Calendar.current.component(.day, from: Date()) }
    private var daysInSeason: Int { Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30 }
    private var seasonPenalty: Int { Scoring.snitchPenaltyPercent(dayOfMonth: seasonDay) }
    /// Cities playable right now (monthly drops unlock on the 1st).
    private var availableCities: [CityKind] { CityKind.allCases.filter { $0.isAvailable() } }
    private func dropText(_ city: CityKind) -> String {
        let parts = city.releaseMonth.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 2 else { return city.releaseMonth }
        let months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
        let m = (1...12).contains(parts[1]) ? months[parts[1] - 1] : "???"
        return "\(m) \(parts[0])"
    }

    /// Load this month's hunt. When the month rolls over, the season
    /// resets: a new Snitch hides in a new city, and last month's
    /// unclaimed bank is gone — the deadline is the whole point.
    private func loadSnitchHunt() {
        let d = UserDefaults.standard
        if d.string(forKey: snitchSeasonKey) != seasonKey {
            snitchCity = availableCities.randomElement()
            d.set(snitchCity?.rawValue ?? 0, forKey: snitchCityKey)
            d.set(seasonKey, forKey: snitchSeasonKey)
            huntBank = 0
            d.set(0, forKey: huntBankKey)
        } else if let raw = d.object(forKey: snitchCityKey) as? Int, let c = CityKind(rawValue: raw) {
            snitchCity = c
            huntBank = d.integer(forKey: huntBankKey)
        } else {
            snitchCity = availableCities.randomElement()
            d.set(snitchCity?.rawValue ?? 0, forKey: snitchCityKey)
            huntBank = d.integer(forKey: huntBankKey)
        }
    }
    /// After a crush, a new Golden Snitch hides in a different city —
    /// same season, same month clock still ticking, same penalty
    /// still growing. (The bank already reset at lock-in.)
    private func startNewSnitchHunt() {
        let d = UserDefaults.standard
        var next = availableCities.randomElement()
        if availableCities.count > 1 {
            while next == snitchCity { next = availableCities.randomElement() }
        }
        snitchCity = next
        d.set(next?.rawValue ?? 0, forKey: snitchCityKey)
    }

    // The crowd
    private var pedestrians: [Pedestrian] = []
    private var crowdTarget = 26
    private var crowdRespawn: Double = 0
    private var peopleSquashed = 0

    private enum Key {
        static let a: UInt16 = 0, s: UInt16 = 1, d: UInt16 = 2, w: UInt16 = 13
        static let r: UInt16 = 15, j: UInt16 = 38, k: UInt16 = 40, x: UInt16 = 7
        static let e: UInt16 = 14, enter: UInt16 = 36, keypadEnter: UInt16 = 76
        static let p: UInt16 = 35, space: UInt16 = 49, escape: UInt16 = 53
        static let q: UInt16 = 12
        static let shift: UInt16 = 56, tab: UInt16 = 48, l: UInt16 = 37, f: UInt16 = 3
        static let m: UInt16 = 46, h: UInt16 = 4
        static let left: UInt16 = 123, right: UInt16 = 124, down: UInt16 = 125, up: UInt16 = 126
        static let digits: [UInt16] = [18, 19, 20, 21, 23, 22, 26, 28, 25] // 1...9
    }

    // MARK: Setup

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        view.window?.makeFirstResponder(view)
        guard !didBuild else { return }
        didBuild = true
        addChild(cam)
        camera = cam
        cam.position = CGPoint(x: 640, y: 400)
        addChild(world)
        world.addChild(effects)
        buildHUD()
        loadSnitchHunt()
        loadCityProgress()
        mamaMuted = UserDefaults.standard.bool(forKey: "kaijurampage.muted")
        showMonsterSelect()
        mamaSays("MAMA'S POLICY. MAMA'S RULES. FIND THE SNITCH, BABY.")
    }

    private func nsColor(_ c: ColorRGB, alpha: CGFloat = 1) -> NSColor {
        NSColor(calibratedRed: CGFloat(c.r), green: CGFloat(c.g), blue: CGFloat(c.b), alpha: alpha)
    }

    private func lerpColor(_ a: ColorRGB, _ b: ColorRGB, _ t: CGFloat) -> NSColor {
        let tt = max(0, min(1, t))
        return NSColor(
            calibratedRed: CGFloat(a.r) + (CGFloat(b.r) - CGFloat(a.r)) * tt,
            green: CGFloat(a.g) + (CGFloat(b.g) - CGFloat(a.g)) * tt,
            blue: CGFloat(a.b) + (CGFloat(b.b) - CGFloat(a.b)) * tt,
            alpha: 1)
    }

    private func makeLabel(_ text: String, size: CGFloat, bold: Bool = true,
                           color: NSColor = .white, pos: CGPoint,
                           align: SKLabelHorizontalAlignmentMode = .center) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: bold ? "AvenirNext-Bold" : "AvenirNext-Medium")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.position = pos
        label.horizontalAlignmentMode = align
        label.verticalAlignmentMode = .center
        return label
    }

    private func buildHUD() {
        let bar = SKShapeNode(rectOf: CGSize(width: 1280, height: 54))
        bar.position = CGPoint(x: 0, y: 373)
        bar.fillColor = NSColor(white: 0, alpha: 0.55)
        bar.strokeColor = .clear
        bar.zPosition = 90
        cam.addChild(bar)

        damageLabel.fontSize = 24
        damageLabel.fontColor = NSColor(calibratedRed: 0.55, green: 0.95, blue: 0.55, alpha: 1)
        damageLabel.horizontalAlignmentMode = .left
        damageLabel.verticalAlignmentMode = .center
        damageLabel.position = CGPoint(x: -616, y: 373)
        damageLabel.zPosition = 91
        cam.addChild(damageLabel)

        timerLabel.fontSize = 28
        timerLabel.fontColor = .white
        timerLabel.horizontalAlignmentMode = .center
        timerLabel.verticalAlignmentMode = .center
        timerLabel.position = CGPoint(x: 0, y: 373)
        timerLabel.zPosition = 91
        cam.addChild(timerLabel)

        progressLabel.fontSize = 17
        progressLabel.fontColor = NSColor(calibratedRed: 1, green: 0.8, blue: 0.4, alpha: 1)
        progressLabel.horizontalAlignmentMode = .right
        progressLabel.verticalAlignmentMode = .center
        progressLabel.position = CGPoint(x: 616, y: 373)
        progressLabel.zPosition = 91
        cam.addChild(progressLabel)

        placeLabel.fontSize = 15
        placeLabel.fontColor = NSColor(white: 1, alpha: 0.8)
        placeLabel.horizontalAlignmentMode = .left
        placeLabel.verticalAlignmentMode = .center
        placeLabel.position = CGPoint(x: -616, y: 338)
        placeLabel.zPosition = 91
        cam.addChild(placeLabel)

        specialLabel.fontSize = 15
        specialLabel.fontColor = NSColor(calibratedRed: 0.6, green: 0.85, blue: 1, alpha: 1)
        specialLabel.horizontalAlignmentMode = .right
        specialLabel.verticalAlignmentMode = .center
        specialLabel.position = CGPoint(x: 616, y: 338)
        specialLabel.zPosition = 91
        cam.addChild(specialLabel)

        comboLabel.fontSize = 19
        comboLabel.fontColor = NSColor(calibratedRed: 1, green: 0.6, blue: 0.25, alpha: 1)
        comboLabel.horizontalAlignmentMode = .right
        comboLabel.verticalAlignmentMode = .center
        comboLabel.position = CGPoint(x: 616, y: 310)
        comboLabel.zPosition = 91
        cam.addChild(comboLabel)

        eventLabel.fontSize = 15
        eventLabel.fontColor = NSColor(calibratedRed: 1, green: 0.8, blue: 0.35, alpha: 1)
        eventLabel.horizontalAlignmentMode = .right
        eventLabel.verticalAlignmentMode = .center
        eventLabel.position = CGPoint(x: 616, y: 282)
        eventLabel.zPosition = 91
        cam.addChild(eventLabel)
    }

    private func refreshHUD() {
        damageLabel.text = Scoring.formatDollars(damageDollars) + " DAMAGE"
            + (huntBank > 0 ? "  ·  🏦 BANK " + Scoring.formatDollars(huntBank) : "")
        if state == .playing || state == .gameOver {
            timerLabel.text = "⏱ \(selectedCity.name) \(clockText(timeLeft))"
        } else {
            timerLabel.text = ""
        }
        timerLabel.fontColor = timeLeft <= 60.5 && state == .playing
            ? NSColor(calibratedRed: 1, green: 0.35, blue: 0.35, alpha: 1) : .white
        let pct = Scoring.percentDestroyed(destroyedValue: destroyedHP, totalValue: totalHP)
        progressLabel.text = "\(pct)% DESTROYED · \(buildingsToppled)/\(buildings.count) BUILDINGS"
        placeLabel.text = state == .playing || state == .gameOver
            ? "\(selectedMonster.name) · \(selectedCity.streetName), \(selectedCity.name)" + (state == .playing ? " · Q = LEAVE CITY (CLOCK FREEZES)" : "") : ""
        specialLabel.text = state == .playing
            ? (specialCooldown <= 0 ? "⚡ \(selectedMonster.specialName) READY (E)" : "Special in \(Int(specialCooldown.rounded(.up)))s")
            : ""
        comboLabel.text = state == .playing && comboLevel > 1
            ? "🔥 COMBO ×\(comboLevel) (\(comboCount))"
            : ""
    }

    // MARK: Selection screens

    private func clearOverlay() {
        overlay?.removeFromParent()
        overlay = nil
        clickTargets = []
    }

    private func beginOverlay(title: String, subtitle: String) -> SKNode {
        clearOverlay()
        let node = SKNode()
        node.zPosition = 100

        let dim = SKShapeNode(rectOf: size)
        dim.fillColor = NSColor(calibratedRed: 0.05, green: 0.05, blue: 0.10, alpha: 0.88)
        dim.strokeColor = .clear
        node.addChild(dim)

        node.addChild(makeLabel(title, size: 50,
                                color: NSColor(calibratedRed: 1, green: 0.55, blue: 0.30, alpha: 1),
                                pos: CGPoint(x: 0, y: 322)))
        node.addChild(makeLabel(subtitle, size: 19, bold: false,
                                color: NSColor(white: 1, alpha: 0.85),
                                pos: CGPoint(x: 0, y: 278)))
        overlay = node
        cam.addChild(node)
        return node
    }

    private func pips(filled: Int) -> String {
        String(repeating: "●", count: max(0, min(5, filled)))
            + String(repeating: "○", count: max(0, 5 - min(5, filled)))
    }

    func showMonsterSelect() {
        state = .monsterSelect
        let all = MonsterKind.allCases
        let pageSize = 8
        let pages = (all.count + pageSize - 1) / pageSize
        monsterPage = min(max(0, monsterPage), pages - 1)
        let start = monsterPage * pageSize
        let pageItems = Array(all[start..<min(start + pageSize, all.count)])
        let node = beginOverlay(title: "KAIJU RAMPAGE", subtitle: "Step 1 of 2 — Choose your fighter (keys 1–8 · ←/→ pages · L = leaderboard · H = how to play)")

        for (slot, kind) in pageItems.enumerated() {
            let col = slot % 4
            let row = slot / 4
            let cx = CGFloat(col) * 308 - 462
            let cy: CGFloat = row == 0 ? 112 : -140
            let card = SKShapeNode(rectOf: CGSize(width: 292, height: 224), cornerRadius: 14)
            card.position = CGPoint(x: cx, y: cy)
            card.fillColor = nsColor(kind.bodyColor, alpha: 0.30)
            card.strokeColor = nsColor(kind.accentColor)
            card.lineWidth = 2.5
            node.addChild(card)

            node.addChild(makeLabel(kind.emoji, size: 42, pos: CGPoint(x: cx, y: cy + 62)))
            node.addChild(makeLabel(kind.name, size: 20, pos: CGPoint(x: cx, y: cy + 14)))
            node.addChild(makeLabel(kind.species + (kind.isRobot ? " · ROBOT" : ""), size: 13, bold: false,
                                    color: NSColor(white: 1, alpha: 0.8), pos: CGPoint(x: cx, y: cy - 13)))
            let spd = pips(filled: Int((kind.speed / 85).rounded()))
            let pow = pips(filled: Int((Double(kind.power) / 8).rounded()))
            node.addChild(makeLabel("SPD \(spd)  POW \(pow)", size: 12.5, bold: false,
                                    pos: CGPoint(x: cx, y: cy - 40)))
            node.addChild(makeLabel(kind.specialName, size: 12.5, bold: false,
                                    color: nsColor(kind.accentColor), pos: CGPoint(x: cx, y: cy - 64)))
            node.addChild(makeLabel(kind.blurb, size: 11, bold: false,
                                    color: NSColor(white: 1, alpha: 0.75), pos: CGPoint(x: cx, y: cy - 88)))
            node.addChild(makeLabel("\(slot + 1)", size: 16,
                                    color: nsColor(kind.accentColor),
                                    pos: CGPoint(x: cx - 132, y: cy + 92)))
            clickTargets.append(ClickTarget(
                rect: CGRect(x: cx - 146, y: cy - 112, width: 292, height: 224), index: start + slot))
        }
        node.addChild(makeLabel("Page \(monsterPage + 1) of \(pages) — 24 fighters: 18 monsters & creatures, 6 robots",
                                size: 14, bold: false, color: NSColor(white: 1, alpha: 0.7),
                                pos: CGPoint(x: 0, y: -292)))
        node.addChild(makeLabel("☠ MALDO — the evil one in the striped shirt — hides in every city. Destroy him to DOUBLE your points ☠",
                                size: 13.5, bold: false,
                                color: NSColor(calibratedRed: 1, green: 0.45, blue: 0.5, alpha: 0.95),
                                pos: CGPoint(x: 0, y: -326)))
        node.addChild(makeLabel("👼 THE PLOT: every monster is one of MAMA's girls (the robots are her builds). Mama took out an insurance policy on planet Earth —",
                                size: 12.5, bold: false, color: NSColor(calibratedRed: 1, green: 0.85, blue: 0.5, alpha: 0.9),
                                pos: CGPoint(x: 0, y: -352)))
        node.addChild(makeLabel("wreck it, silence the Golden Snitch before he talks to the alien cops, and Mama collects. She'll chime in. She always does.",
                                size: 12.5, bold: false, color: NSColor(calibratedRed: 1, green: 0.85, blue: 0.5, alpha: 0.9),
                                pos: CGPoint(x: 0, y: -374)))
        refreshHUD()
    }

    func showCitySelect() {
        loadCityProgress()
        state = .citySelect
        let all = CityKind.allCases
        let pageSize = 8
        let pages = (all.count + pageSize - 1) / pageSize
        cityPage = min(max(0, cityPage), pages - 1)
        let start = cityPage * pageSize
        let pageItems = Array(all[start..<min(start + pageSize, all.count)])
        let node = beginOverlay(title: "CHOOSE THE VICTIM CITY", subtitle: "Step 2 of 2 — \(selectedMonster.name) is ready (keys 1–8 · ←/→ pages) · every city gets ONE HOUR a season — leave anytime, its clock freezes")
        node.addChild(makeLabel("🚨 SNITCH SEASON — DAY \(seasonDay) OF \(daysInSeason)  ·  🏦 BANKED \(Scoring.formatDollars(huntBank))  ·  CRUSH HIM TODAY: ×10 LOCK-IN, PENALTY −\(seasonPenalty)% AND GROWING",
                                size: 14.5, color: NSColor(calibratedRed: 1, green: 0.8, blue: 0.25, alpha: 1),
                                pos: CGPoint(x: 0, y: 262)))

        for (slot, city) in pageItems.enumerated() {
            let col = slot % 4
            let row = slot / 4
            let cx = CGFloat(col) * 308 - 462
            let cy: CGFloat = row == 0 ? 105 : -148
            let card = SKShapeNode(rectOf: CGSize(width: 292, height: 232), cornerRadius: 14)
            card.position = CGPoint(x: cx, y: cy)
            card.fillColor = nsColor(city.skyTop, alpha: 0.55)
            card.strokeColor = nsColor(city.buildingPalette.first ?? ColorRGB(1, 1, 1))
            card.lineWidth = 2.5
            node.addChild(card)

            node.addChild(makeLabel(city.icon, size: 40, pos: CGPoint(x: cx, y: cy + 68)))
            node.addChild(makeLabel(city.name, size: 19, pos: CGPoint(x: cx, y: cy + 24)))
            node.addChild(makeLabel(city.tagline, size: 11, bold: false,
                                    color: NSColor(white: 1, alpha: 0.85), pos: CGPoint(x: cx, y: cy - 4)))
            for (j, rgb) in city.buildingPalette.enumerated() {
                let swatch = SKShapeNode(rectOf: CGSize(width: 28, height: 18), cornerRadius: 3)
                swatch.position = CGPoint(x: cx - 48 + CGFloat(j) * 32, y: cy - 36)
                swatch.fillColor = nsColor(rgb)
                swatch.strokeColor = .clear
                node.addChild(swatch)
            }
            node.addChild(makeLabel("LANDMARK", size: 11, bold: false,
                                    color: NSColor(white: 1, alpha: 0.65), pos: CGPoint(x: cx, y: cy - 66)))
            node.addChild(makeLabel(city.landmarkName, size: 13.5,
                                    color: NSColor(calibratedRed: 1, green: 0.8, blue: 0.4, alpha: 1),
                                    pos: CGPoint(x: cx, y: cy - 86)))
            let prog = cityProgress[city.rawValue]
            let statusText: String
            let statusColor: NSColor
            if !city.isAvailable() {
                statusText = "🔒 DROPS \(dropText(city)) — A NEW CITY EVERY MONTH"
                statusColor = NSColor(calibratedRed: 0.85, green: 0.7, blue: 0.5, alpha: 1)
            } else if let prog, prog.spent {
                statusText = "⏱ HOUR SPENT — CLOSED THIS SEASON"
                statusColor = NSColor(calibratedRed: 1, green: 0.45, blue: 0.4, alpha: 1)
            } else if let prog, prog.elapsed > 1 {
                statusText = "⏱ \(clockText(Scoring.cityBudgetSeconds - prog.elapsed)) LEFT · FROZEN MID-RAMPAGE — Press \(slot + 1)"
                statusColor = NSColor(calibratedRed: 1, green: 0.8, blue: 0.35, alpha: 1)
            } else {
                statusText = "⏱ 60:00 ON THE CLOCK — Press \(slot + 1)"
                statusColor = NSColor(white: 1, alpha: 0.85)
            }
            node.addChild(makeLabel(statusText, size: 11.5, bold: false,
                                    color: statusColor, pos: CGPoint(x: cx, y: cy - 108)))
            clickTargets.append(ClickTarget(
                rect: CGRect(x: cx - 146, y: cy - 116, width: 292, height: 232), index: start + slot))
        }
        node.addChild(makeLabel("Page \(cityPage + 1) of \(pages) — \(CityKind.allCases.count) of the world's biggest cities",
                                size: 14, bold: false, color: NSColor(white: 1, alpha: 0.7),
                                pos: CGPoint(x: 0, y: -292)))
        // The sellout button — explicit, per the business model.
        let soldText = adsToday > 0 ? " — SOLD OUT ×\(adsToday) TODAY" : ""
        node.addChild(makeLabel("📺 WATCH ADS TO GET POINTS — YOU SELL OUT (A)\(soldText)",
                                size: 16, color: NSColor(calibratedRed: 1, green: 0.8, blue: 0.45, alpha: 1),
                                pos: CGPoint(x: 0, y: -334)))
        clickTargets.append(ClickTarget(
            rect: CGRect(x: -360, y: -356, width: 720, height: 44), index: 9999))
        refreshHUD()
    }

    func showLeaderboard() {
        showingLeaderboard = true
        let board = Leaderboard.load()
        let node = beginOverlay(title: "LEADERBOARD", subtitle: "Biggest rampages on this Mac — top 10 by total damage")
        if board.isEmpty {
            node.addChild(makeLabel("No rampages yet. Be the first legend.", size: 19, bold: false,
                                    pos: CGPoint(x: 0, y: 40)))
        } else {
            let df = DateFormatter()
            df.dateStyle = .short
            for (i, entry) in board.enumerated() {
                let line = "\(i + 1).  \(Scoring.formatDollars(entry.damage))  —  \(entry.monster) in \(entry.city) · \(entry.percent)% · \(entry.mode) · \(df.string(from: entry.date))"
                node.addChild(makeLabel(line, size: 16.5, bold: i < 3,
                                        color: i == 0 ? NSColor(calibratedRed: 1, green: 0.85, blue: 0.35, alpha: 1) : .white,
                                        pos: CGPoint(x: 0, y: 200 - CGFloat(i) * 40)))
            }
        }
        node.addChild(makeLabel("ESC or L — back", size: 16, bold: false,
                                color: NSColor(calibratedRed: 0.55, green: 0.95, blue: 0.55, alpha: 1),
                                pos: CGPoint(x: 0, y: -250)))
        refreshHUD()
    }
    // MARK: City building

    private func buildCity() {
        world.removeAllChildren()
        effects = SKNode()
        world.addChild(effects)
        buildings = []
        props = []

        let city = selectedCity
        seedRNG()

        // Sky: six blended bands from horizon color to zenith (atmosphere gradient)
        let bands = 6
        for i in 0..<bands {
            let t0 = Double(i) / Double(bands)
            let bandColor = lerpColor(city.skyBottom, city.skyTop, CGFloat(t0))
            let band = SKShapeNode(rectOf: CGSize(width: worldWidth, height: 660 / CGFloat(bands) + 2))
            band.position = CGPoint(x: worldWidth / 2, y: groundY + (660 / CGFloat(bands)) * (CGFloat(i) + 0.5))
            band.fillColor = bandColor
            band.strokeColor = .clear
            band.zPosition = -30
            world.addChild(band)
        }

        // Sun or moon (position varies by city for variety)
        let celestialX = 420 + CGFloat(abs(city.name.hashValue) % 2600)
        let sun = SKShapeNode(circleOfRadius: 34)
        sun.position = CGPoint(x: celestialX, y: 668)
        sun.fillColor = NSColor(calibratedRed: 1, green: 0.92, blue: 0.70, alpha: 0.9)
        sun.strokeColor = NSColor(calibratedRed: 1, green: 0.85, blue: 0.5, alpha: 0.5)
        sun.lineWidth = 10
        sun.zPosition = -29
        world.addChild(sun)

        // Stars / haze dots
        for _ in 0..<90 {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2.2))
            dot.position = CGPoint(x: CGFloat.random(in: 0...worldWidth), y: CGFloat.random(in: 520...780))
            dot.fillColor = NSColor(white: 1, alpha: CGFloat.random(in: 0.25...0.8))
            dot.strokeColor = .clear
            dot.zPosition = -29
            world.addChild(dot)
        }

        // Clouds: soft clusters drifting in the sky band
        for _ in 0..<7 {
            let cloud = SKNode()
            cloud.position = CGPoint(x: CGFloat.random(in: 100...(worldWidth - 100)),
                                     y: CGFloat.random(in: 555...735))
            cloud.zPosition = -28
            for _ in 0..<4 {
                let puff = SKShapeNode(circleOfRadius: CGFloat.random(in: 13...26))
                puff.position = CGPoint(x: CGFloat.random(in: -34...34), y: CGFloat.random(in: -7...7))
                puff.fillColor = NSColor(white: 1, alpha: CGFloat.random(in: 0.16...0.30))
                puff.strokeColor = .clear
                cloud.addChild(puff)
            }
            world.addChild(cloud)
        }
        // Birds — tiny distant silhouettes
        for _ in 0..<6 {
            let birdPath = CGMutablePath()
            birdPath.move(to: CGPoint(x: -8, y: 0))
            birdPath.addLine(to: CGPoint(x: -1, y: 4))
            birdPath.addLine(to: CGPoint(x: 1, y: 4))
            birdPath.addLine(to: CGPoint(x: 8, y: 0))
            let bird = SKShapeNode(path: birdPath)
            bird.position = CGPoint(x: CGFloat.random(in: 150...(worldWidth - 150)),
                                    y: CGFloat.random(in: 590...720))
            bird.strokeColor = NSColor(white: 0.05, alpha: 0.45)
            bird.lineWidth = 1.6
            bird.fillColor = .clear
            bird.zPosition = -28
            world.addChild(bird)
        }

        // Distant skyline: two parallax layers with lit windows (city depth)
        for layer in 0..<2 {
            var sx: CGFloat = layer == 0 ? 20 : 90
            let alpha: CGFloat = layer == 0 ? 0.13 : 0.22
            let baseH: CGFloat = layer == 0 ? 200 : 140
            while sx < worldWidth - 120 {
                let w = CGFloat.random(in: 90...170)
                let h = baseH + CGFloat.random(in: 0...170)
                let sil = SKShapeNode(rectOf: CGSize(width: w, height: h))
                sil.position = CGPoint(x: sx + w / 2, y: groundY + h / 2)
                sil.fillColor = NSColor(white: 0, alpha: alpha)
                sil.strokeColor = .clear
                sil.zPosition = layer == 0 ? -26 : -25
                world.addChild(sil)
                if layer == 1 {
                    for _ in 0..<6 {
                        let win = SKShapeNode(rectOf: CGSize(width: 5, height: 7))
                        win.position = CGPoint(x: sx + CGFloat.random(in: 10...(w - 10)),
                                               y: groundY + CGFloat.random(in: 16...(h - 12)))
                        win.fillColor = NSColor(calibratedRed: 1, green: 0.87, blue: 0.55, alpha: CGFloat.random(in: 0.3...0.75))
                        win.strokeColor = .clear
                        win.zPosition = -24
                        world.addChild(win)
                    }
                }
                sx += w + CGFloat.random(in: 25...70)
            }
        }

        // Atmospheric haze just above the rooftops
        let haze = SKShapeNode(rectOf: CGSize(width: worldWidth, height: 60))
        haze.position = CGPoint(x: worldWidth / 2, y: groundY + 42)
        haze.fillColor = NSColor(white: 1, alpha: 0.05)
        haze.strokeColor = .clear
        haze.zPosition = -18
        world.addChild(haze)
        // Backdrop sign (Vegas welcome sign / HOLLYWOOD)
        if let sign = city.backdropSign {
            let signLabel = makeLabel(sign, size: city == .losAngeles ? 54 : 25,
                                      color: .white, pos: CGPoint(x: city == .losAngeles ? 3050 : 330, y: city == .losAngeles ? 505 : 300))
            signLabel.zPosition = -20
            if city == .losAngeles {
                let hill = SKShapeNode(rectOf: CGSize(width: 900, height: 130), cornerRadius: 60)
                hill.position = CGPoint(x: 3050, y: 440)
                hill.fillColor = NSColor(calibratedRed: 0.30, green: 0.38, blue: 0.22, alpha: 1)
                hill.strokeColor = .clear
                hill.zPosition = -21
                world.addChild(hill)
            }
            world.addChild(signLabel)
        }

        // Ground / street
        let ground = SKShapeNode(rectOf: CGSize(width: worldWidth, height: groundY))
        ground.position = CGPoint(x: worldWidth / 2, y: groundY / 2)
        ground.fillColor = nsColor(city.groundColor)
        ground.strokeColor = .clear
        ground.zPosition = -15
        world.addChild(ground)
        let curb = SKShapeNode(rectOf: CGSize(width: worldWidth, height: 5))
        curb.position = CGPoint(x: worldWidth / 2, y: groundY)
        curb.fillColor = NSColor(white: 1, alpha: 0.5)
        curb.strokeColor = .clear
        curb.zPosition = -14
        world.addChild(curb)

        // Sidewalk: lighter paved band along the top of the street, with
        // expansion joints — the strip the crowd and Maldo actually walk on
        let sidewalk = SKShapeNode(rectOf: CGSize(width: worldWidth, height: 30))
        sidewalk.position = CGPoint(x: worldWidth / 2, y: groundY - 15)
        sidewalk.fillColor = NSColor(white: 1, alpha: 0.10)
        sidewalk.strokeColor = .clear
        sidewalk.zPosition = -14
        world.addChild(sidewalk)
        var jointX: CGFloat = 60
        while jointX < worldWidth - 40 {
            let joint = SKShapeNode(rectOf: CGSize(width: 2.5, height: 30))
            joint.position = CGPoint(x: jointX, y: groundY - 15)
            joint.fillColor = NSColor(white: 0, alpha: 0.18)
            joint.strokeColor = .clear
            joint.zPosition = -13
            world.addChild(joint)
            jointX += 120
        }
        // Manholes in the roadway
        var holeX: CGFloat = 340
        while holeX < worldWidth - 200 {
            let hole = SKShapeNode(path: CGPath(ellipseIn: CGRect(x: -26, y: -8, width: 52, height: 16), transform: nil))
            hole.position = CGPoint(x: holeX, y: groundY - 82)
            hole.fillColor = NSColor(white: 0, alpha: 0.30)
            hole.strokeColor = NSColor(white: 1, alpha: 0.12)
            hole.lineWidth = 1.5
            hole.zPosition = -13
            world.addChild(hole)
            holeX += 520
        }

        // Street furniture & markings: road dashes, crosswalks at each
        // cross street, and proper street signage — main street board
        // first, then a sign at every cross street in order.
        var dashX: CGFloat = 30
        while dashX < worldWidth - 40 {
            let dash = SKShapeNode(rectOf: CGSize(width: 44, height: 5), cornerRadius: 2)
            dash.position = CGPoint(x: dashX, y: groundY - 52)
            dash.fillColor = NSColor(calibratedRed: 1, green: 0.87, blue: 0.45, alpha: 0.5)
            dash.strokeColor = .clear
            dash.zPosition = -13
            world.addChild(dash)
            dashX += 110
        }
        func streetSign(x: CGFloat, text: String, big: Bool) {
            let pole = SKShapeNode(rectOf: CGSize(width: 5, height: big ? 118 : 96))
            pole.position = CGPoint(x: x, y: groundY + (big ? 59 : 48))
            pole.fillColor = NSColor(white: 0.35, alpha: 1)
            pole.strokeColor = .clear
            pole.zPosition = -6
            world.addChild(pole)
            let board = SKShapeNode(rectOf: CGSize(width: big ? 300 : 168, height: big ? 34 : 26), cornerRadius: 4)
            board.position = CGPoint(x: x, y: groundY + (big ? 128 : 104))
            board.fillColor = NSColor(calibratedRed: 0.10, green: 0.35, blue: 0.18, alpha: 1)
            board.strokeColor = NSColor(white: 1, alpha: 0.6)
            board.lineWidth = 1.5
            board.zPosition = -5
            world.addChild(board)
            let label = makeLabel(text, size: big ? 15 : 12.5, pos: CGPoint(x: x, y: groundY + (big ? 128 : 104)))
            label.zPosition = -4
            world.addChild(label)
            // Crosswalk stripes below each cross-street sign
            if !big {
                for s in 0..<5 {
                    let stripe = SKShapeNode(rectOf: CGSize(width: 11, height: 74))
                    stripe.position = CGPoint(x: x - 52 + CGFloat(s) * 26, y: groundY - 68)
                    stripe.fillColor = NSColor(white: 1, alpha: 0.35)
                    stripe.strokeColor = .clear
                    stripe.zPosition = -13
                    world.addChild(stripe)
                }
            }
        }
        streetSign(x: 300, text: city.streetName, big: true)
        for (i, cross) in city.crossStreets.enumerated() {
            streetSign(x: 780 + CGFloat(i) * 760, text: cross, big: false)
        }

        // Traffic lights at every cross street — pole, arm, three lamps
        for i in 0..<city.crossStreets.count {
            let tx = 780 + CGFloat(i) * 760 + 185
            let pole = SKShapeNode(rectOf: CGSize(width: 6, height: 152))
            pole.position = CGPoint(x: tx, y: groundY + 76)
            pole.fillColor = NSColor(white: 0.22, alpha: 1)
            pole.strokeColor = .clear
            pole.zPosition = -6
            world.addChild(pole)
            let armBar = SKShapeNode(rectOf: CGSize(width: 64, height: 6))
            armBar.position = CGPoint(x: tx - 29, y: groundY + 150)
            armBar.fillColor = NSColor(white: 0.22, alpha: 1)
            armBar.strokeColor = .clear
            armBar.zPosition = -6
            world.addChild(armBar)
            let headBox = SKShapeNode(rectOf: CGSize(width: 17, height: 44), cornerRadius: 3)
            headBox.position = CGPoint(x: tx - 56, y: groundY + 126)
            headBox.fillColor = NSColor(white: 0.10, alpha: 1)
            headBox.strokeColor = .clear
            headBox.zPosition = -5
            world.addChild(headBox)
            let lampColors: [NSColor] = [
                NSColor(calibratedRed: 1, green: 0.25, blue: 0.2, alpha: 0.35),
                NSColor(calibratedRed: 1, green: 0.8, blue: 0.2, alpha: 0.35),
                NSColor(calibratedRed: 0.3, green: 0.95, blue: 0.4, alpha: 1)
            ]
            for (li, lc) in lampColors.enumerated() {
                let lamp = SKShapeNode(circleOfRadius: 5)
                lamp.position = CGPoint(x: tx - 56, y: groundY + 140 - CGFloat(li) * 13.5)
                lamp.fillColor = lc
                lamp.strokeColor = .clear
                lamp.zPosition = -4
                world.addChild(lamp)
            }
        }

        // Street lamps the whole length of the street
        var lampX: CGFloat = 240
        while lampX < worldWidth - 120 {
            let pole = SKShapeNode(rectOf: CGSize(width: 5, height: 118))
            pole.position = CGPoint(x: lampX, y: groundY + 59)
            pole.fillColor = NSColor(white: 0.28, alpha: 1)
            pole.strokeColor = .clear
            pole.zPosition = -6
            world.addChild(pole)
            let halo = SKShapeNode(circleOfRadius: 15)
            halo.position = CGPoint(x: lampX + 10, y: groundY + 120)
            halo.fillColor = NSColor(calibratedRed: 1, green: 0.92, blue: 0.70, alpha: 0.22)
            halo.strokeColor = .clear
            halo.zPosition = -6
            world.addChild(halo)
            let bulb = SKShapeNode(circleOfRadius: 5.5)
            bulb.position = CGPoint(x: lampX + 10, y: groundY + 120)
            bulb.fillColor = NSColor(calibratedRed: 1, green: 0.95, blue: 0.78, alpha: 1)
            bulb.strokeColor = .clear
            bulb.zPosition = -5
            world.addChild(bulb)
            lampX += 430
        }

        // Street trees in planters, all the way down the block
        var treeX: CGFloat = 470
        while treeX < worldWidth - 200 {
            let trunk = SKShapeNode(rectOf: CGSize(width: 7, height: 36))
            trunk.position = CGPoint(x: treeX, y: groundY + 16)
            trunk.fillColor = NSColor(calibratedRed: 0.36, green: 0.25, blue: 0.16, alpha: 1)
            trunk.strokeColor = .clear
            trunk.zPosition = -8
            world.addChild(trunk)
            for (dx, dy, r) in [(-13, 52, 19), (13, 55, 21), (0, 70, 23)] as [(CGFloat, CGFloat, CGFloat)] {
                let canopy = SKShapeNode(circleOfRadius: r)
                canopy.position = CGPoint(x: treeX + dx, y: groundY + dy)
                canopy.fillColor = NSColor(calibratedRed: 0.22, green: 0.48, blue: 0.22, alpha: 0.9)
                canopy.strokeColor = .clear
                canopy.zPosition = -8
                world.addChild(canopy)
            }
            treeX += 610
        }

        // Transit entrance — the city's own system, correctly badged —
        // or a bus shelter where there's no metro to speak of
        let transitX: CGFloat = 2060
        func transitPosts(color: NSColor) {
            for dx in [-52, 52] as [CGFloat] {
                let post = SKShapeNode(rectOf: CGSize(width: 6, height: 96))
                post.position = CGPoint(x: transitX + dx, y: groundY + 48)
                post.fillColor = color
                post.strokeColor = .clear
                post.zPosition = -5
                world.addChild(post)
            }
        }
        func transitSign(text: String, fill: NSColor, w: CGFloat) {
            let sign = SKShapeNode(rectOf: CGSize(width: w, height: 30), cornerRadius: 6)
            sign.position = CGPoint(x: transitX, y: groundY + 100)
            sign.fillColor = fill
            sign.strokeColor = NSColor(white: 1, alpha: 0.5)
            sign.lineWidth = 1.5
            sign.zPosition = -4
            world.addChild(sign)
            let label = makeLabel(text, size: 15, pos: CGPoint(x: transitX, y: groundY + 100))
            label.zPosition = -3
            world.addChild(label)
            // Stairwell down
            let stairs = SKShapeNode(rectOf: CGSize(width: 84, height: 12))
            stairs.position = CGPoint(x: transitX, y: groundY - 8)
            stairs.fillColor = NSColor(white: 0, alpha: 0.45)
            stairs.strokeColor = .clear
            stairs.zPosition = -5
            world.addChild(stairs)
        }
        switch city {
        case .newYork:
            transitPosts(color: NSColor(calibratedRed: 0.12, green: 0.45, blue: 0.22, alpha: 1))
            transitSign(text: "SUBWAY", fill: NSColor(calibratedRed: 0.12, green: 0.45, blue: 0.22, alpha: 1), w: 118)
        case .paris:
            transitPosts(color: NSColor(calibratedRed: 0.10, green: 0.32, blue: 0.28, alpha: 1))
            transitSign(text: "MÉTRO", fill: NSColor(calibratedRed: 0.75, green: 0.15, blue: 0.15, alpha: 1), w: 96)
        case .tokyo:
            transitPosts(color: NSColor(calibratedRed: 0.15, green: 0.35, blue: 0.55, alpha: 1))
            transitSign(text: "METRO", fill: NSColor(calibratedRed: 0.10, green: 0.55, blue: 0.60, alpha: 1), w: 100)
        case .london:
            transitPosts(color: NSColor(calibratedRed: 0.30, green: 0.30, blue: 0.32, alpha: 1))
            let roundel = SKShapeNode(circleOfRadius: 21)
            roundel.position = CGPoint(x: transitX, y: groundY + 104)
            roundel.fillColor = .clear
            roundel.strokeColor = NSColor(calibratedRed: 0.85, green: 0.15, blue: 0.15, alpha: 1)
            roundel.lineWidth = 7
            roundel.zPosition = -4
            world.addChild(roundel)
            let bar = SKShapeNode(rectOf: CGSize(width: 104, height: 19))
            bar.position = CGPoint(x: transitX, y: groundY + 104)
            bar.fillColor = NSColor(calibratedRed: 0.10, green: 0.20, blue: 0.55, alpha: 1)
            bar.strokeColor = .clear
            bar.zPosition = -3
            world.addChild(bar)
            let label = makeLabel("UNDERGROUND", size: 11.5, pos: CGPoint(x: transitX, y: groundY + 104))
            label.zPosition = -2
            world.addChild(label)
        default:
            // Bus shelter: posts, roof, bench, sign
            transitPosts(color: NSColor(white: 0.30, alpha: 1))
            let roof = SKShapeNode(rectOf: CGSize(width: 128, height: 7), cornerRadius: 3)
            roof.position = CGPoint(x: transitX, y: groundY + 98)
            roof.fillColor = NSColor(white: 0.25, alpha: 1)
            roof.strokeColor = .clear
            roof.zPosition = -4
            world.addChild(roof)
            let bench = SKShapeNode(rectOf: CGSize(width: 96, height: 6), cornerRadius: 2)
            bench.position = CGPoint(x: transitX, y: groundY + 26)
            bench.fillColor = NSColor(calibratedRed: 0.45, green: 0.32, blue: 0.20, alpha: 1)
            bench.strokeColor = .clear
            bench.zPosition = -4
            world.addChild(bench)
            let signLabel = makeLabel("🚌 BUS STOP", size: 14, pos: CGPoint(x: transitX, y: groundY + 116))
            signLabel.zPosition = -3
            world.addChild(signLabel)
        }

        // Buildings row
        var x: CGFloat = 170
        var index = 0
        // First pass: lay out widths to know where the middle (landmark) lands.
        var layout: [(width: CGFloat, height: CGFloat)] = []
        var cursor: CGFloat = 170
        while cursor < worldWidth - 320 {
            let w = randIn(215...295)
            // True height profile for this city's architecture
            let h = randIn(CGFloat(city.minBuildingH)...CGFloat(city.maxBuildingH))
            layout.append((w, h))
            cursor += w + randIn(95...150)
        }
        let landmarkIndex = layout.count / 2

        cursor = 170
        for (i, item) in layout.enumerated() {
            let isLandmark = i == landmarkIndex
            var w = item.width
            var h = item.height
            if isLandmark {
                switch selectedCity.landmarkStyle {
                case .tower: h = 560; w = 200
                case .wheel: h = 470
                case .needle: h = 580; w = 210
                case .tiers: h = 660; w = 250
                case .clock: h = 520; w = 230
                case .statue: h = 400; w = 260
                case .shells: h = 230; w = 430
                case .bridge: h = 330; w = 470
                case .sails: h = 430; w = 360
                case .spire: h = 600
                case .pyramid: h = 300; w = 460
                case .dome: h = 430; w = 300
                }
            }
            let centerX = cursor + w / 2
            let building = makeBuilding(index: index, centerX: centerX, width: w, height: h, isLandmark: isLandmark)
            buildings.append(building)
            world.addChild(building.group)
            index += 1

            // A prop in the gap after each building: vehicles native to
            // the city, street furniture, or a drawn fire hydrant
            let gapCenter = cursor + w + 55
            if gapCenter < worldWidth - 120 {
                if index % 4 == 3 {
                    // Fire hydrant — drawn, red, unmistakable, smashable
                    let prop = Prop(emoji: "", x: gapCenter)
                    prop.node.position = CGPoint(x: gapCenter, y: groundY + 22)
                    let hydrantRed = NSColor(calibratedRed: 0.85, green: 0.15, blue: 0.15, alpha: 1)
                    let hydrantBody = SKShapeNode(rectOf: CGSize(width: 13, height: 21), cornerRadius: 4)
                    hydrantBody.position = CGPoint(x: 0, y: -8)
                    hydrantBody.fillColor = hydrantRed
                    hydrantBody.strokeColor = .clear
                    hydrantBody.zPosition = 5
                    prop.node.addChild(hydrantBody)
                    let hydrantDome = SKShapeNode(circleOfRadius: 6.5)
                    hydrantDome.position = CGPoint(x: 0, y: 4)
                    hydrantDome.fillColor = hydrantRed
                    hydrantDome.strokeColor = .clear
                    hydrantDome.zPosition = 5
                    prop.node.addChild(hydrantDome)
                    for dx in [-8.5, 8.5] as [CGFloat] {
                        let cap = SKShapeNode(circleOfRadius: 3.4)
                        cap.position = CGPoint(x: dx, y: -6)
                        cap.fillColor = NSColor(white: 0.75, alpha: 1)
                        cap.strokeColor = .clear
                        cap.zPosition = 5
                        prop.node.addChild(cap)
                    }
                    world.addChild(prop.node)
                    props.append(prop)
                } else {
                    let pool = index % 5 == 2 ? ["📮", "🚏", "🗞️"] : city.propEmojis
                    let prop = Prop(emoji: pool.isEmpty ? "🚗" : pool[Int(nextRandom() * Double(pool.count)) % pool.count], x: gapCenter)
                    prop.node.position = CGPoint(x: gapCenter, y: groundY + 22)
                    let label = makeLabel(prop.emoji, size: 34, pos: .zero)
                    label.zPosition = 5
                    prop.node.addChild(label)
                    world.addChild(prop.node)
                    props.append(prop)
                }
            }
            cursor += w + randIn(95...150)
        }

        totalHP = buildings.reduce(0) { $0 + $1.maxHP } + props.count * 20
        claimRate = Scoring.claimRate(cityValue: selectedCity.destructionValue, totalHP: totalHP)
        destroyedHP = 0

        // Restore this city's frozen state from earlier this season —
        // the seeded layout is identical, so the rubble lines back up.
        buildingsToppled = 0
        propsSmashed = 0
        let saved = cityProgress[selectedCity.rawValue] ?? CityProgress()
        for (key, hpLeft) in saved.buildingHP {
            guard let idx = Int(key), buildings.indices.contains(idx) else { continue }
            let b = buildings[idx]
            destroyedHP += b.maxHP - hpLeft
            b.hp = hpLeft
            let frac = b.hpFraction
            b.body.fillColor = b.baseColor.blended(withFraction: CGFloat(1 - frac) * 0.55, of: .black) ?? b.baseColor
            updateCracks(b)
            if hpLeft <= 0 {
                b.destroyed = true
                buildingsToppled += 1
                b.group.yScale = 0.10
                b.group.childNode(withName: "hpBG")?.alpha = 0
                b.group.childNode(withName: "hpFill")?.alpha = 0
            } else {
                // Frozen rubble includes the HP bar: a damaged building
                // shows its bar (scaled + colored exactly as
                // damageBuilding left it) from the moment the player
                // returns, not only after the next hit lands.
                if let hpBG = b.group.childNode(withName: "hpBG"),
                   let hpFill = b.group.childNode(withName: "hpFill") as? SKShapeNode {
                    hpBG.alpha = 1
                    hpFill.alpha = 1
                    hpFill.xScale = CGFloat(max(0, frac))
                    hpFill.fillColor = frac > 0.4
                        ? NSColor(calibratedRed: 0.5, green: 0.95, blue: 0.45, alpha: 1)
                        : NSColor(calibratedRed: 1, green: 0.4, blue: 0.35, alpha: 1)
                }
            }
        }
        for idx in saved.deadProps where props.indices.contains(idx) {
            props[idx].destroyed = true
            props[idx].node.removeFromParent()
            destroyedHP += 20
            propsSmashed += 1
        }
    }

    private func makeBuilding(index: Int, centerX: CGFloat, width: CGFloat, height: CGFloat, isLandmark: Bool) -> Building {
        let city = selectedCity
        let palette = city.buildingPalette
        let baseRGB = isLandmark ? ColorRGB(0.92, 0.78, 0.45) : palette[index % palette.count]
        let baseColor = nsColor(baseRGB)

        let body: SKShapeNode
        if isLandmark {
            switch city.landmarkStyle {
            case .tower:
                // Tapered Eiffel-style tower — path drawn from its base.
                let path = CGMutablePath()
                let hw = width / 2
                path.move(to: CGPoint(x: -hw, y: 0))
                path.addLine(to: CGPoint(x: -width * 0.16, y: height * 0.55))
                path.addLine(to: CGPoint(x: -width * 0.07, y: height))
                path.addLine(to: CGPoint(x: width * 0.07, y: height))
                path.addLine(to: CGPoint(x: width * 0.16, y: height * 0.55))
                path.addLine(to: CGPoint(x: hw, y: 0))
                path.addLine(to: CGPoint(x: width * 0.22, y: 0))
                path.addLine(to: CGPoint(x: 0, y: height * 0.28))
                path.addLine(to: CGPoint(x: -width * 0.22, y: 0))
                path.closeSubpath()
                body = SKShapeNode(path: path)
                body.position = .zero
            case .wheel:
                body = SKShapeNode(circleOfRadius: height / 2)
                body.position = CGPoint(x: 0, y: height / 2 + 40)
            case .needle:
                // Slim tower with a sphere bulge near the top (Skytree / Pearl / CN / Fernsehturm family)
                let path = CGMutablePath()
                let bw = width * 0.62
                path.move(to: CGPoint(x: -bw / 2, y: 0))
                path.addLine(to: CGPoint(x: -13, y: height * 0.52))
                path.addLine(to: CGPoint(x: -30, y: height * 0.64))
                path.addLine(to: CGPoint(x: -13, y: height * 0.76))
                path.addLine(to: CGPoint(x: -4, y: height))
                path.addLine(to: CGPoint(x: 4, y: height))
                path.addLine(to: CGPoint(x: 13, y: height * 0.76))
                path.addLine(to: CGPoint(x: 30, y: height * 0.64))
                path.addLine(to: CGPoint(x: 13, y: height * 0.52))
                path.addLine(to: CGPoint(x: bw / 2, y: 0))
                path.closeSubpath()
                body = SKShapeNode(path: path)
                body.position = .zero
            case .tiers:
                // Stepped supertall (Burj family) — stacked tiers narrowing to a point
                let path = CGMutablePath()
                let hw = width / 2
                path.move(to: CGPoint(x: -hw, y: 0))
                path.addLine(to: CGPoint(x: -hw, y: height * 0.34))
                path.addLine(to: CGPoint(x: -hw * 0.74, y: height * 0.34))
                path.addLine(to: CGPoint(x: -hw * 0.74, y: height * 0.62))
                path.addLine(to: CGPoint(x: -hw * 0.46, y: height * 0.62))
                path.addLine(to: CGPoint(x: -hw * 0.46, y: height * 0.85))
                path.addLine(to: CGPoint(x: -hw * 0.16, y: height * 0.85))
                path.addLine(to: CGPoint(x: -hw * 0.16, y: height))
                path.addLine(to: CGPoint(x: hw * 0.16, y: height))
                path.addLine(to: CGPoint(x: hw * 0.16, y: height * 0.85))
                path.addLine(to: CGPoint(x: hw * 0.46, y: height * 0.85))
                path.addLine(to: CGPoint(x: hw * 0.46, y: height * 0.62))
                path.addLine(to: CGPoint(x: hw * 0.74, y: height * 0.62))
                path.addLine(to: CGPoint(x: hw * 0.74, y: height * 0.34))
                path.addLine(to: CGPoint(x: hw, y: height * 0.34))
                path.addLine(to: CGPoint(x: hw, y: 0))
                path.closeSubpath()
                body = SKShapeNode(path: path)
                body.position = .zero
            case .statue:
                // Figure with outstretched arms on a pedestal (Christ the Redeemer family)
                let path = CGMutablePath()
                let w = width
                let h = height
                path.move(to: CGPoint(x: -w * 0.35, y: 0))
                path.addLine(to: CGPoint(x: w * 0.35, y: 0))
                path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.25))
                path.addLine(to: CGPoint(x: w * 0.10, y: h * 0.25))
                path.addLine(to: CGPoint(x: w * 0.10, y: h * 0.60))
                path.addLine(to: CGPoint(x: w * 0.44, y: h * 0.66))
                path.addLine(to: CGPoint(x: w * 0.44, y: h * 0.75))
                path.addLine(to: CGPoint(x: w * 0.10, y: h * 0.77))
                path.addLine(to: CGPoint(x: w * 0.08, y: h))
                path.addLine(to: CGPoint(x: -w * 0.08, y: h))
                path.addLine(to: CGPoint(x: -w * 0.10, y: h * 0.77))
                path.addLine(to: CGPoint(x: -w * 0.44, y: h * 0.75))
                path.addLine(to: CGPoint(x: -w * 0.44, y: h * 0.66))
                path.addLine(to: CGPoint(x: -w * 0.10, y: h * 0.60))
                path.addLine(to: CGPoint(x: -w * 0.10, y: h * 0.25))
                path.addLine(to: CGPoint(x: -w * 0.35, y: h * 0.25))
                path.closeSubpath()
                body = SKShapeNode(path: path)
                body.position = .zero
            case .bridge:
                // Suspension bridge silhouette: deck + two towers (Golden Gate family)
                let path = CGMutablePath()
                let w = width
                let h = height
                path.move(to: CGPoint(x: -w / 2, y: h * 0.34))
                path.addLine(to: CGPoint(x: -w * 0.32, y: h * 0.34))
                path.addLine(to: CGPoint(x: -w * 0.32, y: h))
                path.addLine(to: CGPoint(x: -w * 0.22, y: h))
                path.addLine(to: CGPoint(x: -w * 0.22, y: h * 0.34))
                path.addLine(to: CGPoint(x: w * 0.22, y: h * 0.34))
                path.addLine(to: CGPoint(x: w * 0.22, y: h))
                path.addLine(to: CGPoint(x: w * 0.32, y: h))
                path.addLine(to: CGPoint(x: w * 0.32, y: h * 0.34))
                path.addLine(to: CGPoint(x: w / 2, y: h * 0.34))
                path.addLine(to: CGPoint(x: w / 2, y: h * 0.18))
                path.addLine(to: CGPoint(x: -w / 2, y: h * 0.18))
                path.closeSubpath()
                body = SKShapeNode(path: path)
                body.position = .zero
            case .pyramid:
                let ppath = CGMutablePath()
                ppath.move(to: CGPoint(x: -width / 2, y: 0))
                ppath.addLine(to: CGPoint(x: width / 2, y: 0))
                ppath.addLine(to: CGPoint(x: 0, y: height))
                ppath.closeSubpath()
                body = SKShapeNode(path: ppath)
                body.position = .zero
            case .shells, .sails, .clock, .spire, .dome:
                body = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 4)
                body.position = CGPoint(x: 0, y: height / 2)
            }
        } else {
            body = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 4)
            body.position = CGPoint(x: 0, y: height / 2)
        }
        body.fillColor = isLandmark && city.landmarkStyle == .bridge
            ? NSColor(calibratedRed: 0.85, green: 0.32, blue: 0.16, alpha: 1) : baseColor
        body.strokeColor = NSColor(white: 0, alpha: 0.35)
        body.lineWidth = 2

        let maxHP = Int((120 + Double(height) * 0.9) * (isLandmark ? 2.2 : 1.0))
        let name = isLandmark ? city.landmarkName : city.buildingNames[index % city.buildingNames.count]
        let building = Building(name: name, isLandmark: isLandmark, maxHP: maxHP,
                                centerX: centerX, width: width, height: height,
                                body: body, baseColor: baseColor)

        let group = building.group
        group.position = CGPoint(x: centerX, y: groundY)
        group.zPosition = 0

        group.addChild(body)

        // Crack decals (damage juice): stage 1 shows under 66% HP,
        // stage 2 under 33% — see updateCracks.
        let crack1 = makeCrack(seed: index * 2 + 1, width: width, height: height)
        crack1.name = "crack1"
        crack1.alpha = 0
        group.addChild(crack1)
        let crack2 = makeCrack(seed: index * 2 + 101, width: width, height: height)
        crack2.name = "crack2"
        crack2.alpha = 0
        group.addChild(crack2)

        // Landmark dressing that the generic rect/path doesn't cover
        if isLandmark {
            switch city.landmarkStyle {
            case .wheel:
                for dx in [-height / 4, height / 4] as [CGFloat] {
                    let leg = SKShapeNode(rectOf: CGSize(width: 14, height: 60))
                    leg.position = CGPoint(x: dx, y: 20)
                    leg.fillColor = baseColor
                    leg.strokeColor = .clear
                    group.addChild(leg)
                }
                for angle in stride(from: 0.0, to: Double.pi * 2, by: Double.pi / 4) {
                    let spoke = SKShapeNode(rectOf: CGSize(width: 3, height: height - 30))
                    spoke.position = body.position
                    spoke.zRotation = CGFloat(angle)
                    spoke.fillColor = NSColor(white: 0, alpha: 0.3)
                    spoke.strokeColor = .clear
                    group.addChild(spoke)
                }
            case .clock:
                let face = SKShapeNode(circleOfRadius: 27)
                face.position = CGPoint(x: 0, y: height - 58)
                face.fillColor = .white
                face.strokeColor = NSColor(white: 0, alpha: 0.4)
                face.lineWidth = 3
                face.zPosition = 2
                group.addChild(face)
                let handV = SKShapeNode(rectOf: CGSize(width: 4, height: 34))
                handV.position = face.position
                handV.fillColor = .black
                handV.strokeColor = .clear
                handV.zPosition = 3
                group.addChild(handV)
                let handH = SKShapeNode(rectOf: CGSize(width: 26, height: 4))
                handH.position = face.position
                handH.fillColor = .black
                handH.strokeColor = .clear
                handH.zPosition = 3
                group.addChild(handH)
            case .spire:
                let antenna = SKShapeNode(rectOf: CGSize(width: 6, height: 66))
                antenna.position = CGPoint(x: 0, y: height + 30)
                antenna.fillColor = baseColor
                antenna.strokeColor = .clear
                group.addChild(antenna)
            case .dome:
                // Basilica dome crowning the rect body, finial on top
                let domePath = CGMutablePath()
                domePath.move(to: CGPoint(x: -width / 2, y: 0))
                domePath.addArc(center: .zero, radius: width / 2, startAngle: .pi, endAngle: 0, clockwise: false)
                domePath.closeSubpath()
                let domeCap = SKShapeNode(path: domePath)
                domeCap.position = CGPoint(x: 0, y: height)
                domeCap.fillColor = baseColor
                domeCap.strokeColor = NSColor(white: 0, alpha: 0.25)
                group.addChild(domeCap)
                let finial = SKShapeNode(circleOfRadius: 9)
                finial.position = CGPoint(x: 0, y: height + width / 2 + 4)
                finial.fillColor = baseColor
                finial.strokeColor = .clear
                group.addChild(finial)
            case .shells:
                // Opera-house sails over a podium (the podium is `body`, shrunk below)
                body.setScale(1)
                body.position = CGPoint(x: 0, y: height * 0.10)
                body.yScale = 0.20
                for (dx, r) in [(-width * 0.30, height * 0.55), (0, height * 0.92), (width * 0.30, height * 0.55)] as [(CGFloat, CGFloat)] {
                    let shellPath = CGMutablePath()
                    shellPath.move(to: CGPoint(x: -r, y: 0))
                    shellPath.addArc(center: .zero, radius: r, startAngle: .pi, endAngle: 0, clockwise: false)
                    shellPath.closeSubpath()
                    let shell = SKShapeNode(path: shellPath)
                    shell.position = CGPoint(x: dx, y: height * 0.18)
                    shell.fillColor = NSColor(calibratedRed: 0.96, green: 0.94, blue: 0.90, alpha: 1)
                    shell.strokeColor = NSColor(white: 0, alpha: 0.25)
                    group.addChild(shell)
                }
            case .sails:
                // Marina Bay Sands: three towers under the sky-boat
                body.position = CGPoint(x: 0, y: height * 0.93)
                body.yScale = 0.14
                for dx in [-width * 0.33, 0, width * 0.33] as [CGFloat] {
                    let tower = SKShapeNode(rectOf: CGSize(width: width * 0.17, height: height * 0.86))
                    tower.position = CGPoint(x: dx, y: height * 0.43)
                    tower.fillColor = baseColor
                    tower.strokeColor = NSColor(white: 0, alpha: 0.3)
                    group.addChild(tower)
                }
            default:
                break
            }
        }

        // Windows (only rect-bodied buildings and spire/clock landmarks have offices)
        if !isLandmark || city.landmarkStyle == .spire || city.landmarkStyle == .clock {
            let cols = max(3, Int(width / 42))
            let rows = max(4, Int(height / 48))
            for c in 0..<cols {
                for r in 0..<rows {
                    if (c * 7 + r * 3 + index) % 5 == 0 { continue } // some windows dark
                    let win = SKShapeNode(rectOf: CGSize(width: 15, height: 20))
                    win.position = CGPoint(
                        x: -width / 2 + (CGFloat(c) + 0.5) * (width / CGFloat(cols)),
                        y: 26 + (CGFloat(r) + 0.5) * ((height - 40) / CGFloat(rows)))
                    win.fillColor = NSColor(calibratedRed: 1, green: 0.88, blue: 0.55, alpha: CGFloat.random(in: 0.5...0.95))
                    win.strokeColor = .clear
                    win.zPosition = 1
                    group.addChild(win)
                }
            }
        }

        // Street-level storefront: every building fronts a real (parody)
        // business, so the whole street's commerce is on display — and
        // on the destruction ledger.
        if !isLandmark {
            let shop = city.shops[index % city.shops.count]
            let band = SKShapeNode(rectOf: CGSize(width: width - 8, height: 40), cornerRadius: 3)
            band.position = CGPoint(x: 0, y: 20)
            band.fillColor = NSColor(white: 0, alpha: 0.28)
            band.strokeColor = .clear
            band.zPosition = 2
            group.addChild(band)
            let awning = SKShapeNode(rectOf: CGSize(width: width - 8, height: 9), cornerRadius: 2)
            awning.position = CGPoint(x: 0, y: 44)
            awning.fillColor = nsColor(city.buildingPalette[(index + 1) % city.buildingPalette.count])
            awning.strokeColor = .clear
            awning.zPosition = 3
            group.addChild(awning)
            for dx in [-width / 4, width / 4] as [CGFloat] {
                let display = SKShapeNode(rectOf: CGSize(width: 36, height: 20), cornerRadius: 2)
                display.position = CGPoint(x: dx, y: 17)
                display.fillColor = NSColor(calibratedRed: 0.85, green: 0.93, blue: 0.98, alpha: 0.9)
                display.strokeColor = .clear
                display.zPosition = 3
                group.addChild(display)
            }
            let door = SKShapeNode(rectOf: CGSize(width: 15, height: 27))
            door.position = CGPoint(x: 0, y: 13)
            door.fillColor = NSColor(white: 0.10, alpha: 1)
            door.strokeColor = .clear
            door.zPosition = 3
            group.addChild(door)
            let shopLabel = makeLabel(shop, size: 14.5,
                                      color: NSColor(calibratedRed: 1, green: 0.88, blue: 0.55, alpha: 1),
                                      pos: CGPoint(x: 0, y: 30))
            shopLabel.zPosition = 4
            group.addChild(shopLabel)

            // Roof character by city: Paris mansard + chimneys, Vegas neon
            // crown, Tokyo blade sign, everyone else gets rooftops clutter.
            if city == .paris {
                let mansard = SKShapeNode(rectOf: CGSize(width: width, height: height * 0.16), cornerRadius: 3)
                mansard.position = CGPoint(x: 0, y: height * 0.92)
                mansard.fillColor = NSColor(calibratedRed: 0.25, green: 0.28, blue: 0.36, alpha: 1)
                mansard.strokeColor = .clear
                mansard.zPosition = 1
                group.addChild(mansard)
                for dx in [-width / 4, width / 5] as [CGFloat] {
                    let chimney = SKShapeNode(rectOf: CGSize(width: 12, height: 20))
                    chimney.position = CGPoint(x: dx, y: height + 6)
                    chimney.fillColor = NSColor(calibratedRed: 0.55, green: 0.42, blue: 0.36, alpha: 1)
                    chimney.strokeColor = .clear
                    group.addChild(chimney)
                }
            } else if city == .vegas {
                let neon = SKShapeNode(rectOf: CGSize(width: width, height: 5))
                neon.position = CGPoint(x: 0, y: height - 3)
                neon.fillColor = nsColor(city.buildingPalette[index % city.buildingPalette.count])
                neon.strokeColor = .clear
                neon.zPosition = 2
                group.addChild(neon)
            } else if city == .tokyo {
                let blade = SKShapeNode(rectOf: CGSize(width: 17, height: height * 0.52), cornerRadius: 4)
                blade.position = CGPoint(x: width / 2 - 12, y: height * 0.55)
                blade.fillColor = NSColor(calibratedRed: 0.95, green: 0.30, blue: 0.55, alpha: 0.9)
                blade.strokeColor = .clear
                blade.zPosition = 2
                group.addChild(blade)
            } else if index % 5 == 2 {
                // Rooftop water tower (NYC / Chicago vernacular)
                let tank = SKShapeNode(rectOf: CGSize(width: 30, height: 34), cornerRadius: 4)
                tank.position = CGPoint(x: -width / 5, y: height + 19)
                tank.fillColor = NSColor(calibratedRed: 0.45, green: 0.34, blue: 0.24, alpha: 1)
                tank.strokeColor = .clear
                group.addChild(tank)
                let cone = SKShapeNode(rectOf: CGSize(width: 36, height: 12), cornerRadius: 3)
                cone.position = CGPoint(x: -width / 5, y: height + 40)
                cone.fillColor = NSColor(calibratedRed: 0.35, green: 0.26, blue: 0.18, alpha: 1)
                cone.strokeColor = .clear
                group.addChild(cone)
            } else if index % 3 == 1 {
                let ac = SKShapeNode(rectOf: CGSize(width: 34, height: 14), cornerRadius: 2)
                ac.position = CGPoint(x: width / 5, y: height + 7)
                ac.fillColor = NSColor(white: 0.55, alpha: 1)
                ac.strokeColor = .clear
                group.addChild(ac)
            }
            if index % 4 == 3 {
                let antenna = SKShapeNode(rectOf: CGSize(width: 4, height: 44))
                antenna.position = CGPoint(x: width / 3, y: height + 20)
                antenna.fillColor = NSColor(white: 0, alpha: 0.5)
                antenna.strokeColor = .clear
                group.addChild(antenna)
            }
        }

        // Name sign
        let sign = makeLabel(name, size: isLandmark ? 19 : 14.5,
                             color: isLandmark ? NSColor(calibratedRed: 1, green: 0.85, blue: 0.4, alpha: 1) : .white,
                             pos: CGPoint(x: 0, y: height + 20))
        sign.zPosition = 2
        group.addChild(sign)

        // HP bar (appears once damaged — always drawn, hidden by alpha logic in damage fn)
        let hpBG = SKShapeNode(rectOf: CGSize(width: min(width, 190), height: 9), cornerRadius: 4)
        hpBG.name = "hpBG"
        hpBG.position = CGPoint(x: 0, y: height + 44)
        hpBG.fillColor = NSColor(white: 0, alpha: 0.55)
        hpBG.strokeColor = .clear
        hpBG.alpha = 0
        hpBG.zPosition = 2
        group.addChild(hpBG)
        let hpFill = SKShapeNode(rectOf: CGSize(width: min(width, 186), height: 6), cornerRadius: 3)
        hpFill.name = "hpFill"
        hpFill.position = CGPoint(x: 0, y: height + 44)
        hpFill.fillColor = NSColor(calibratedRed: 0.5, green: 0.95, blue: 0.45, alpha: 1)
        hpFill.strokeColor = .clear
        hpFill.alpha = 0
        hpFill.zPosition = 3
        group.addChild(hpFill)

        return building
    }

    // MARK: Monster building

    private func buildMonster() {
        monster.removeAllChildren()
        let kind = selectedMonster
        let plan = kind.bodyPlan
        let body = nsColor(kind.bodyColor)
        let accent = nsColor(kind.accentColor)
        let scale = CGFloat(kind.scale)

        monsterBodyGroup = SKNode()
        monster.addChild(monsterBodyGroup)

        // Geometry derived from this fighter's body plan — no two alike
        let bodyW = CGFloat(plan.bodyW)
        let bodyH = CGFloat(plan.bodyH)
        let legH: CGFloat = (plan.legs == .two || plan.legs == .four) ? 44
            : plan.legs == .spider ? 40 : plan.legs == .tentacles ? 30 : 4
        let torsoY = legH + bodyH / 2 - 4
        let topY = legH + bodyH - 4

        // Tail (behind body)
        if kind == .razorback || kind == .voltina || kind == .pyra || kind == .gorgo || kind == .mako || kind == .hydra {
            let tail = SKShapeNode(rectOf: CGSize(width: 78, height: 20), cornerRadius: 9)
            tail.position = CGPoint(x: -bodyW / 2 - 28, y: legH + 12)
            tail.zRotation = -0.25
            tail.fillColor = body
            tail.strokeColor = .clear
            monsterBodyGroup.addChild(tail)
        }

        // Scorpius: segmented tail arcing over the back, stinger last
        if kind == .scorpius {
            let arc: [(CGFloat, CGFloat, CGFloat)] = [
                (-0.38, 10, 12), (-0.22, 28, 10), (0.0, 38, 8.5), (0.16, 36, 7)
            ]
            for (fx, dy, r) in arc {
                let seg = SKShapeNode(circleOfRadius: r)
                seg.position = CGPoint(x: bodyW * fx, y: topY + dy)
                seg.fillColor = body
                seg.strokeColor = .clear
                monsterBodyGroup.addChild(seg)
            }
            let stingPath = CGMutablePath()
            stingPath.move(to: CGPoint(x: -6, y: 0))
            stingPath.addLine(to: CGPoint(x: 6, y: 0))
            stingPath.addLine(to: CGPoint(x: 10, y: -20))
            stingPath.closeSubpath()
            let sting = SKShapeNode(path: stingPath)
            sting.position = CGPoint(x: bodyW * 0.24, y: topY + 30)
            sting.fillColor = accent
            sting.strokeColor = .clear
            monsterBodyGroup.addChild(sting)
        }

        // Legs — the plan decides: two, four, spider, tentacles, or none
        switch plan.legs {
        case .two:
            let legW = min(max(bodyW * 0.24, 16), 30)
            for dx in [-bodyW * 0.26, bodyW * 0.26] {
                let leg = SKShapeNode(rectOf: CGSize(width: legW, height: legH + 8), cornerRadius: 7)
                leg.position = CGPoint(x: dx, y: legH / 2)
                leg.fillColor = body
                leg.strokeColor = NSColor(white: 0, alpha: 0.25)
                monsterBodyGroup.addChild(leg)
            }
        case .four:
            for dx in [-bodyW * 0.36, -bodyW * 0.13, bodyW * 0.13, bodyW * 0.36] {
                let leg = SKShapeNode(rectOf: CGSize(width: 19, height: legH + 8), cornerRadius: 6)
                leg.position = CGPoint(x: dx, y: legH / 2)
                leg.fillColor = body
                leg.strokeColor = NSColor(white: 0, alpha: 0.25)
                monsterBodyGroup.addChild(leg)
            }
        case .spider:
            for side in [-1, 1] as [CGFloat] {
                for i in 0..<3 {
                    let leg = SKShapeNode(rectOf: CGSize(width: 6.5, height: legH + 16), cornerRadius: 3)
                    leg.position = CGPoint(x: side * bodyW * (0.14 + 0.13 * CGFloat(i)), y: legH / 2)
                    leg.zRotation = side * (0.55 - 0.22 * CGFloat(i))
                    leg.fillColor = body
                    leg.strokeColor = .clear
                    monsterBodyGroup.addChild(leg)
                }
            }
        case .tentacles:
            for i in 0..<4 {
                let tent = SKShapeNode(rectOf: CGSize(width: 13, height: legH + 14), cornerRadius: 6)
                tent.position = CGPoint(x: -bodyW * 0.33 + CGFloat(i) * bodyW * 0.22, y: legH / 2)
                tent.zRotation = (i % 2 == 0 ? -1 : 1) * 0.16
                tent.fillColor = body
                tent.strokeColor = .clear
                monsterBodyGroup.addChild(tent)
            }
        case .none:
            break
        }

        // Hover glow for the legless robot (Sentinel never touches ground)
        if plan.legs == .none && kind.isRobot {
            let glow = SKShapeNode(path: CGPath(ellipseIn: CGRect(x: -bodyW * 0.4, y: 0, width: bodyW * 0.8, height: 13), transform: nil))
            glow.fillColor = accent
            glow.strokeColor = .clear
            glow.alpha = 0.35
            monsterBodyGroup.addChild(glow)
        }

        // Wings (Pyra, Noctura) behind torso
        if kind == .pyra || kind == .noctura {
            for side in [-1, 1] as [CGFloat] {
                let path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 95 * side, y: 55))
                path.addLine(to: CGPoint(x: 30 * side, y: -18))
                path.closeSubpath()
                let wing = SKShapeNode(path: path)
                wing.position = CGPoint(x: -10 * side, y: topY - 8)
                wing.fillColor = accent
                wing.strokeColor = .clear
                monsterBodyGroup.insertChild(wing, at: 0)
            }
        }

        // Torso — silhouette by shape
        let torso: SKShapeNode
        switch plan.shape {
        case .standard:
            torso = SKShapeNode(rectOf: CGSize(width: bodyW, height: bodyH), cornerRadius: 22)
        case .wide:
            torso = SKShapeNode(rectOf: CGSize(width: bodyW, height: bodyH), cornerRadius: 16)
        case .tall:
            torso = SKShapeNode(rectOf: CGSize(width: bodyW, height: bodyH), cornerRadius: 18)
        case .long:
            torso = SKShapeNode(rectOf: CGSize(width: bodyW, height: bodyH), cornerRadius: bodyH * 0.45)
        case .flat:
            torso = SKShapeNode(rectOf: CGSize(width: bodyW, height: bodyH), cornerRadius: 12)
        case .round:
            torso = SKShapeNode(path: CGPath(ellipseIn: CGRect(x: -bodyW / 2, y: -bodyH / 2, width: bodyW, height: bodyH), transform: nil))
        case .dome:
            let p = CGMutablePath()
            p.move(to: CGPoint(x: -bodyW / 2, y: -bodyH / 2))
            p.addLine(to: CGPoint(x: bodyW / 2, y: -bodyH / 2))
            p.addLine(to: CGPoint(x: bodyW / 2, y: 0))
            p.addArc(center: CGPoint(x: 0, y: 0), radius: bodyW / 2, startAngle: 0, endAngle: .pi, clockwise: false)
            p.closeSubpath()
            torso = SKShapeNode(path: p)
        }
        torso.position = CGPoint(x: 0, y: torsoY)
        torso.fillColor = body
        torso.strokeColor = NSColor(white: 0, alpha: 0.3)
        torso.lineWidth = 2
        if kind == .spectra { torso.alpha = 0.82 }
        monsterBodyGroup.addChild(torso)

        // Belly / chest accent
        let belly = SKShapeNode(rectOf: CGSize(width: bodyW * 0.58, height: bodyH * 0.62), cornerRadius: 18)
        belly.position = CGPoint(x: plan.headAtFront ? -bodyW * 0.06 : 4, y: torsoY - 2)
        belly.fillColor = accent
        belly.strokeColor = .clear
        belly.alpha = 0.85
        monsterBodyGroup.addChild(belly)

        // Battle scars — every one of Mama's girls has earned hers
        if !kind.isRobot {
            for (dx, dy) in [(-bodyW * 0.18, bodyH * 0.16), (bodyW * 0.14, -bodyH * 0.10)] as [(CGFloat, CGFloat)] {
                let scar = SKShapeNode(rectOf: CGSize(width: 4, height: bodyH * 0.30), cornerRadius: 2)
                scar.position = CGPoint(x: dx, y: torsoY + dy)
                scar.zRotation = 0.7
                scar.fillColor = NSColor(white: 0, alpha: 0.35)
                scar.strokeColor = .clear
                monsterBodyGroup.addChild(scar)
            }
        }

        // Robot chassis details: glowing core + panel lines
        if kind.isRobot {
            let core = SKShapeNode(circleOfRadius: 13)
            core.position = CGPoint(x: 0, y: torsoY)
            core.fillColor = accent
            core.strokeColor = NSColor(white: 0, alpha: 0.4)
            core.lineWidth = 2
            monsterBodyGroup.addChild(core)
            for dy in [-bodyH * 0.30, bodyH * 0.30] {
                let seam = SKShapeNode(rectOf: CGSize(width: bodyW * 0.82, height: 3))
                seam.position = CGPoint(x: 0, y: torsoY + dy)
                seam.fillColor = NSColor(white: 0, alpha: 0.35)
                seam.strokeColor = .clear
                monsterBodyGroup.addChild(seam)
            }
        }

        // Back spikes (Razorback / Yetira / Magmor) — along the spine,
        // horizontal on long bodies, vertical on upright ones
        if kind == .razorback || kind == .yetira || kind == .magmor {
            for i in 0..<4 {
                let spikePath = CGMutablePath()
                spikePath.move(to: CGPoint(x: -10, y: 0))
                spikePath.addLine(to: CGPoint(x: 10, y: 0))
                spikePath.addLine(to: CGPoint(x: 0, y: 24))
                spikePath.closeSubpath()
                let spike = SKShapeNode(path: spikePath)
                if plan.shape == .long {
                    spike.position = CGPoint(x: -bodyW / 2 + 24 + CGFloat(i) * 27, y: topY + 2)
                } else {
                    spike.position = CGPoint(x: -bodyW / 2 + 8, y: legH + 14 + CGFloat(i) * (bodyH / 4.2))
                }
                spike.fillColor = accent
                spike.strokeColor = .clear
                monsterBodyGroup.addChild(spike)
            }
        }

        // Mako: dorsal fin
        if kind == .mako {
            let finPath = CGMutablePath()
            finPath.move(to: CGPoint(x: -16, y: 0))
            finPath.addLine(to: CGPoint(x: 16, y: 0))
            finPath.addLine(to: CGPoint(x: -2, y: 30))
            finPath.closeSubpath()
            let fin = SKShapeNode(path: finPath)
            fin.position = CGPoint(x: -6, y: topY + 2)
            fin.fillColor = accent
            fin.strokeColor = .clear
            monsterBodyGroup.addChild(fin)
        }

        // Head — placed and scaled by the plan (quadrupeds carry it up
        // front; upright fighters wear it on top). Features are drawn at
        // the classic r33 scale inside the group, then the group scales.
        let headGroup = SKNode()
        let headX: CGFloat = plan.headAtFront ? bodyW / 2 + CGFloat(plan.headR) * 0.30 : 6
        let headY: CGFloat = plan.headAtFront ? legH + bodyH * 0.74 : topY + CGFloat(plan.headR) * 0.52
        headGroup.position = CGPoint(x: headX, y: headY)
        headGroup.setScale(CGFloat(plan.headR) / 33)
        monsterBodyGroup.addChild(headGroup)
        let head = SKShapeNode(circleOfRadius: 33)
        head.fillColor = body
        head.strokeColor = NSColor(white: 0, alpha: 0.3)
        head.lineWidth = 2
        headGroup.addChild(head)
        if kind.isRobot {
            // Visor eye-band + antenna + jaw grill
            let visor = SKShapeNode(rectOf: CGSize(width: 44, height: 13), cornerRadius: 6)
            visor.position = CGPoint(x: 10, y: 8)
            visor.fillColor = NSColor(white: 0.08, alpha: 1)
            visor.strokeColor = .clear
            headGroup.addChild(visor)
            let visorGlow = SKShapeNode(rectOf: CGSize(width: 36, height: 4), cornerRadius: 2)
            visorGlow.position = CGPoint(x: 12, y: 8)
            visorGlow.fillColor = accent
            visorGlow.strokeColor = .clear
            headGroup.addChild(visorGlow)
            let antennaRod = SKShapeNode(rectOf: CGSize(width: 4, height: 24))
            antennaRod.position = CGPoint(x: -12, y: 38)
            antennaRod.fillColor = body
            antennaRod.strokeColor = .clear
            headGroup.addChild(antennaRod)
            let antennaTip = SKShapeNode(circleOfRadius: 5)
            antennaTip.position = CGPoint(x: -12, y: 52)
            antennaTip.fillColor = accent
            antennaTip.strokeColor = .clear
            headGroup.addChild(antennaTip)
            for i in 0..<3 {
                let grill = SKShapeNode(rectOf: CGSize(width: 20, height: 3))
                grill.position = CGPoint(x: 20, y: -12 - CGFloat(i) * 6)
                grill.fillColor = NSColor(white: 0, alpha: 0.45)
                grill.strokeColor = .clear
                headGroup.addChild(grill)
            }
        } else {
            // Snout
            let snout = SKShapeNode(rectOf: CGSize(width: 30, height: 20), cornerRadius: 8)
            snout.position = CGPoint(x: 26, y: -6)
            snout.fillColor = accent
            snout.strokeColor = .clear
            headGroup.addChild(snout)
            // Eye (angry)
            let eye = SKShapeNode(circleOfRadius: 6.5)
            eye.position = CGPoint(x: 13, y: 9)
            eye.fillColor = .white
            eye.strokeColor = .clear
            headGroup.addChild(eye)
            let pupil = SKShapeNode(circleOfRadius: 3.2)
            pupil.position = CGPoint(x: 15, y: 9)
            pupil.fillColor = .black
            pupil.strokeColor = .clear
            headGroup.addChild(pupil)
            // Gruesome pass: furious brow, a snarl of teeth, drool.
            // Sweet names. None of them are sweet.
            let brow = SKShapeNode(rectOf: CGSize(width: 26, height: 6), cornerRadius: 3)
            brow.position = CGPoint(x: 13, y: 19)
            brow.zRotation = -0.38
            brow.fillColor = NSColor(white: 0.08, alpha: 0.85)
            brow.strokeColor = .clear
            headGroup.addChild(brow)
            for i in 0..<3 {
                let toothPath = CGMutablePath()
                toothPath.move(to: CGPoint(x: -3.5, y: 0))
                toothPath.addLine(to: CGPoint(x: 3.5, y: 0))
                toothPath.addLine(to: CGPoint(x: 0, y: -9))
                toothPath.closeSubpath()
                let tooth = SKShapeNode(path: toothPath)
                tooth.position = CGPoint(x: 18 + CGFloat(i) * 9, y: -13)
                tooth.fillColor = .white
                tooth.strokeColor = .clear
                headGroup.addChild(tooth)
            }
            let drool = SKShapeNode(rectOf: CGSize(width: 3.5, height: 13), cornerRadius: 1.75)
            drool.position = CGPoint(x: 38, y: -20)
            drool.fillColor = NSColor(calibratedRed: 0.75, green: 0.95, blue: 0.8, alpha: 0.8)
            drool.strokeColor = .clear
            headGroup.addChild(drool)
        }

        // Kind-specific head features
        switch kind {
        case .pyra, .yetira:
            for side in [-1, 1] as [CGFloat] {
                let hornPath = CGMutablePath()
                hornPath.move(to: CGPoint(x: -6, y: 0))
                hornPath.addLine(to: CGPoint(x: 6, y: 0))
                hornPath.addLine(to: CGPoint(x: 12 * side, y: 26))
                hornPath.closeSubpath()
                let horn = SKShapeNode(path: hornPath)
                horn.position = CGPoint(x: 18 * side, y: 24)
                horn.fillColor = accent
                horn.strokeColor = .clear
                headGroup.addChild(horn)
            }
        case .voltina:
            let bolt = makeLabel("⚡", size: 24, pos: CGPoint(x: -8, y: 34))
            headGroup.addChild(bolt)
        case .krawl:
            for side in [-1, 1] as [CGFloat] {
                let stalk = SKShapeNode(rectOf: CGSize(width: 5, height: 22))
                stalk.position = CGPoint(x: 12 * side, y: 34)
                stalk.fillColor = body
                stalk.strokeColor = .clear
                headGroup.addChild(stalk)
                let stalkEye = SKShapeNode(circleOfRadius: 6)
                stalkEye.position = CGPoint(x: 12 * side, y: 47)
                stalkEye.fillColor = .white
                stalkEye.strokeColor = .clear
                headGroup.addChild(stalkEye)
            }
        case .zorgath:
            for side in [-1, 1] as [CGFloat] {
                let stalk = SKShapeNode(rectOf: CGSize(width: 4, height: 26))
                stalk.position = CGPoint(x: 10 * side, y: 40)
                stalk.zRotation = side * -0.3
                stalk.fillColor = body
                stalk.strokeColor = .clear
                headGroup.addChild(stalk)
                let stalkEye = SKShapeNode(circleOfRadius: 6.5)
                stalkEye.position = CGPoint(x: 14 * side, y: 55)
                stalkEye.fillColor = accent
                stalkEye.strokeColor = .clear
                headGroup.addChild(stalkEye)
            }
        default:
            break
        }

        // Hydra: two extra heads on necks — three heads, three opinions
        if kind == .hydra {
            for side in [-1, 1] as [CGFloat] {
                let neck = SKShapeNode(rectOf: CGSize(width: 13, height: 44), cornerRadius: 6)
                neck.position = CGPoint(x: side * 30, y: topY + 12)
                neck.zRotation = side * -0.5
                neck.fillColor = body
                neck.strokeColor = .clear
                monsterBodyGroup.addChild(neck)
                let mini = SKNode()
                mini.position = CGPoint(x: side * 52, y: topY + 34)
                let miniHead = SKShapeNode(circleOfRadius: 19)
                miniHead.fillColor = body
                miniHead.strokeColor = NSColor(white: 0, alpha: 0.3)
                miniHead.lineWidth = 2
                mini.addChild(miniHead)
                let miniSnout = SKShapeNode(rectOf: CGSize(width: 18, height: 12), cornerRadius: 5)
                miniSnout.position = CGPoint(x: 16, y: -4)
                miniSnout.fillColor = accent
                miniSnout.strokeColor = .clear
                mini.addChild(miniSnout)
                let miniEye = SKShapeNode(circleOfRadius: 4)
                miniEye.position = CGPoint(x: 8, y: 6)
                miniEye.fillColor = .white
                miniEye.strokeColor = .clear
                mini.addChild(miniEye)
                monsterBodyGroup.addChild(mini)
            }
        }

        // Behemoth: the horn that ends arguments
        if kind == .behemoth {
            let hornPath = CGMutablePath()
            hornPath.move(to: CGPoint(x: -7, y: 0))
            hornPath.addLine(to: CGPoint(x: 7, y: 0))
            hornPath.addLine(to: CGPoint(x: 20, y: 16))
            hornPath.closeSubpath()
            let horn = SKShapeNode(path: hornPath)
            horn.position = CGPoint(x: headX + CGFloat(plan.headR) * 0.72, y: headY + 2)
            horn.fillColor = accent
            horn.strokeColor = .clear
            monsterBodyGroup.addChild(horn)
        }

        // Noctura: ears
        if kind == .noctura {
            for side in [-1, 1] as [CGFloat] {
                let earPath = CGMutablePath()
                earPath.move(to: CGPoint(x: -7, y: 0))
                earPath.addLine(to: CGPoint(x: 7, y: 0))
                earPath.addLine(to: CGPoint(x: 3 * side, y: 22))
                earPath.closeSubpath()
                let ear = SKShapeNode(path: earPath)
                ear.position = CGPoint(x: headX + side * CGFloat(plan.headR) * 0.52, y: headY + CGFloat(plan.headR) * 0.78)
                ear.fillColor = body
                ear.strokeColor = .clear
                monsterBodyGroup.addChild(ear)
            }
        }

        // Signature features — Marcus's rule: VERY different. Every
        // fighter carries drawn features no other fighter has.
        switch kind {
        case .bruno:
            // Knuckle arms: long arms hanging low, huge fists
            let arm = SKShapeNode(rectOf: CGSize(width: 17, height: bodyH * 0.95), cornerRadius: 8)
            arm.position = CGPoint(x: bodyW * 0.52, y: torsoY - 6)
            arm.fillColor = body
            arm.strokeColor = .clear
            monsterBodyGroup.addChild(arm)
            let fist = SKShapeNode(circleOfRadius: 16)
            fist.position = CGPoint(x: bodyW * 0.52, y: legH + 10)
            fist.fillColor = body
            fist.strokeColor = NSColor(white: 0, alpha: 0.3)
            monsterBodyGroup.addChild(fist)
        case .gorgo:
            // T-rex teeth row + comedy-tiny arm
            for i in 0..<4 {
                let toothPath = CGMutablePath()
                toothPath.move(to: CGPoint(x: -4, y: 0))
                toothPath.addLine(to: CGPoint(x: 4, y: 0))
                toothPath.addLine(to: CGPoint(x: 0, y: -10))
                toothPath.closeSubpath()
                let tooth = SKShapeNode(path: toothPath)
                tooth.position = CGPoint(x: 16 + CGFloat(i) * 8, y: -15)
                tooth.fillColor = .white
                tooth.strokeColor = .clear
                headGroup.addChild(tooth)
            }
            let tinyArm = SKShapeNode(rectOf: CGSize(width: 7, height: 20), cornerRadius: 3)
            tinyArm.position = CGPoint(x: bodyW * 0.30, y: torsoY - 8)
            tinyArm.zRotation = 0.5
            tinyArm.fillColor = body
            tinyArm.strokeColor = .clear
            monsterBodyGroup.addChild(tinyArm)
        case .kraken:
            // Two dome eyes + a squid beak
            for dx in [-bodyW * 0.18, bodyW * 0.18] {
                let eye = SKShapeNode(circleOfRadius: 13)
                eye.position = CGPoint(x: dx, y: topY - 12)
                eye.fillColor = .white
                eye.strokeColor = .clear
                monsterBodyGroup.addChild(eye)
                let pupil = SKShapeNode(circleOfRadius: 6)
                pupil.position = CGPoint(x: dx + 3, y: topY - 12)
                pupil.fillColor = .black
                pupil.strokeColor = .clear
                monsterBodyGroup.addChild(pupil)
            }
            let beakPath = CGMutablePath()
            beakPath.move(to: CGPoint(x: -10, y: 0))
            beakPath.addLine(to: CGPoint(x: 10, y: 0))
            beakPath.addLine(to: CGPoint(x: 0, y: -18))
            beakPath.closeSubpath()
            let beak = SKShapeNode(path: beakPath)
            beak.position = CGPoint(x: bodyW * 0.30, y: legH + 26)
            beak.fillColor = accent
            beak.strokeColor = .clear
            monsterBodyGroup.addChild(beak)
        case .arachnia:
            // Four extra eyes + fangs
            for dx in [-14, -5, 5, 14] as [CGFloat] {
                let eye = SKShapeNode(circleOfRadius: (dx == -5 || dx == 5) ? 4.5 : 3)
                eye.position = CGPoint(x: dx, y: 16)
                eye.fillColor = accent
                eye.strokeColor = .clear
                headGroup.addChild(eye)
            }
            for dx in [18, 30] as [CGFloat] {
                let fangPath = CGMutablePath()
                fangPath.move(to: CGPoint(x: -3.5, y: 0))
                fangPath.addLine(to: CGPoint(x: 3.5, y: 0))
                fangPath.addLine(to: CGPoint(x: 0, y: -13))
                fangPath.closeSubpath()
                let fang = SKShapeNode(path: fangPath)
                fang.position = CGPoint(x: dx, y: -14)
                fang.fillColor = .white
                fang.strokeColor = .clear
                headGroup.addChild(fang)
            }
        case .dunemaw:
            // Body segment seams + a ring of maw teeth
            for i in 1...5 {
                let seam = SKShapeNode(rectOf: CGSize(width: 5, height: bodyH * 0.86), cornerRadius: 2)
                seam.position = CGPoint(x: -bodyW / 2 + CGFloat(i) * bodyW / 6, y: torsoY)
                seam.fillColor = NSColor(white: 0, alpha: 0.28)
                seam.strokeColor = .clear
                monsterBodyGroup.addChild(seam)
            }
            for i in 0..<5 {
                let tooth = SKShapeNode(rectOf: CGSize(width: 4, height: 9), cornerRadius: 2)
                tooth.position = CGPoint(x: headX + CGFloat(plan.headR) * 0.55, y: headY - 12 + CGFloat(i) * 6)
                tooth.fillColor = .white
                tooth.strokeColor = .clear
                monsterBodyGroup.addChild(tooth)
            }
        case .spectra:
            // Wispy ghost tail + hollow eyes
            for i in 0..<4 {
                let wispPath = CGMutablePath()
                wispPath.move(to: CGPoint(x: -9, y: 0))
                wispPath.addLine(to: CGPoint(x: 9, y: 0))
                wispPath.addLine(to: CGPoint(x: 0, y: -22))
                wispPath.closeSubpath()
                let wisp = SKShapeNode(path: wispPath)
                wisp.position = CGPoint(x: -bodyW * 0.36 + CGFloat(i) * bodyW * 0.24, y: legH + 2)
                wisp.fillColor = body
                wisp.strokeColor = .clear
                wisp.alpha = 0.82
                monsterBodyGroup.addChild(wisp)
            }
            for dx in [4, 22] as [CGFloat] {
                let hollow = SKShapeNode(path: CGPath(ellipseIn: CGRect(x: -5, y: -8, width: 10, height: 16), transform: nil))
                hollow.position = CGPoint(x: dx, y: 8)
                hollow.fillColor = NSColor(white: 0.05, alpha: 0.9)
                hollow.strokeColor = .clear
                headGroup.addChild(hollow)
            }
        case .voltina:
            // Electric coil bands + forked tongue
            for i in 1...3 {
                let band = SKShapeNode(rectOf: CGSize(width: 10, height: bodyH * 0.92), cornerRadius: 4)
                band.position = CGPoint(x: -bodyW / 2 + CGFloat(i) * bodyW / 4, y: torsoY)
                band.fillColor = accent
                band.strokeColor = .clear
                monsterBodyGroup.addChild(band)
            }
            let tongue = SKShapeNode(rectOf: CGSize(width: 20, height: 3.5), cornerRadius: 1.5)
            tongue.position = CGPoint(x: 46, y: -8)
            tongue.fillColor = NSColor(calibratedRed: 0.9, green: 0.2, blue: 0.3, alpha: 1)
            tongue.strokeColor = .clear
            headGroup.addChild(tongue)
        case .magmor:
            // Lava cracks across the torso
            for (dx, rot) in [(-bodyW * 0.22, 0.4), (bodyW * 0.05, -0.3), (bodyW * 0.26, 0.55)] as [(CGFloat, CGFloat)] {
                let crack = SKShapeNode(rectOf: CGSize(width: 5, height: bodyH * 0.42), cornerRadius: 2)
                crack.position = CGPoint(x: dx, y: torsoY + bodyH * 0.12)
                crack.zRotation = rot
                crack.fillColor = accent
                crack.strokeColor = .clear
                monsterBodyGroup.addChild(crack)
            }
        case .yetira:
            // Tusks rising from the lower jaw
            for dx in [16, 34] as [CGFloat] {
                let tuskPath = CGMutablePath()
                tuskPath.move(to: CGPoint(x: -4, y: 0))
                tuskPath.addLine(to: CGPoint(x: 4, y: 0))
                tuskPath.addLine(to: CGPoint(x: 1, y: 17))
                tuskPath.closeSubpath()
                let tusk = SKShapeNode(path: tuskPath)
                tusk.position = CGPoint(x: dx, y: -15)
                tusk.fillColor = .white
                tusk.strokeColor = .clear
                headGroup.addChild(tusk)
            }
        case .mako:
            // Gill slits + a real tail fin
            for i in 0..<3 {
                let gill = SKShapeNode(rectOf: CGSize(width: 4, height: bodyH * 0.5), cornerRadius: 2)
                gill.position = CGPoint(x: bodyW * 0.26 - CGFloat(i) * 11, y: torsoY)
                gill.zRotation = 0.25
                gill.fillColor = NSColor(white: 0, alpha: 0.3)
                gill.strokeColor = .clear
                monsterBodyGroup.addChild(gill)
            }
            let finPath = CGMutablePath()
            finPath.move(to: CGPoint(x: 0, y: -20))
            finPath.addLine(to: CGPoint(x: 0, y: 22))
            finPath.addLine(to: CGPoint(x: -17, y: 4))
            finPath.closeSubpath()
            let tailFin = SKShapeNode(path: finPath)
            tailFin.position = CGPoint(x: -bodyW / 2 - 62, y: legH + 14)
            tailFin.fillColor = body
            tailFin.strokeColor = .clear
            monsterBodyGroup.addChild(tailFin)
        case .krawl:
            // One GIANT claw (the other one is normal, don't stare)
            let clawArm = SKShapeNode(rectOf: CGSize(width: 13, height: 34), cornerRadius: 6)
            clawArm.position = CGPoint(x: bodyW * 0.42, y: topY + 4)
            clawArm.zRotation = -0.4
            clawArm.fillColor = body
            clawArm.strokeColor = .clear
            monsterBodyGroup.addChild(clawArm)
            let claw = SKShapeNode(circleOfRadius: 21)
            claw.position = CGPoint(x: bodyW * 0.50, y: topY + 22)
            claw.fillColor = accent
            claw.strokeColor = NSColor(white: 0, alpha: 0.3)
            claw.lineWidth = 2
            monsterBodyGroup.addChild(claw)
            let notchPath = CGMutablePath()
            notchPath.move(to: CGPoint(x: 0, y: 0))
            notchPath.addLine(to: CGPoint(x: 20, y: 8))
            notchPath.addLine(to: CGPoint(x: 4, y: -12))
            notchPath.closeSubpath()
            let notch = SKShapeNode(path: notchPath)
            notch.position = claw.position
            notch.fillColor = NSColor(white: 0, alpha: 0.35)
            notch.strokeColor = .clear
            monsterBodyGroup.addChild(notch)
        case .noctura:
            // Vampire fangs
            for dx in [20, 32] as [CGFloat] {
                let fangPath = CGMutablePath()
                fangPath.move(to: CGPoint(x: -3, y: 0))
                fangPath.addLine(to: CGPoint(x: 3, y: 0))
                fangPath.addLine(to: CGPoint(x: 0, y: -11))
                fangPath.closeSubpath()
                let fang = SKShapeNode(path: fangPath)
                fang.position = CGPoint(x: dx, y: -13)
                fang.fillColor = .white
                fang.strokeColor = .clear
                headGroup.addChild(fang)
            }
        case .pyra:
            // Flame crest along the spine
            for i in 0..<3 {
                let flamePath = CGMutablePath()
                flamePath.move(to: CGPoint(x: -8, y: 0))
                flamePath.addLine(to: CGPoint(x: 8, y: 0))
                flamePath.addLine(to: CGPoint(x: 0, y: 24 - CGFloat(i) * 4))
                flamePath.closeSubpath()
                let flame = SKShapeNode(path: flamePath)
                flame.position = CGPoint(x: -bodyW * 0.22 + CGFloat(i) * 17, y: topY + 1)
                flame.fillColor = accent
                flame.strokeColor = .clear
                monsterBodyGroup.addChild(flame)
            }
        case .razorback:
            // Tail club
            let club = SKShapeNode(circleOfRadius: 13)
            club.position = CGPoint(x: -bodyW / 2 - 64, y: legH + 6)
            club.fillColor = accent
            club.strokeColor = .clear
            monsterBodyGroup.addChild(club)
        case .mechaRex:
            // Exhaust stacks + a steel jaw plate
            for dx in [-bodyW * 0.28, -bodyW * 0.13] {
                let stack = SKShapeNode(rectOf: CGSize(width: 11, height: 26), cornerRadius: 3)
                stack.position = CGPoint(x: dx, y: topY + 10)
                stack.fillColor = NSColor(white: 0.25, alpha: 1)
                stack.strokeColor = .clear
                monsterBodyGroup.addChild(stack)
            }
            let jaw = SKShapeNode(rectOf: CGSize(width: 34, height: 10), cornerRadius: 4)
            jaw.position = CGPoint(x: 24, y: -22)
            jaw.fillColor = NSColor(white: 0.30, alpha: 1)
            jaw.strokeColor = .clear
            headGroup.addChild(jaw)
        case .titan9:
            // Shoulder missile pods
            for side in [-1, 1] as [CGFloat] {
                let pod = SKShapeNode(rectOf: CGSize(width: 30, height: 20), cornerRadius: 5)
                pod.position = CGPoint(x: side * bodyW * 0.40, y: topY + 4)
                pod.fillColor = NSColor(white: 0.28, alpha: 1)
                pod.strokeColor = .clear
                monsterBodyGroup.addChild(pod)
                for k in 0..<3 {
                    let tip = SKShapeNode(circleOfRadius: 4)
                    tip.position = CGPoint(x: side * bodyW * 0.40 - 8 + CGFloat(k) * 8, y: topY + 4)
                    tip.fillColor = accent
                    tip.strokeColor = .clear
                    monsterBodyGroup.addChild(tip)
                }
            }
        case .crusher:
            // Wrecking ball on a chain
            let chain = SKShapeNode(rectOf: CGSize(width: 4, height: 44), cornerRadius: 2)
            chain.position = CGPoint(x: bodyW * 0.46, y: topY - 12)
            chain.zRotation = 0.35
            chain.fillColor = NSColor(white: 0.2, alpha: 1)
            chain.strokeColor = .clear
            monsterBodyGroup.addChild(chain)
            let ball = SKShapeNode(circleOfRadius: 17)
            ball.position = CGPoint(x: bodyW * 0.46 + 15, y: topY - 36)
            ball.fillColor = NSColor(white: 0.15, alpha: 1)
            ball.strokeColor = NSColor(white: 0, alpha: 0.4)
            ball.lineWidth = 2
            monsterBodyGroup.addChild(ball)
        case .scrapjack:
            // Horseshoe magnet + a junk pile bolted to his back
            for dx in [bodyW * 0.40, bodyW * 0.40 + 16] {
                let prong = SKShapeNode(rectOf: CGSize(width: 8, height: 22), cornerRadius: 3)
                prong.position = CGPoint(x: dx, y: torsoY + 2)
                prong.fillColor = NSColor(calibratedRed: 0.85, green: 0.2, blue: 0.2, alpha: 1)
                prong.strokeColor = .clear
                monsterBodyGroup.addChild(prong)
            }
            let magnetTop = SKShapeNode(rectOf: CGSize(width: 24, height: 9), cornerRadius: 4)
            magnetTop.position = CGPoint(x: bodyW * 0.40 + 8, y: torsoY + 15)
            magnetTop.fillColor = NSColor(calibratedRed: 0.85, green: 0.2, blue: 0.2, alpha: 1)
            magnetTop.strokeColor = .clear
            monsterBodyGroup.addChild(magnetTop)
            for (dx, s) in [(-bodyW * 0.30, 15.0), (-bodyW * 0.16, 11.0), (-bodyW * 0.38, 9.0)] as [(CGFloat, CGFloat)] {
                let junk = SKShapeNode(rectOf: CGSize(width: s, height: s * 0.8), cornerRadius: 2)
                junk.position = CGPoint(x: dx, y: topY + s * 0.3)
                junk.zRotation = dx
                junk.fillColor = NSColor(white: 0.45, alpha: 1)
                junk.strokeColor = .clear
                monsterBodyGroup.addChild(junk)
            }
        case .voltbot:
            // Tesla coils
            for dx in [-bodyW * 0.24, bodyW * 0.24] {
                let rod = SKShapeNode(rectOf: CGSize(width: 5, height: 30), cornerRadius: 2)
                rod.position = CGPoint(x: dx, y: topY + 12)
                rod.fillColor = NSColor(white: 0.3, alpha: 1)
                rod.strokeColor = .clear
                monsterBodyGroup.addChild(rod)
                let orb = SKShapeNode(circleOfRadius: 10)
                orb.position = CGPoint(x: dx, y: topY + 30)
                orb.fillColor = accent
                orb.strokeColor = NSColor(white: 0, alpha: 0.3)
                monsterBodyGroup.addChild(orb)
            }
        case .sentinel:
            // Solar panel wings + a comms dish
            for side in [-1, 1] as [CGFloat] {
                let panel = SKShapeNode(rectOf: CGSize(width: 44, height: 20), cornerRadius: 3)
                panel.position = CGPoint(x: side * (bodyW / 2 + 20), y: torsoY + 8)
                panel.zRotation = side * -0.18
                panel.fillColor = NSColor(calibratedRed: 0.15, green: 0.3, blue: 0.75, alpha: 1)
                panel.strokeColor = NSColor(white: 0, alpha: 0.3)
                monsterBodyGroup.addChild(panel)
            }
            let dishPath = CGMutablePath()
            dishPath.move(to: CGPoint(x: -16, y: 0))
            dishPath.addArc(center: .zero, radius: 16, startAngle: .pi, endAngle: 0, clockwise: false)
            dishPath.closeSubpath()
            let dish = SKShapeNode(path: dishPath)
            dish.position = CGPoint(x: 0, y: topY + 2)
            dish.fillColor = NSColor(white: 0.85, alpha: 1)
            dish.strokeColor = NSColor(white: 0, alpha: 0.3)
            monsterBodyGroup.addChild(dish)
            // Orbiting scout drone on a pivot (roadmap 6 nice-to-have)
            let pivot = SKNode()
            pivot.position = CGPoint(x: 0, y: torsoY + 10)
            let drone = SKNode()
            drone.position = CGPoint(x: 74, y: 0)
            let droneBody = SKShapeNode(circleOfRadius: 9)
            droneBody.fillColor = NSColor(white: 0.75, alpha: 1)
            droneBody.strokeColor = NSColor(white: 0, alpha: 0.35)
            drone.addChild(droneBody)
            let droneEye = SKShapeNode(circleOfRadius: 3.5)
            droneEye.fillColor = NSColor(calibratedRed: 1, green: 0.25, blue: 0.25, alpha: 1)
            droneEye.strokeColor = .clear
            drone.addChild(droneEye)
            pivot.addChild(drone)
            pivot.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 3.6)))
            monsterBodyGroup.addChild(pivot)
        default:
            break // hydra (3 heads), scorpius (stinger arc), behemoth (horn), zorgath (eye stalks) already wear theirs
        }

        // Attack arm (pivot at shoulder, swings on smash)
        monsterArm = SKNode()
        let armLen = 74 * min(max(bodyH / 104, 0.7), 1.25)
        monsterArm.position = CGPoint(
            x: plan.headAtFront ? bodyW * 0.30 : bodyW / 2 - 2,
            y: plan.headAtFront ? legH + bodyH * 0.70 : legH + bodyH * 0.76)
        monsterBodyGroup.addChild(monsterArm)
        let armShape = SKShapeNode(rectOf: CGSize(width: 22, height: armLen), cornerRadius: 10)
        armShape.position = CGPoint(x: 8, y: -armLen / 2 + 6)
        armShape.fillColor = body
        armShape.strokeColor = NSColor(white: 0, alpha: 0.25)
        monsterArm.addChild(armShape)
        // Claw / fist
        let fist = SKShapeNode(circleOfRadius: kind == .krawl ? 26 : (bodyW > 115 ? 18 : 15))
        fist.position = CGPoint(x: 10, y: -armLen - 2)
        fist.fillColor = kind == .krawl ? accent : body
        fist.strokeColor = NSColor(white: 0, alpha: 0.25)
        monsterArm.addChild(fist)
        // Claws on the striking fist — nothing about this is friendly
        if !kind.isRobot {
            for i in 0..<3 {
                let clawPath = CGMutablePath()
                clawPath.move(to: CGPoint(x: -4, y: 0))
                clawPath.addLine(to: CGPoint(x: 4, y: 0))
                clawPath.addLine(to: CGPoint(x: 0, y: -13))
                clawPath.closeSubpath()
                let claw = SKShapeNode(path: clawPath)
                claw.position = CGPoint(x: 2 + CGFloat(i) * 8, y: -armLen - 12)
                claw.fillColor = NSColor(calibratedRed: 0.92, green: 0.88, blue: 0.74, alpha: 1)
                claw.strokeColor = .clear
                monsterArm.addChild(claw)
            }
        }

        // Far arm (static, behind) — only on two-legged upright builds
        if plan.legs == .two && !plan.headAtFront {
            let backArm = SKShapeNode(rectOf: CGSize(width: 18, height: 62), cornerRadius: 9)
            backArm.position = CGPoint(x: -bodyW / 2 + 2, y: torsoY + 4)
            backArm.zRotation = 0.35
            backArm.fillColor = body
            backArm.strokeColor = .clear
            backArm.alpha = 0.75
            monsterBodyGroup.insertChild(backArm, at: 0)
        }

        monster.setScale(scale)
        monster.position = CGPoint(x: 240, y: groundY)
        monster.zPosition = 20
        monster.xScale = scale // facing applied in update via sign
    }

    // MARK: Selection plumbing

    private func choose(index: Int) {
        if index == 9999 { showAdMenu(); return } // the sellout button
        if (9000..<(9000 + Scoring.adMenu.count)).contains(index) { playAd(at: index - 9000); return }
        switch state {
        case .monsterSelect:
            guard MonsterKind.allCases.indices.contains(index) else { return }
            selectedMonster = MonsterKind.allCases[index]
            playSFX("Pop")
            showCitySelect()
        case .citySelect:
            guard CityKind.allCases.indices.contains(index) else { return }
            if !CityKind.allCases[index].isAvailable() {
                playSFX("Basso") // hasn't dropped yet
                return
            }
            if cityProgress[CityKind.allCases[index].rawValue]?.spent == true {
                playSFX("Basso") // closed for the season
                return
            }
            selectedCity = CityKind.allCases[index]
            playSFX("Pop")
            startGame()
        case .timeSelect:
            break // retired — every city runs on its own one-hour clock
        case .playing, .gameOver:
            break
        }
    }

    // MARK: Input

    override func keyDown(with event: NSEvent) {
        let code = event.keyCode

        if code == Key.m {
            mamaMuted.toggle()
            UserDefaults.standard.set(mamaMuted, forKey: "kaijurampage.muted")
            if mamaMuted { mamaSynth.stopSpeaking(at: .immediate) }
            showMamaText(mamaMuted ? "MAMA HAS BEEN MUTED. SHE'LL REMEMBER THIS."
                                   : "MAMA CAN SPEAK AGAIN. SHE NEVER STOPPED WATCHING.")
            return
        }

        if code == Key.h {
            if state != .playing || isPausedGame { toggleHowTo() }
            return
        }

        if state == .playing {
            if (code == Key.q || code == Key.f) && !isPausedGame {
                // Leave the city: its clock freezes exactly here.
                endReason = .leftCity
                showResults()
                return
            }
            if code == Key.p || code == Key.escape {
                if !event.isARepeat {
                    isPausedGame.toggle()
                    if isPausedGame { showPauseOverlay() } else { clearOverlay() }
                }
                return
            }
            keysPressed.insert(code)
            return
        }
        if state == .gameOver {
            if code == Key.r { startGame() }
            if code == Key.enter || code == Key.keypadEnter { showMonsterSelect() }
            return
        }
        // Selection states
        if adTimeLeft > 0 { return } // mid-ad: no input. That's showbiz.
        if adMenuShowing {
            if code == Key.escape { adMenuShowing = false; showCitySelect() }
            else if let digitIndex = Key.digits.firstIndex(of: code),
                    digitIndex < Scoring.adMenu.count { playAd(at: digitIndex) }
            return
        }
        if showingLeaderboard {
            if code == Key.escape || code == Key.l {
                showingLeaderboard = false
                showMonsterSelect()
            }
            return
        }
        if state == .monsterSelect && code == Key.l {
            showLeaderboard()
            return
        }
        if state == .citySelect && code == Key.a {
            choose(index: 9999)
            return
        }
        if code == Key.right || code == Key.tab {
            if state == .monsterSelect {
                monsterPage = (monsterPage + 1) % 3
                showMonsterSelect()
            } else if state == .citySelect {
                cityPage = (cityPage + 1) % cityPageCount
                showCitySelect()
            }
            return
        }
        if code == Key.left {
            if state == .monsterSelect {
                monsterPage = (monsterPage + 2) % 3
                showMonsterSelect()
            } else if state == .citySelect {
                cityPage = (cityPage + cityPageCount - 1) % cityPageCount
                showCitySelect()
            }
            return
        }
        if let digitIndex = Key.digits.firstIndex(of: code) {
            let base = state == .monsterSelect ? monsterPage * 8
                : (state == .citySelect ? cityPage * 8 : 0)
            choose(index: base + digitIndex)
        }
    }

    override func keyUp(with event: NSEvent) {
        keysPressed.remove(event.keyCode)
    }

    override func mouseDown(with event: NSEvent) {
        let scenePoint = event.location(in: self)
        // Convert to camera space (camera children live around the camera center).
        let camPoint = CGPoint(x: scenePoint.x - cam.position.x, y: scenePoint.y - cam.position.y)
        if state == .monsterSelect || state == .citySelect || state == .timeSelect {
            for target in clickTargets where target.rect.contains(camPoint) {
                choose(index: target.index)
                return
            }
            return
        }
        if state == .gameOver {
            startGame()
            return
        }
        if state == .playing && !isPausedGame {
            // Click = smash toward the click side
            facing = scenePoint.x >= monster.position.x ? 1 : -1
            trySmash()
        }
    }

    private var howToCard: SKNode?

    /// The whole game on one card — toggled with H on the select
    /// screens and while paused.
    private func toggleHowTo() {
        if let card = howToCard {
            card.removeFromParent()
            howToCard = nil
            return
        }
        let gold = NSColor(calibratedRed: 1, green: 0.8, blue: 0.35, alpha: 1)
        let node = SKNode()
        node.zPosition = 120
        let panel = SKShapeNode(rectOf: CGSize(width: 1000, height: 640), cornerRadius: 18)
        panel.fillColor = NSColor(white: 0.06, alpha: 0.95)
        panel.strokeColor = gold
        panel.lineWidth = 2
        node.addChild(panel)
        node.addChild(makeLabel("HOW TO PLAY", size: 34, color: gold, pos: CGPoint(x: 0, y: 276)))
        let lines: [(String, Bool)] = [
            ("THE JOB", true),
            ("Mama insured Earth. Wreck cities, bank the claim money, crush the Golden Snitch before he informs the alien cops.", false),
            ("CONTROLS", true),
            ("Move ← → or A/D · Smash J or click · Stomp: jump, then ↓/S to slam down · Special E", false),
            ("Leave city Q/F — its clock and rubble freeze until you return · Pause P/Esc · Sound M · This card H", false),
            ("THE RULES THAT MATTER", true),
            ("One hour per city per season. Flattening a city pays its real value — Tokyo pays $14 TRILLION.", false),
            ("Nothing counts until you crush the Snitch: a crush locks (bank + run) × 10 as one leaderboard score.", false),
            ("Every day after the 1st costs 2% of the lock-in. Unclaimed banks evaporate when the month ends.", false),
            ("MALDO — striped, evil, wandering — doubles your points plus a $1 BILLION bounty. Back in 16 seconds.", false),
            ("Crowd liability: walker $10M · TikTok dancer $15M · influencer $25M · big guy $50M.", false),
            ("Combos: hits within 1.4s chain — every 10 hits raises the claim multiplier, up to ×5.", false),
            ("SELLOUT MENU (A on city select): real sponsors pay you bank points for watching their ads. 10 a day.", false),
        ]
        var y: CGFloat = 228
        for (text, isHeader) in lines {
            if isHeader {
                y -= 12
                node.addChild(makeLabel(text, size: 19, color: gold, pos: CGPoint(x: 0, y: y)))
                y -= 30
            } else {
                node.addChild(makeLabel(text, size: 15.5, bold: false, pos: CGPoint(x: 0, y: y)))
                y -= 27
            }
        }
        node.addChild(makeLabel("H — close", size: 14, bold: false, pos: CGPoint(x: 0, y: -292)))
        howToCard = node
        cam.addChild(node)
    }

    private func showPauseOverlay() {
        clearOverlay()
        let node = SKNode()
        node.zPosition = 100
        let dim = SKShapeNode(rectOf: size)
        dim.fillColor = NSColor(white: 0, alpha: 0.65)
        dim.strokeColor = .clear
        node.addChild(dim)
        node.addChild(makeLabel("PAUSED", size: 46, pos: CGPoint(x: 0, y: 60)))
        node.addChild(makeLabel("Press P or Esc to resume", size: 18, bold: false, pos: CGPoint(x: 0, y: 4)))
        let rules = [
            "Smash J · Stomp ↓/S from a jump · Special E · Leave city Q (clock freezes)",
            "Crush the Golden Snitch or nothing counts — a crush locks (bank + run) × 10",
            "Maldo doubles your points · combos raise claim pay up to ×5 · H for the full card",
            "M toggles all sound — Mama included"
        ]
        for (i, line) in rules.enumerated() {
            node.addChild(makeLabel(line, size: 15, bold: false, pos: CGPoint(x: 0, y: -44 - CGFloat(i) * 27)))
        }
        overlay = node
        cam.addChild(node)
    }


    // MARK: Game flow

    private func startGame() {
        clearOverlay()
        howToCard?.removeFromParent()
        howToCard = nil
        loadSnitchHunt()
        loadCityProgress()
        let prog = cityProgress[selectedCity.rawValue] ?? CityProgress()
        // A city whose hour is spent stays closed for the season.
        guard Scoring.cityBudgetSeconds - prog.elapsed > 0 else { showCitySelect(); return }
        elapsedBase = prog.elapsed
        sessionElapsed = 0
        autosaveTimer = 0
        huntBankAtEntry = huntBank
        foldedAtEntry = prog.damageFolded
        endReason = .leftCity
        snitchPresent = (snitchCity == selectedCity) && !prog.snitchCaught
        snitchGone = false
        snitchCaughtRun = false
        snitchDodges = 0
        crowdTarget = selectedCity.crowdDensity
        buildCity()
        buildMonster()
        if monster.parent == nil { world.addChild(monster) }
        buildMaldo()
        spawnMaldo()
        spawnCrowd()
        spawnTraffic()
        if snitchPresent { buildSnitchScene() }

        facing = 1
        monsterVelY = 0
        onGround = true
        walkCycle = 0
        attackCooldown = 0
        specialCooldown = 0
        isPausedGame = false
        keysPressed = []

        timeLeft = Scoring.cityBudgetSeconds - elapsedBase
        if prog.snitchCaught {
            snitchCaughtRun = true
            // Legacy saves (pre-snitchDay) store 0 — fall back to
            // today rather than recording a "DAY 0" catch at 0%.
            huntDaysAtCatch = prog.snitchDay > 0 ? prog.snitchDay : seasonDay
        }
        damageDollars = 0
        comboCount = 0
        comboLevel = 1
        comboTimer = 0
        activeEvent = nil
        eventTimer = 0
        eventNextIn = 35
        eventLabel.text = ""
        maldoKills = 0
        peopleSquashed = 0
        state = .playing
        cam.position = CGPoint(x: 640, y: 400)

        floatingText("\(selectedMonster.name) VS. \(selectedCity.name)", at: CGPoint(x: 420, y: 560),
                     color: NSColor(calibratedRed: 1, green: 0.6, blue: 0.3, alpha: 1), size: 34)
        floatingText("DESTROY EVERYTHING", at: CGPoint(x: 420, y: 510),
                     color: .white, size: 20)
        floatingText("☠ MALDO IS HIDING SOMEWHERE — DESTROY HIM TO DOUBLE YOUR POINTS ☠",
                     at: CGPoint(x: 420, y: 466),
                     color: NSColor(calibratedRed: 1, green: 0.35, blue: 0.4, alpha: 1), size: 16)
        if snitchPresent {
            floatingText("🚨 THE GOLDEN SNITCH IS SOMEWHERE IN THIS CITY — CRUSH HIM TO LOCK IN EVERYTHING ×10 🚨",
                         at: CGPoint(x: 420, y: 424),
                         color: NSColor(calibratedRed: 1, green: 0.8, blue: 0.2, alpha: 1), size: 17)
            mamaSays("HE'S IN THIS CITY, BABY. MAMA CAN FEEL IT. FIND HIM.")
        }
        // Arrival: a roar and a camera kick. The city should know she's here.
        shakeCamera(intensity: 12, duration: 0.45)
        playSFX("Basso")
        refreshHUD()
    }

    private func showResults() {
        state = .gameOver
        eventLabel.text = ""
        let pct = Scoring.percentDestroyed(destroyedValue: destroyedHP, totalValue: totalHP)
        let rank = Scoring.rank(percentDestroyed: pct)
        let bestKey = "kaiju.bestDamage"
        let previousBest = UserDefaults.standard.integer(forKey: bestKey)
        // THE GAME DOESN'T END UNTIL THE GOLDEN SNITCH IS CRUSHED.
        // A run without him just banks its points into the hunt —
        // saved, unlocked, still at risk of meaning nothing. A run
        // with the crush locks EVERYTHING in at ×10 (the whole bank
        // plus this run) as one leaderboard score, and a new hunt
        // begins somewhere else in the world.
        // bankBefore is the bank when this visit began — autosaves
        // during the visit already folded this visit's damage into
        // huntBank, so the visit's own total is counted exactly once.
        let bankBefore = huntBankAtEntry
        let lockGross = (bankBefore + damageDollars) * Scoring.snitchMultiplier
        // The penalty is fixed by the day he was CRUSHED
        // (huntDaysAtCatch — set at the catch and persisted across a
        // frozen visit), NOT the day this visit happens to end: the
        // city-select banner promises "CRUSH HIM TODAY: penalty −X%",
        // and a catch restored after midnight must not be
        // re-penalized for days he was already caught. (The
        // leaderboard entry below likewise records the catch day.)
        let catchPenalty = Scoring.snitchPenaltyPercent(dayOfMonth: huntDaysAtCatch)
        let lockedTotal = snitchCaughtRun ? Scoring.huntLockIn(bank: bankBefore, runDamage: damageDollars, dayOfMonth: huntDaysAtCatch) : 0
        if snitchCaughtRun {
            // Lock-in: the whole hunt pays out, the bank zeroes, the
            // completed flag clears, and a new Snitch hides.
            snapshotProgress(bank: 0, folded: foldedAtEntry)
            cityProgress[selectedCity.rawValue]?.snitchCaught = false
            saveCityProgress()
            startNewSnitchHunt()
        } else {
            snapshotProgress(bank: bankBefore + damageDollars, folded: foldedAtEntry + damageDollars)
        }
        let isBest = snitchCaughtRun && lockedTotal > previousBest
        if isBest { UserDefaults.standard.set(lockedTotal, forKey: bestKey) }

        // Local leaderboard (+ Game Center once enabled in App Store Connect)
        let entry = ScoreEntry(damage: snitchCaughtRun ? lockedTotal : damageDollars, percent: pct,
                               monster: selectedMonster.name, city: selectedCity.name,
                               mode: snitchCaughtRun ? "SNITCH · DAY \(huntDaysAtCatch)" : "CITY CLOCK", date: Date())
        let board = snitchCaughtRun ? Leaderboard.record(entry) : Leaderboard.load()
        let myRank = snitchCaughtRun ? Leaderboard.rank(of: entry, in: board) : nil

        clearOverlay()
        let node = SKNode()
        node.zPosition = 100
        let dim = SKShapeNode(rectOf: size)
        dim.fillColor = NSColor(white: 0, alpha: 0.78)
        dim.strokeColor = .clear
        node.addChild(dim)

        node.addChild(makeLabel(snitchCaughtRun ? "🏆 SNITCH CRUSHED — GAME COMPLETE 🏆" : (endReason == .clockSpent ? "⏱ \(selectedCity.name)'S HOUR IS UP ⏱" : "YOU LEFT \(selectedCity.name)"), size: 40,
                                color: NSColor(calibratedRed: 1, green: 0.55, blue: 0.3, alpha: 1),
                                pos: CGPoint(x: 0, y: 292)))
        node.addChild(makeLabel("RANK \(rank)", size: 56,
                                color: NSColor(calibratedRed: 1, green: 0.85, blue: 0.35, alpha: 1),
                                pos: CGPoint(x: 0, y: 226)))
        node.addChild(makeLabel(Scoring.verdict(rank: rank), size: 17, bold: false,
                                pos: CGPoint(x: 0, y: 178)))
        let lines = snitchCaughtRun ? [
            "This run:  \(Scoring.formatDollars(damageDollars))  ·  City destroyed:  \(pct)%",
            "Banked across the season:  \(Scoring.formatDollars(bankBefore))",
            "🏆 ×10 = \(Scoring.formatDollars(lockGross))  →  LOCKED IN:  \(Scoring.formatDollars(lockedTotal))  (season penalty −\(catchPenalty)%, caught day \(huntDaysAtCatch))",
            "Buildings toppled:  \(buildingsToppled) of \(buildings.count) · Props smashed:  \(propsSmashed) · Crowd squashed:  \(peopleSquashed)",
            isBest ? "★ NEW BEST LOCKED SCORE ★" : "Best locked score:  \(Scoring.formatDollars(previousBest))"
        ] : [
            "Total damage:  \(Scoring.formatDollars(damageDollars))",
            "Buildings toppled:  \(buildingsToppled) of \(buildings.count) · Props smashed:  \(propsSmashed) · Crowd squashed:  \(peopleSquashed)",
            "City destroyed:  \(pct)%",
            "🏦 BANKED:  \(Scoring.formatDollars(huntBank)) — find him this month or it evaporates on the 1st  ·  ⏱ \(selectedCity.name) frozen at \(clockText(timeLeft)) left",
            "Best locked score:  \(Scoring.formatDollars(previousBest))"
        ]
        for (i, line) in lines.enumerated() {
            node.addChild(makeLabel(line, size: 18.5, bold: false,
                                    pos: CGPoint(x: 0, y: 148 - CGFloat(i) * 30)))
        }
        let boardDrop: CGFloat = (maldoKills > 0 ? 24 : 0) + 24
        if snitchCaughtRun {
            node.addChild(makeLabel("🏆 GOLDEN SNITCH FOUND ON DAY \(huntDaysAtCatch) OF THE SEASON — \(Scoring.formatDollars(lockedTotal)) ON THE LEADERBOARD. A NEW SNITCH HIDES 🏆", size: 15,
                                    color: NSColor(calibratedRed: 1, green: 0.8, blue: 0.25, alpha: 1),
                                    pos: CGPoint(x: 0, y: 4)))
        } else {
            node.addChild(makeLabel("🚨 NOT LOCKED IN — DAY \(seasonDay) OF \(daysInSeason) · \(daysInSeason - seasonDay + 1) DAYS LEFT THIS SEASON · SNITCH PENALTY −\(seasonPenalty)% AND GROWING", size: 14.5,
                                    color: NSColor(calibratedRed: 1, green: 0.55, blue: 0.35, alpha: 1),
                                    pos: CGPoint(x: 0, y: 4)))
        }
        if maldoKills > 0 {
            node.addChild(makeLabel("☠ MALDO DESTROYED ×\(maldoKills) — POINTS DOUBLED! ☠", size: 16,
                                    color: NSColor(calibratedRed: 1, green: 0.4, blue: 0.45, alpha: 1),
                                    pos: CGPoint(x: 0, y: -20)))
        }
        // Leaderboard (top 5)
        node.addChild(makeLabel("— LEADERBOARD —", size: 16,
                                color: NSColor(calibratedRed: 1, green: 0.8, blue: 0.4, alpha: 1),
                                pos: CGPoint(x: 0, y: -12 - boardDrop)))
        for (i, e) in board.prefix(5).enumerated() {
            let isMe = e == entry
            let prefix = isMe ? "▶" : "\(i + 1)."
            node.addChild(makeLabel("\(prefix) \(Scoring.formatDollars(e.damage)) — \(e.monster) in \(e.city)",
                                    size: 15.5, bold: isMe,
                                    color: isMe ? NSColor(calibratedRed: 0.55, green: 0.95, blue: 0.55, alpha: 1) : NSColor(white: 1, alpha: 0.9),
                                    pos: CGPoint(x: 0, y: -46 - CGFloat(i) * 27 - boardDrop)))
        }
        if let myRank = myRank, myRank > 5 {
            node.addChild(makeLabel("You placed #\(myRank) on the leaderboard", size: 14, bold: false,
                                    color: NSColor(white: 1, alpha: 0.8), pos: CGPoint(x: 0, y: -190 - boardDrop)))
        }
        let prompt = makeLabel("R — back into this city      ENTER — new fighter / city", size: 18,
                               color: NSColor(calibratedRed: 0.55, green: 0.95, blue: 0.55, alpha: 1),
                               pos: CGPoint(x: 0, y: -248))
        node.addChild(prompt)
        prompt.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.35, duration: 0.6), .fadeAlpha(to: 1, duration: 0.6)
        ])))
        overlay = node
        cam.addChild(node)
        refreshHUD()
    }
    // MARK: Combat

    private func attackZone() -> (minX: CGFloat, maxX: CGFloat) {
        let reach: CGFloat = 175
        return facing > 0
            ? (monster.position.x + 10, monster.position.x + reach)
            : (monster.position.x - reach, monster.position.x - 10)
    }

    private func trySmash() {
        guard attackCooldown <= 0 else { return }
        attackCooldown = selectedMonster.attackInterval
        animateSmash()
        let zone = attackZone()
        var hitSomething = false

        // Nearest standing building overlapping the zone
        var target: Building?
        var bestDist = CGFloat.greatestFiniteMagnitude
        for b in buildings where !b.destroyed {
            if b.right >= zone.minX && b.left <= zone.maxX {
                let d = abs(b.centerX - monster.position.x)
                if d < bestDist { bestDist = d; target = b }
            }
        }
        if let target = target {
            damageBuilding(target, power: selectedMonster.power, isSpecial: false)
            hitSomething = true
        }
        // Props in zone
        for prop in props where !prop.destroyed {
            if prop.x >= zone.minX - 20 && prop.x <= zone.maxX + 20 {
                smashProp(prop)
                hitSomething = true
            }
        }
        checkMaldoHit(minX: zone.minX - 20, maxX: zone.maxX + 20)
        checkPedsHit(minX: zone.minX - 20, maxX: zone.maxX + 20)
        checkCarsHit(minX: zone.minX - 20, maxX: zone.maxX + 20)
        checkSnitchHit(minX: zone.minX - 20, maxX: zone.maxX + 20)
        if !hitSomething { playSFX("Tink") }
    }

    private func tryStomp() {
        guard attackCooldown <= 0 else { return }
        attackCooldown = 0.62
        shakeCamera(intensity: 7, duration: 0.22)
        playSFX("Basso")
        // Ground ring visual
        let ring = SKShapeNode(circleOfRadius: 30)
        ring.position = CGPoint(x: monster.position.x, y: groundY + 6)
        ring.strokeColor = nsColor(selectedMonster.accentColor)
        ring.lineWidth = 4
        ring.fillColor = .clear
        ring.zPosition = 30
        effects.addChild(ring)
        ring.run(.sequence([
            .group([.scale(to: 4.2, duration: 0.28), .fadeOut(withDuration: 0.28)]),
            .removeFromParent()
        ]))
        for b in buildings where !b.destroyed {
            if abs(b.centerX - monster.position.x) <= b.width / 2 + 120 {
                damageBuilding(b, power: selectedMonster.power, isSpecial: false)
            }
        }
        for prop in props where !prop.destroyed && abs(prop.x - monster.position.x) <= 140 {
            smashProp(prop)
        }
        checkMaldoHit(minX: monster.position.x - 140, maxX: monster.position.x + 140)
        checkPedsHit(minX: monster.position.x - 140, maxX: monster.position.x + 140)
        checkCarsHit(minX: monster.position.x - 140, maxX: monster.position.x + 140)
        checkSnitchHit(minX: monster.position.x - 140, maxX: monster.position.x + 140)
    }

    private func trySpecial() {
        guard specialCooldown <= 0, attackCooldown <= 0 else { return }
        specialCooldown = 6
        attackCooldown = 0.45
        animateSmash()
        shakeCamera(intensity: 11, duration: 0.35)
        playSFX("Glass")

        // Element blast ring in the monster's accent color
        let ring = SKShapeNode(circleOfRadius: 40)
        ring.position = CGPoint(x: monster.position.x, y: groundY + 110)
        ring.strokeColor = nsColor(selectedMonster.accentColor)
        ring.lineWidth = 8
        ring.fillColor = nsColor(selectedMonster.accentColor, alpha: 0.25)
        ring.zPosition = 29
        effects.addChild(ring)
        ring.run(.sequence([
            .group([.scale(to: 6.5, duration: 0.4), .fadeOut(withDuration: 0.4)]),
            .removeFromParent()
        ]))
        floatingText(selectedMonster.specialName.uppercased() + "!",
                     at: CGPoint(x: monster.position.x, y: groundY + 300),
                     color: nsColor(selectedMonster.accentColor), size: 26)

        for b in buildings where !b.destroyed {
            if abs(b.centerX - monster.position.x) <= b.width / 2 + 240 {
                damageBuilding(b, power: selectedMonster.power * Scoring.specialMultiplier, isSpecial: true)
            }
        }
        for prop in props where !prop.destroyed && abs(prop.x - monster.position.x) <= 260 {
            smashProp(prop)
        }
        checkMaldoHit(minX: monster.position.x - 260, maxX: monster.position.x + 260)
        checkPedsHit(minX: monster.position.x - 260, maxX: monster.position.x + 260)
        checkCarsHit(minX: monster.position.x - 260, maxX: monster.position.x + 260)
        checkSnitchHit(minX: monster.position.x - 260, maxX: monster.position.x + 260)
    }

    private func animateSmash() {
        monsterArm.removeAllActions()
        monsterArm.run(.sequence([
            .rotate(toAngle: -1.9, duration: 0.07),
            .rotate(toAngle: 0.55, duration: 0.10),
            .rotate(toAngle: 0, duration: 0.12)
        ]))
        // Lunge: the whole body throws its weight toward the facing.
        monsterBodyGroup.removeAction(forKey: "lunge")
        monsterBodyGroup.run(.sequence([
            .moveBy(x: facing * 15, y: 0, duration: 0.07),
            .moveBy(x: -facing * 15, y: 0, duration: 0.14)
        ]), withKey: "lunge")
    }

    /// Mid-run events: 15 seconds of a random flavor of chaos.
    private func startEvent() {
        guard let ev = Scoring.CityEvent.allCases.randomElement() else { return }
        activeEvent = ev
        eventTimer = Scoring.eventDurationSeconds
        switch ev {
        case .rushHour:
            for _ in 0..<Scoring.rushHourExtraPeds { spawnOnePed() }
            announceEvent("🚨 RUSH HOUR! Packed streets — every squash pays DOUBLE!")
        case .maldoMania:
            announceEvent("🎩 MALDO MANIA! He respawns in 4 seconds flat!")
        case .demolitionDerby:
            announceEvent("💥 DEMOLITION DERBY! Collapse claims pay DOUBLE!")
        }
        playSFX("Glass")
        refreshHUD()
    }

    private func announceEvent(_ text: String) {
        let label = makeLabel(text, size: 29,
                              color: NSColor(calibratedRed: 1, green: 0.8, blue: 0.35, alpha: 1),
                              pos: CGPoint(x: 0, y: 205))
        label.zPosition = 96
        cam.addChild(label)
        label.run(.sequence([
            .group([.scale(to: 1.05, duration: 2.8), .fadeOut(withDuration: 2.8)]),
            .removeFromParent()
        ]))
    }

    /// Chain a hit and return its claim dollars at the current
    /// combo multiplier. Milestones announce themselves.
    private func comboAward(_ base: Int) -> Int {
        comboCount += 1
        comboTimer = Scoring.comboWindowSeconds
        let lvl = Scoring.comboMultiplier(combo: comboCount)
        if lvl > comboLevel {
            comboLevel = lvl
            floatingText("🔥 COMBO ×\(lvl)!",
                         at: CGPoint(x: monster.position.x, y: groundY + 340),
                         color: NSColor(calibratedRed: 1, green: 0.6, blue: 0.25, alpha: 1), size: 30)
            playSFX("Glass")
        }
        return Scoring.comboClaim(base: base, combo: comboCount)
    }

    /// One jagged crack decal: three deterministic branches down
    /// the facade (index-hashed, so every building cracks its own
    /// way and the seeded city RNG is untouched).
    private func makeCrack(seed: Int, width: CGFloat, height: CGFloat) -> SKNode {
        let node = SKNode()
        let spread = max(0.45, min(1, width / 150))
        for branch in 0..<3 {
            let path = CGMutablePath()
            var x = (CGFloat((seed * 29 + branch * 41) % 60) - 30) * spread
            var y = height * (0.78 - CGFloat(branch) * 0.20)
            path.move(to: CGPoint(x: x, y: y))
            for step in 0..<4 {
                x += CGFloat(((seed + branch * 7 + step * 11) % 13) - 6) * 2.2 * spread
                y -= height * 0.11
                path.addLine(to: CGPoint(x: x, y: y))
            }
            let line = SKShapeNode(path: path)
            line.strokeColor = NSColor(white: 0.05, alpha: 0.55)
            line.lineWidth = 2
            line.fillColor = .clear
            node.addChild(line)
        }
        node.zPosition = 3
        return node
    }

    private func updateCracks(_ building: Building) {
        let frac = building.hpFraction
        building.group.childNode(withName: "crack1")?.alpha = frac < 0.66 ? 1 : 0
        building.group.childNode(withName: "crack2")?.alpha = frac < 0.33 ? 1 : 0
    }

    /// Soft dust burst when a building comes down.
    private func dustCloud(at pos: CGPoint) {
        for _ in 0..<10 {
            let puff = SKShapeNode(circleOfRadius: CGFloat.random(in: 14...30))
            puff.fillColor = NSColor(white: 0.72, alpha: 0.35)
            puff.strokeColor = .clear
            puff.position = CGPoint(x: pos.x + CGFloat.random(in: -70...70),
                                    y: pos.y + CGFloat.random(in: -6...26))
            puff.zPosition = 48
            effects.addChild(puff)
            puff.run(.sequence([
                .group([.scale(to: CGFloat.random(in: 1.8...2.6), duration: 0.9),
                        .moveBy(x: CGFloat.random(in: -24...24), y: 26, duration: 0.9),
                        .fadeOut(withDuration: 0.9)]),
                .removeFromParent()
            ]))
        }
    }

    private func damageBuilding(_ building: Building, power: Int, isSpecial: Bool) {
        guard !building.destroyed else { return }
        let dealt = min(power, building.hp)
        building.hp -= dealt
        destroyedHP += dealt
        // `dealt` already includes the special multiplier in HP terms
        // (trySpecial passes doubled power). Dollars = HP × the
        // city's claim rate, two-thirds paid as damage lands.
        let awarded = comboAward(Scoring.hitClaimDollars(hpDealt: dealt, rate: claimRate))
        damageDollars += awarded

        // Damage tint + HP bar
        let frac = building.hpFraction
        building.body.fillColor = building.baseColor.blended(
            withFraction: CGFloat(1 - frac) * 0.55, of: .black) ?? building.baseColor
        if let hpBG = building.group.childNode(withName: "hpBG"),
           let hpFill = building.group.childNode(withName: "hpFill") as? SKShapeNode {
            hpBG.alpha = 1
            hpFill.alpha = 1
            hpFill.xScale = CGFloat(max(0, frac))
            hpFill.fillColor = frac > 0.4
                ? NSColor(calibratedRed: 0.5, green: 0.95, blue: 0.45, alpha: 1)
                : NSColor(calibratedRed: 1, green: 0.4, blue: 0.35, alpha: 1)
        }

        // Shake + debris at a random height facing the monster
        building.group.removeAction(forKey: "shake")
        let shake = SKAction.sequence([
            .moveBy(x: 5, y: 0, duration: 0.03), .moveBy(x: -10, y: 0, duration: 0.05),
            .moveBy(x: 5, y: 0, duration: 0.03)
        ])
        building.group.run(shake, withKey: "shake")
        debris(at: CGPoint(x: monster.position.x + facing * 90,
                           y: groundY + CGFloat.random(in: 30...min(building.height, 240))))
        playSFX("Pop")
        updateCracks(building)
        floatingText("+\(Scoring.formatDollars(awarded))",
                     at: CGPoint(x: monster.position.x + facing * 95,
                                 y: groundY + CGFloat.random(in: 130...250)),
                     color: NSColor(calibratedRed: 1, green: 0.9, blue: 0.5, alpha: 1), size: 14)

        if building.hp <= 0 {
            collapse(building)
        }
        refreshHUD()
    }

    private func collapse(_ building: Building) {
        building.destroyed = true
        buildingsToppled += 1
        let claim = Scoring.collapseClaimDollars(maxHP: building.maxHP, rate: claimRate)
        let bonus = comboAward(activeEvent == .demolitionDerby ? claim * 2 : claim)
            + (building.isLandmark ? Scoring.landmarkSurcharge(cityValue: selectedCity.destructionValue) : 0)
        damageDollars += bonus
        floatingText(building.isLandmark ? "LANDMARK DOWN! +\(Scoring.formatDollars(bonus))"
                                         : "+\(Scoring.formatDollars(bonus))",
                     at: CGPoint(x: building.centerX, y: groundY + building.height + 60),
                     color: NSColor(calibratedRed: 1, green: 0.85, blue: 0.35, alpha: 1), size: 24)
        debris(at: CGPoint(x: building.centerX, y: groundY + 90), count: 34, big: true)
        dustCloud(at: CGPoint(x: building.centerX, y: groundY + 12))
        shakeCamera(intensity: building.isLandmark ? 14 : 9, duration: 0.4)
        playSFX("Basso")

        building.group.childNode(withName: "hpBG")?.alpha = 0
        building.group.childNode(withName: "hpFill")?.alpha = 0
        // The building crumples down into rubble.
        building.group.run(.sequence([
            .group([
                .scaleY(to: 0.10, duration: 0.55),
                .moveBy(x: 0, y: 0, duration: 0.55)
            ])
        ]))
        // Anchor the collapse at the base: y-scale around the group origin (the base),
        // which is exactly where the group sits — children shrink toward the street.
    }

    private func smashProp(_ prop: Prop) {
        guard !prop.destroyed else { return }
        prop.destroyed = true
        propsSmashed += 1
        destroyedHP += 20
        damageDollars += comboAward(Scoring.propClaimDollars(rate: claimRate))
        debris(at: CGPoint(x: prop.x, y: groundY + 24), count: 8)
        prop.node.run(.sequence([
            .group([.scale(to: 0.2, duration: 0.18), .fadeOut(withDuration: 0.18)]),
            .removeFromParent()
        ]))
    }

    // MARK: Maldo — evil Waldo parody. Same clothes. Wrong intentions.
    // He wanders a random stretch of the city. Find him, destroy him,
    // and your points DOUBLE (plus a bounty). Then he comes back…

    private func buildMaldo() {
        maldo.removeAllChildren()
        maldoLegL.removeAllChildren()
        maldoLegR.removeAllChildren()
        maldo.zPosition = 8
        maldo.zRotation = 0
        let red = NSColor(calibratedRed: 0.85, green: 0.12, blue: 0.16, alpha: 1)
        let cream = NSColor(calibratedRed: 0.96, green: 0.95, blue: 0.92, alpha: 1)
        let skin = NSColor(calibratedRed: 0.88, green: 0.79, blue: 0.68, alpha: 1)
        let jeans = NSColor(calibratedRed: 0.16, green: 0.25, blue: 0.55, alpha: 1)

        // Pulsing dark aura — this is NOT the friendly one
        let aura = SKShapeNode(circleOfRadius: 30)
        aura.position = CGPoint(x: 0, y: 30)
        aura.fillColor = NSColor(calibratedRed: 0.45, green: 0.0, blue: 0.05, alpha: 0.28)
        aura.strokeColor = .clear
        aura.zPosition = -1
        maldo.addChild(aura)
        aura.run(.repeatForever(.sequence([
            .scale(to: 1.18, duration: 0.8), .scale(to: 1.0, duration: 0.8)
        ])))

        // Legs pivot at the hip so they swing while he strolls
        for (leg, dx) in [(maldoLegL, CGFloat(-5)), (maldoLegR, CGFloat(5))] {
            leg.position = CGPoint(x: dx, y: 16)
            leg.zRotation = 0
            let pant = SKShapeNode(rectOf: CGSize(width: 7, height: 13), cornerRadius: 2)
            pant.position = CGPoint(x: 0, y: -6)
            pant.fillColor = jeans
            pant.strokeColor = .clear
            leg.addChild(pant)
            let shoe = SKShapeNode(rectOf: CGSize(width: 9.5, height: 4), cornerRadius: 1.5)
            shoe.position = CGPoint(x: 1.5, y: -13.5)
            shoe.fillColor = NSColor(calibratedRed: 0.25, green: 0.16, blue: 0.10, alpha: 1)
            shoe.strokeColor = .clear
            leg.addChild(shoe)
            maldo.addChild(leg)
        }

        // The famous stripes — red and white, five bands
        for i in 0..<5 {
            let stripe = SKShapeNode(rectOf: CGSize(width: 21, height: 4.6))
            stripe.position = CGPoint(x: 0, y: 20.3 + CGFloat(i) * 4.6)
            stripe.fillColor = i % 2 == 0 ? red : cream
            stripe.strokeColor = NSColor(white: 0, alpha: 0.15)
            stripe.lineWidth = 0.5
            maldo.addChild(stripe)
        }
        // Arms in matching stripes, angled like he's up to something
        for side in [-1, 1] as [CGFloat] {
            let arm = SKShapeNode(rectOf: CGSize(width: 5.5, height: 16), cornerRadius: 2.5)
            arm.position = CGPoint(x: side * 13.5, y: 29)
            arm.zRotation = side * -0.3
            arm.fillColor = side < 0 ? red : cream
            arm.strokeColor = .clear
            maldo.addChild(arm)
            let hand = SKShapeNode(circleOfRadius: 3)
            hand.position = CGPoint(x: side * 16, y: 21.5)
            hand.fillColor = skin
            hand.strokeColor = .clear
            maldo.addChild(hand)
        }

        // Head — pale, grinning, wrong
        let head = SKShapeNode(circleOfRadius: 9.5)
        head.position = CGPoint(x: 0, y: 47)
        head.fillColor = skin
        head.strokeColor = NSColor(white: 0, alpha: 0.25)
        head.lineWidth = 1
        maldo.addChild(head)

        // Bobble hat: white dome, red band, red pompom — same as the original
        let dome = SKShapeNode(circleOfRadius: 8.2)
        dome.position = CGPoint(x: 0, y: 54.5)
        dome.fillColor = cream
        dome.strokeColor = .clear
        maldo.addChild(dome)
        let band = SKShapeNode(rectOf: CGSize(width: 18.5, height: 3.4))
        band.position = CGPoint(x: 0, y: 52.6)
        band.fillColor = red
        band.strokeColor = .clear
        maldo.addChild(band)
        let pom = SKShapeNode(circleOfRadius: 4)
        pom.position = CGPoint(x: 0, y: 62.5)
        pom.fillColor = red
        pom.strokeColor = .clear
        maldo.addChild(pom)

        // Round glasses…
        for dx in [-4.6, 4.6] as [CGFloat] {
            let lens = SKShapeNode(circleOfRadius: 4.3)
            lens.position = CGPoint(x: dx, y: 47)
            lens.fillColor = NSColor(white: 1, alpha: 0.10)
            lens.strokeColor = NSColor(white: 0.05, alpha: 1)
            lens.lineWidth = 1.6
            maldo.addChild(lens)
            // …with glowing red eyes behind them
            let eye = SKShapeNode(circleOfRadius: 1.9)
            eye.position = CGPoint(x: dx, y: 47)
            eye.fillColor = NSColor(calibratedRed: 1, green: 0.15, blue: 0.1, alpha: 1)
            eye.strokeColor = .clear
            maldo.addChild(eye)
        }
        // Angry brows, slanted down toward the middle
        for (dx, rot) in [(-4.6, CGFloat(-0.45)), (4.6, CGFloat(0.45))] {
            let brow = SKShapeNode(rectOf: CGSize(width: 6.5, height: 1.7))
            brow.position = CGPoint(x: dx, y: 50.8)
            brow.zRotation = rot
            brow.fillColor = NSColor(white: 0.08, alpha: 1)
            brow.strokeColor = .clear
            maldo.addChild(brow)
        }
        // Fanged grin — zigzag teeth over a black mouth
        let mouth = SKShapeNode(rectOf: CGSize(width: 10, height: 3.6), cornerRadius: 1.6)
        mouth.position = CGPoint(x: 0, y: 41.6)
        mouth.fillColor = NSColor(white: 0.04, alpha: 1)
        mouth.strokeColor = .clear
        maldo.addChild(mouth)
        let teeth = CGMutablePath()
        teeth.move(to: CGPoint(x: -4.5, y: 43.3))
        for k in 0..<4 {
            teeth.addLine(to: CGPoint(x: -4.5 + CGFloat(k) * 2.25 + 1.125, y: 41.2))
            teeth.addLine(to: CGPoint(x: -4.5 + CGFloat(k + 1) * 2.25, y: 43.3))
        }
        teeth.closeSubpath()
        let teethNode = SKShapeNode(path: teeth)
        teethNode.fillColor = .white
        teethNode.strokeColor = .clear
        maldo.addChild(teethNode)
    }

    private func spawnMaldo() {
        if maldo.parent == nil { world.addChild(maldo) }
        maldoHome = CGFloat.random(in: 420...(worldWidth - 420))
        maldoX = maldoHome
        maldoDir = Bool.random() ? 1 : -1
        maldo.position = CGPoint(x: maldoX, y: groundY)
        maldo.zRotation = 0
        maldo.alpha = 1
        maldo.xScale = maldoDir * 0.92
        maldo.yScale = 0.92
        maldoAlive = true
    }

    private func checkMaldoHit(minX: CGFloat, maxX: CGFloat) {
        if maldoAlive && maldoX >= minX && maldoX <= maxX {
            destroyMaldo()
        }
    }

    private func destroyMaldo() {
        guard maldoAlive else { return }
        maldoAlive = false
        maldoKills += 1
        let reward = Scoring.maldoReward(currentDamage: damageDollars)
        damageDollars += reward
        maldoRespawn = activeEvent == .maldoMania ? Scoring.maldoManiaRespawnSeconds : 16
        debris(at: CGPoint(x: maldoX, y: groundY + 28), count: 18, big: true)
        floatingText("☠ MALDO DESTROYED! ☠",
                     at: CGPoint(x: maldoX, y: groundY + 155),
                     color: NSColor(calibratedRed: 1, green: 0.25, blue: 0.3, alpha: 1), size: 30)
        floatingText("POINTS DOUBLED! +\(Scoring.formatDollars(reward))",
                     at: CGPoint(x: maldoX, y: groundY + 116),
                     color: NSColor(calibratedRed: 1, green: 0.85, blue: 0.35, alpha: 1), size: 22)
        shakeCamera(intensity: 9, duration: 0.3)
        playSFX("Sosumi")
        maldo.run(.sequence([
            .group([.scale(to: 0.1, duration: 0.25),
                    .fadeOut(withDuration: 0.25),
                    .rotate(byAngle: 2.6, duration: 0.25)]),
            .removeFromParent()
        ]))
        refreshHUD()
    }

    // MARK: The Crowd — strollers, TikTok dancers, influencers.
    // Plenty of people walking around, all of them squashable.

    private func buildPedestrian(kind: Pedestrian.Kind, x: CGFloat) -> Pedestrian {
        let dir: CGFloat = Bool.random() ? 1 : -1
        let speed: CGFloat = kind == .big ? CGFloat.random(in: 15...23)
            : kind == .influencer ? CGFloat.random(in: 10...17)
            : CGFloat.random(in: 22...38)
        let ped = Pedestrian(kind: kind, x: x, dir: dir, baseSpeed: speed)
        ped.node.position = CGPoint(x: x, y: groundY)
        ped.node.zPosition = 7

        let skins = [
            NSColor(calibratedRed: 0.98, green: 0.80, blue: 0.66, alpha: 1),
            NSColor(calibratedRed: 0.85, green: 0.62, blue: 0.45, alpha: 1),
            NSColor(calibratedRed: 0.65, green: 0.45, blue: 0.30, alpha: 1),
            NSColor(calibratedRed: 0.45, green: 0.32, blue: 0.22, alpha: 1)
        ]
        let shirts = [
            NSColor(calibratedRed: 0.95, green: 0.30, blue: 0.45, alpha: 1),
            NSColor(calibratedRed: 0.25, green: 0.75, blue: 0.90, alpha: 1),
            NSColor(calibratedRed: 0.98, green: 0.80, blue: 0.25, alpha: 1),
            NSColor(calibratedRed: 0.55, green: 0.90, blue: 0.45, alpha: 1),
            NSColor(calibratedRed: 0.70, green: 0.50, blue: 0.95, alpha: 1),
            NSColor(calibratedRed: 0.95, green: 0.55, blue: 0.25, alpha: 1),
            NSColor(calibratedRed: 0.92, green: 0.92, blue: 0.95, alpha: 1)
        ]
        let hairColors = [
            NSColor(calibratedRed: 0.15, green: 0.10, blue: 0.08, alpha: 1),
            NSColor(calibratedRed: 0.45, green: 0.28, blue: 0.12, alpha: 1),
            NSColor(calibratedRed: 0.85, green: 0.68, blue: 0.35, alpha: 1),
            NSColor(calibratedRed: 0.60, green: 0.15, blue: 0.15, alpha: 1)
        ]
        // This city's actual people: skin tones and clothes weighted
        // to its real-world demographics (CitySpec.crowdSkin / Clothes)
        let skin = selectedCity.crowdSkin.isEmpty ? skins.randomElement()!
            : nsColor(selectedCity.crowdSkin.randomElement()!)
        let shirt = kind == .dancer
            ? NSColor(calibratedRed: 0.98, green: 0.25, blue: 0.65, alpha: 1)
            : (selectedCity.crowdClothes.isEmpty ? shirts.randomElement()!
                : nsColor(selectedCity.crowdClothes.randomElement()!))
        let pantsC = NSColor(calibratedRed: CGFloat.random(in: 0.15...0.4),
                             green: CGFloat.random(in: 0.15...0.35),
                             blue: CGFloat.random(in: 0.25...0.55), alpha: 1)
        let big = kind == .big
        let torsoW: CGFloat = big ? 31 : 17
        let legDX: CGFloat = big ? 8 : 4.5
        let legW: CGFloat = big ? 9.5 : 6

        // Legs pivot at the hip
        for (leg, dx) in [(ped.legL, -legDX), (ped.legR, legDX)] {
            leg.position = CGPoint(x: dx, y: 15)
            let pant = SKShapeNode(rectOf: CGSize(width: legW, height: 12), cornerRadius: 2)
            pant.position = CGPoint(x: 0, y: -5.5)
            pant.fillColor = pantsC
            pant.strokeColor = .clear
            leg.addChild(pant)
            let shoe = SKShapeNode(rectOf: CGSize(width: legW + 2.5, height: 3.6), cornerRadius: 1.5)
            shoe.position = CGPoint(x: 1, y: -12)
            shoe.fillColor = NSColor(white: 0.12, alpha: 1)
            shoe.strokeColor = .clear
            leg.addChild(shoe)
            ped.node.addChild(leg)
        }

        // Body group (bounces for dancers)
        ped.node.addChild(ped.bodyG)
        let torso = SKShapeNode(rectOf: CGSize(width: torsoW, height: 23), cornerRadius: 5)
        torso.position = CGPoint(x: 0, y: 26.5)
        torso.fillColor = shirt
        torso.strokeColor = NSColor(white: 0, alpha: 0.2)
        torso.lineWidth = 1
        ped.bodyG.addChild(torso)
        if big {
            let belly = SKShapeNode(circleOfRadius: 12.5)
            belly.position = CGPoint(x: 0, y: 23)
            belly.fillColor = shirt
            belly.strokeColor = .clear
            ped.bodyG.addChild(belly)
        }
        // Head with a hair cap
        let hair = SKShapeNode(circleOfRadius: big ? 8 : 7.2)
        hair.position = CGPoint(x: 0, y: big ? 48.5 : 47.5)
        hair.fillColor = hairColors.randomElement()!
        hair.strokeColor = .clear
        ped.bodyG.addChild(hair)
        let head = SKShapeNode(circleOfRadius: big ? 8.5 : 7.5)
        head.position = CGPoint(x: 0, y: big ? 45.5 : 44.5)
        head.fillColor = skin
        head.strokeColor = .clear
        ped.bodyG.addChild(head)

        // Arms pivot at the shoulder
        for (arm, dx) in [(ped.armL, -(torsoW / 2 + 2)), (ped.armR, torsoW / 2 + 2)] {
            arm.position = CGPoint(x: dx, y: 36)
            let sleeve = SKShapeNode(rectOf: CGSize(width: 4.5, height: 14), cornerRadius: 2)
            sleeve.position = CGPoint(x: 0, y: -6)
            sleeve.fillColor = shirt
            sleeve.strokeColor = .clear
            arm.addChild(sleeve)
            let hand = SKShapeNode(circleOfRadius: 2.6)
            hand.position = CGPoint(x: 0, y: -13.5)
            hand.fillColor = skin
            hand.strokeColor = .clear
            arm.addChild(hand)
            ped.bodyG.addChild(arm)
        }

        if kind == .dancer {
            // Arms up, mid-routine — and their phone on a tripod, filming
            ped.armL.zRotation = 2.5
            ped.armR.zRotation = -2.5
            let tripod = SKNode()
            tripod.position = CGPoint(x: 27, y: 0)
            for rot in [-0.3, 0.3] as [CGFloat] {
                let stick = SKShapeNode(rectOf: CGSize(width: 1.8, height: 17))
                stick.position = CGPoint(x: 0, y: 8)
                stick.zRotation = rot
                stick.fillColor = NSColor(white: 0.2, alpha: 1)
                stick.strokeColor = .clear
                tripod.addChild(stick)
            }
            let phone = SKShapeNode(rectOf: CGSize(width: 5.5, height: 10), cornerRadius: 1.5)
            phone.position = CGPoint(x: 0, y: 24)
            phone.fillColor = NSColor(white: 0.08, alpha: 1)
            phone.strokeColor = .clear
            tripod.addChild(phone)
            let rec = SKShapeNode(circleOfRadius: 1.3)
            rec.position = CGPoint(x: 0, y: 27)
            rec.fillColor = NSColor(calibratedRed: 1, green: 0.2, blue: 0.2, alpha: 1)
            rec.strokeColor = .clear
            tripod.addChild(rec)
            ped.node.addChild(tripod)
        }

        if kind == .influencer {
            // Arm up, phone out, ring light glowing — content must be made
            ped.armR.zRotation = -2.25
            let phone = SKShapeNode(rectOf: CGSize(width: 5.5, height: 10), cornerRadius: 1.5)
            phone.position = CGPoint(x: 1, y: -17)
            phone.fillColor = NSColor(white: 0.08, alpha: 1)
            phone.strokeColor = .clear
            ped.armR.addChild(phone)
            let screen = SKShapeNode(rectOf: CGSize(width: 4, height: 7.5))
            screen.position = CGPoint(x: 1, y: -17)
            screen.fillColor = NSColor(calibratedRed: 0.85, green: 0.93, blue: 1, alpha: 1)
            screen.strokeColor = .clear
            ped.armR.addChild(screen)
            let ring = SKShapeNode(circleOfRadius: 9)
            ring.position = CGPoint(x: 19, y: 42)
            ring.fillColor = .clear
            ring.strokeColor = NSColor(calibratedRed: 1, green: 0.98, blue: 0.9, alpha: 0.95)
            ring.lineWidth = 2.2
            ped.bodyG.addChild(ring)
        }
        return ped
    }

    // MARK: The Golden Snitch — and the one officer he's talking to

    /// Somewhere out in the city: the Golden Snitch, just standing
    /// there on some street talking to one police officer, like he
    /// hasn't got a care in the world. Gold bandana, shades, gold
    /// chain, gold teeth, baggy khakis — and little golden wings.
    /// His spot in the city is re-rolled every run: you have to patrol
    /// the whole street to find him.
    private func buildSnitchScene() {
        let spotX = CGFloat.random(in: 420...(worldWidth - 420))
        let gold = NSColor(calibratedRed: 1, green: 0.78, blue: 0.2, alpha: 1)
        let skin = NSColor(calibratedRed: 0.72, green: 0.52, blue: 0.38, alpha: 1)
        let khaki = NSColor(calibratedRed: 0.76, green: 0.70, blue: 0.55, alpha: 1)

        // ——— THE SNITCH ———
        snitch.removeAllChildren()
        snitch.removeFromParent()

        // Little wings (on his back, behind everything). They flap.
        let wingPath = CGMutablePath()
        wingPath.move(to: CGPoint(x: 0, y: 0))
        wingPath.addQuadCurve(to: CGPoint(x: -27, y: 11), control: CGPoint(x: -17, y: 15))
        wingPath.addQuadCurve(to: CGPoint(x: 0, y: -5), control: CGPoint(x: -15, y: -4))
        wingPath.closeSubpath()
        snitchWingA = SKNode()
        snitchWingA.position = CGPoint(x: -6, y: 56)
        let wingA = SKShapeNode(path: wingPath)
        wingA.fillColor = NSColor(calibratedRed: 1, green: 0.88, blue: 0.45, alpha: 0.95)
        wingA.strokeColor = .clear
        snitchWingA.addChild(wingA)
        snitch.addChild(snitchWingA)
        snitchWingB = SKNode()
        snitchWingB.position = CGPoint(x: 4, y: 58)
        let wingB = SKShapeNode(path: wingPath)
        wingB.fillColor = NSColor(calibratedRed: 1, green: 0.84, blue: 0.38, alpha: 0.8)
        wingB.strokeColor = .clear
        wingB.xScale = -0.72
        wingB.yScale = 0.8
        snitchWingB.addChild(wingB)
        snitch.addChild(snitchWingB)

        // Legs: baggy khakis + clean white sneakers (hip pivots)
        for (legNode, dx) in [(snitchLegL, -7), (snitchLegR, 7)] as [(SKNode, CGFloat)] {
            legNode.removeAllChildren()
            legNode.position = CGPoint(x: dx, y: 30)
            let pant = SKShapeNode(rectOf: CGSize(width: 15, height: 27), cornerRadius: 3)
            pant.position = CGPoint(x: 0, y: -12)
            pant.fillColor = khaki
            pant.strokeColor = .clear
            legNode.addChild(pant)
            let shoe = SKShapeNode(rectOf: CGSize(width: 17, height: 6), cornerRadius: 2)
            shoe.position = CGPoint(x: 2, y: -26)
            shoe.fillColor = .white
            shoe.strokeColor = .clear
            legNode.addChild(shoe)
            snitch.addChild(legNode)
        }

        // Torso: white tank, open flannel over it
        let tank = SKShapeNode(rectOf: CGSize(width: 32, height: 31), cornerRadius: 4)
        tank.position = CGPoint(x: 0, y: 45)
        tank.fillColor = NSColor(white: 0.95, alpha: 1)
        tank.strokeColor = .clear
        snitch.addChild(tank)
        for dx in [-17, 17] as [CGFloat] {
            let panel = SKShapeNode(rectOf: CGSize(width: 7.5, height: 31), cornerRadius: 2)
            panel.position = CGPoint(x: dx, y: 45)
            panel.fillColor = NSColor(calibratedRed: 0.45, green: 0.12, blue: 0.12, alpha: 1)
            panel.strokeColor = .clear
            snitch.addChild(panel)
        }
        // Arms + gold watch
        for dx in [-22, 22] as [CGFloat] {
            let armS = SKShapeNode(rectOf: CGSize(width: 8, height: 25), cornerRadius: 3)
            armS.position = CGPoint(x: dx, y: 42)
            armS.zRotation = dx < 0 ? 0.15 : -0.15
            armS.fillColor = skin
            armS.strokeColor = .clear
            snitch.addChild(armS)
        }
        let watch = SKShapeNode(circleOfRadius: 3.6)
        watch.position = CGPoint(x: -24.5, y: 32)
        watch.fillColor = gold
        watch.strokeColor = .clear
        snitch.addChild(watch)
        // The gold chain — five links across the chest
        for i in 0..<5 {
            let link = SKShapeNode(circleOfRadius: 2.6)
            link.position = CGPoint(x: -10 + CGFloat(i) * 5, y: 52 - abs(CGFloat(i) - 2) * 1.7)
            link.fillColor = gold
            link.strokeColor = .clear
            snitch.addChild(link)
        }
        // Head: bandana, shades, mustache, GOLD TEETH
        let headS = SKShapeNode(circleOfRadius: 11.5)
        headS.position = CGPoint(x: 0, y: 71)
        headS.fillColor = skin
        headS.strokeColor = .clear
        snitch.addChild(headS)
        let bandana = SKShapeNode(rectOf: CGSize(width: 24, height: 8.5), cornerRadius: 4)
        bandana.position = CGPoint(x: 0, y: 78)
        bandana.fillColor = gold
        bandana.strokeColor = .clear
        snitch.addChild(bandana)
        let knot = SKShapeNode(circleOfRadius: 3.5)
        knot.position = CGPoint(x: 12.5, y: 77)
        knot.fillColor = gold
        knot.strokeColor = .clear
        snitch.addChild(knot)
        let shades = SKShapeNode(rectOf: CGSize(width: 21, height: 6), cornerRadius: 2)
        shades.position = CGPoint(x: 0, y: 71)
        shades.fillColor = NSColor(white: 0.06, alpha: 1)
        shades.strokeColor = .clear
        snitch.addChild(shades)
        let stache = SKShapeNode(rectOf: CGSize(width: 12, height: 3.5), cornerRadius: 1.5)
        stache.position = CGPoint(x: 0, y: 64.5)
        stache.fillColor = NSColor(calibratedRed: 0.15, green: 0.10, blue: 0.08, alpha: 1)
        stache.strokeColor = .clear
        snitch.addChild(stache)
        let teeth = SKShapeNode(rectOf: CGSize(width: 10, height: 3.5), cornerRadius: 1.5)
        teeth.position = CGPoint(x: 0, y: 61)
        teeth.fillColor = gold
        teeth.strokeColor = .clear
        snitch.addChild(teeth)
        for (dx, dy) in [(-20, 86), (19, 64)] as [(CGFloat, CGFloat)] {
            let sparkle = makeLabel("✦", size: 12, pos: CGPoint(x: dx, y: dy), color: gold)
            snitch.addChild(sparkle)
        }

        snitchHome = spotX
        snitchX = snitchHome
        snitchDir = 1
        snitch.position = CGPoint(x: snitchX, y: groundY + 3)
        snitch.zPosition = 18
        world.addChild(snitch)

        // ——— THE OFFICER ———
        officer.removeAllChildren()
        officer.removeFromParent()
        let navy = NSColor(calibratedRed: 0.12, green: 0.18, blue: 0.38, alpha: 1)
        for (legNode, dx) in [(officerLegL, -5.5), (officerLegR, 5.5)] as [(SKNode, CGFloat)] {
            legNode.removeAllChildren()
            legNode.position = CGPoint(x: dx, y: 28)
            let pantO = SKShapeNode(rectOf: CGSize(width: 10, height: 25), cornerRadius: 2)
            pantO.position = CGPoint(x: 0, y: -11)
            pantO.fillColor = navy
            pantO.strokeColor = .clear
            legNode.addChild(pantO)
            let shoeO = SKShapeNode(rectOf: CGSize(width: 13, height: 5), cornerRadius: 2)
            shoeO.position = CGPoint(x: 1, y: -24)
            shoeO.fillColor = NSColor(white: 0.08, alpha: 1)
            shoeO.strokeColor = .clear
            legNode.addChild(shoeO)
            officer.addChild(legNode)
        }
        let uniform = SKShapeNode(rectOf: CGSize(width: 27, height: 30), cornerRadius: 4)
        uniform.position = CGPoint(x: 0, y: 43)
        uniform.fillColor = navy
        uniform.strokeColor = .clear
        officer.addChild(uniform)
        let belt = SKShapeNode(rectOf: CGSize(width: 27, height: 5))
        belt.position = CGPoint(x: 0, y: 29)
        belt.fillColor = NSColor(white: 0.08, alpha: 1)
        belt.strokeColor = .clear
        officer.addChild(belt)
        let badgeO = SKShapeNode(circleOfRadius: 3.4)
        badgeO.position = CGPoint(x: -7, y: 49)
        badgeO.fillColor = gold
        badgeO.strokeColor = .clear
        officer.addChild(badgeO)
        for dx in [-17.5, 17.5] as [CGFloat] {
            let armO = SKShapeNode(rectOf: CGSize(width: 7, height: 23), cornerRadius: 3)
            armO.position = CGPoint(x: dx, y: 41)
            armO.zRotation = dx < 0 ? 0.12 : -0.12
            armO.fillColor = navy
            armO.strokeColor = .clear
            officer.addChild(armO)
        }
        let headO = SKShapeNode(circleOfRadius: 10.5)
        headO.position = CGPoint(x: 0, y: 66)
        headO.fillColor = NSColor(calibratedRed: 0.85, green: 0.66, blue: 0.50, alpha: 1)
        headO.strokeColor = .clear
        officer.addChild(headO)
        let capTop = SKShapeNode(rectOf: CGSize(width: 21, height: 6.5), cornerRadius: 3)
        capTop.position = CGPoint(x: 0, y: 74)
        capTop.fillColor = navy
        capTop.strokeColor = .clear
        officer.addChild(capTop)
        let brim = SKShapeNode(rectOf: CGSize(width: 15, height: 3))
        brim.position = CGPoint(x: -8, y: 70.5)
        brim.fillColor = NSColor(white: 0.08, alpha: 1)
        brim.strokeColor = .clear
        officer.addChild(brim)
        let capBadge = SKShapeNode(circleOfRadius: 2.4)
        capBadge.position = CGPoint(x: 0, y: 74)
        capBadge.fillColor = gold
        capBadge.strokeColor = .clear
        officer.addChild(capBadge)

        officerX = spotX + 58
        officerState = 0
        officerRunDist = 0
        officer.position = CGPoint(x: officerX, y: groundY)
        officer.zPosition = 18
        officer.xScale = -1 // facing the Snitch
        world.addChild(officer)

        // ——— THE CONVERSATION ———
        talkBubble.removeAllChildren()
        talkBubble.removeFromParent()
        let bubbleBack = SKShapeNode(rectOf: CGSize(width: 218, height: 30), cornerRadius: 9)
        bubbleBack.fillColor = NSColor(white: 1, alpha: 0.92)
        bubbleBack.strokeColor = NSColor(white: 0, alpha: 0.25)
        bubbleBack.lineWidth = 1
        talkBubble.addChild(bubbleBack)
        let tailB = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
        tailB.position = CGPoint(x: -14, y: -17)
        tailB.zRotation = .pi / 4
        tailB.fillColor = NSColor(white: 1, alpha: 0.92)
        tailB.strokeColor = .clear
        talkBubble.addChild(tailB)
        talkLabel = SKLabelNode(fontNamed: "Helvetica")
        talkLabel.fontSize = 12.5
        talkLabel.fontColor = NSColor(white: 0.10, alpha: 1)
        talkLabel.verticalAlignmentMode = .center
        talkLabel.horizontalAlignmentMode = .center
        talkLabel.text = "…so I told him, that's MY corner."
        talkBubble.addChild(talkLabel)
        talkBubble.position = CGPoint(x: snitchX + 42, y: groundY + 118)
        talkBubble.zPosition = 19
        talkTimer = 0
        talkTurn = false
        world.addChild(talkBubble)
    }

    private func checkSnitchHit(minX: CGFloat, maxX: CGFloat) {
        guard snitchPresent, !snitchGone, !snitchCaughtRun else { return }
        guard snitchX >= minX - 12 && snitchX <= maxX + 12 else { return }
        if snitchDodges < 3 && Int.random(in: 0..<4) == 0 {
            snitchDodges += 1
            snitchX = min(max(snitchX + (snitchX < monster.position.x ? -170 : 170), 90), worldWidth - 90)
            snitch.position.x = snitchX
            floatingText("TOO SLOW, FOOL! 💨", at: CGPoint(x: snitchX, y: groundY + 130),
                         color: .white, size: 17)
            return
        }
        catchSnitch()
    }

    private func catchSnitch() {
        snitchCaughtRun = true
        huntDaysAtCatch = seasonDay
        // No payout yet — the payday lands when this run ends and the
        // whole hunt bank locks in at ×10 (see showResults).
        let gold = NSColor(calibratedRed: 1, green: 0.8, blue: 0.2, alpha: 1)
        floatingText("🏆 GOLDEN SNITCH CRUSHED! 🏆", at: CGPoint(x: snitchX, y: groundY + 215),
                     color: gold, size: 27)
        floatingText("FINISH THE RUN — EVERYTHING LOCKS IN AT ×10!", at: CGPoint(x: snitchX, y: groundY + 178),
                     color: gold, size: 18)
        mamaSays(mamaPraiseLines.randomElement() ?? "THAT'S MY BABY!")
        playSFX("Hero")
        debris(at: CGPoint(x: snitchX, y: groundY + 40), count: 18, big: true)
        talkBubble.removeFromParent()
        snitch.run(SKAction.sequence([
            SKAction.group([
                SKAction.rotate(byAngle: 5.5, duration: 0.45),
                SKAction.scale(to: 0.15, duration: 0.45),
                SKAction.fadeOut(withDuration: 0.45)
            ]),
            SKAction.removeFromParent()
        ]))
        // The new hunt begins at lock-in, when this run ends.
    }

    private func spawnCrowd() {
        pedestrians = []
        var kinds: [Pedestrian.Kind] = []
        kinds += Array(repeating: .walker, count: 14)
        kinds += Array(repeating: .dancer, count: 5)
        kinds += Array(repeating: .influencer, count: 4)
        kinds += Array(repeating: .big, count: 3)
        for kind in kinds.shuffled() {
            let ped = buildPedestrian(kind: kind, x: CGFloat.random(in: 170...(worldWidth - 170)))
            pedestrians.append(ped)
            world.addChild(ped.node)
        }
    }

    // MARK: Traffic — drawn cars in two lanes, smashable, polite
    // enough to stop (and honk) for pedestrians.

    private func buildCar(x: CGFloat, lane: Int) -> Car {
        let car = Car(x: x, lane: lane, groundY: groundY)
        let paints: [NSColor] = [
            NSColor(calibratedRed: 0.85, green: 0.25, blue: 0.22, alpha: 1),
            NSColor(calibratedRed: 0.98, green: 0.78, blue: 0.15, alpha: 1),
            NSColor(calibratedRed: 0.25, green: 0.45, blue: 0.85, alpha: 1),
            NSColor(calibratedRed: 0.90, green: 0.90, blue: 0.92, alpha: 1),
            NSColor(calibratedRed: 0.20, green: 0.65, blue: 0.55, alpha: 1),
            NSColor(calibratedRed: 0.55, green: 0.30, blue: 0.70, alpha: 1)
        ]
        let body = SKShapeNode(rectOf: CGSize(width: 66, height: 18), cornerRadius: 6)
        body.position = CGPoint(x: 0, y: 17)
        body.fillColor = paints.randomElement()!
        body.strokeColor = NSColor(white: 0, alpha: 0.3)
        car.node.addChild(body)
        let cabin = SKShapeNode(rectOf: CGSize(width: 32, height: 13), cornerRadius: 4)
        cabin.position = CGPoint(x: -3, y: 31)
        cabin.fillColor = NSColor(calibratedRed: 0.65, green: 0.80, blue: 0.90, alpha: 1)
        cabin.strokeColor = NSColor(white: 0, alpha: 0.3)
        car.node.addChild(cabin)
        for wx in [-20, 20] as [CGFloat] {
            let wheel = SKShapeNode(circleOfRadius: 7)
            wheel.position = CGPoint(x: wx, y: 7)
            wheel.fillColor = NSColor(white: 0.12, alpha: 1)
            wheel.strokeColor = NSColor(white: 0.55, alpha: 1)
            wheel.lineWidth = 2
            car.node.addChild(wheel)
        }
        let light = SKShapeNode(circleOfRadius: 3)
        light.position = CGPoint(x: 32, y: 19)
        light.fillColor = NSColor(calibratedRed: 1, green: 0.95, blue: 0.6, alpha: 1)
        light.strokeColor = .clear
        car.node.addChild(light)
        car.node.position = CGPoint(x: x, y: car.laneY)
        car.node.xScale = car.dir
        car.node.zPosition = lane == 0 ? 6 : 24
        return car
    }

    private func spawnTraffic() {
        cars = []
        for i in 0..<8 {
            let car = buildCar(x: CGFloat(300 + i * 430) + CGFloat.random(in: -60...60), lane: i % 2)
            cars.append(car)
            world.addChild(car.node)
        }
    }

    private func spawnCarAtEdge() {
        let lane = Int.random(in: 0...1)
        let car = buildCar(x: lane == 1 ? -70 : worldWidth + 70, lane: lane)
        cars.append(car)
        world.addChild(car.node)
    }

    private func updateTraffic(_ dt: Double) {
        for car in cars where car.alive {
            // Stop-and-honk when a pedestrian is crossing ahead.
            let aheadX = car.x + car.dir * 52
            var blocked = false
            for ped in pedestrians where ped.alive {
                if abs(ped.x - aheadX) < 30 { blocked = true; break }
            }
            if blocked {
                car.honkTimer -= dt
                if car.honkTimer <= 0 {
                    car.honkTimer = 1.1
                    floatingText("!", at: CGPoint(x: car.x, y: car.laneY + 64),
                                 color: .white, size: 22)
                    playSFX("Submarine")
                }
            } else {
                let fleeing = abs(car.x - monster.position.x) < 240
                car.x += car.dir * car.speed * CGFloat(fleeing ? 2.2 : 1.0) * CGFloat(dt)
                if car.x < -90 { car.x = worldWidth + 90 }
                if car.x > worldWidth + 90 { car.x = -90 }
            }
            car.node.position = CGPoint(x: car.x, y: car.laneY)
        }
        // Keep the streets populated (never more than ~10 cars).
        if cars.filter({ $0.alive }).count < 8 {
            carRespawnTimer -= dt
            if carRespawnTimer <= 0 {
                carRespawnTimer = 2.5
                spawnCarAtEdge()
            }
        }
    }

    private func smashCar(_ car: Car) {
        guard car.alive else { return }
        car.alive = false
        propsSmashed += 1
        // Cars pay prop claim dollars (roadmap item 5) but are NOT
        // part of the city's HP stock: totalHP counts buildings +
        // props only, and traffic respawns forever — counting car
        // HP here would let endless traffic inflate percentDestroyed
        // (rank could hit 100% / S while buildings still stand).
        damageDollars += comboAward(Scoring.propClaimDollars(rate: claimRate))
        debris(at: CGPoint(x: car.x, y: car.laneY + 20), count: 12, big: true)
        playSFX("Basso")
        floatingText("CAR CRUNCHED!", at: CGPoint(x: car.x, y: car.laneY + 84),
                     color: NSColor(calibratedRed: 1, green: 0.85, blue: 0.35, alpha: 1), size: 16)
        car.node.run(.sequence([
            .group([.scaleY(to: 0.15, duration: 0.16), .fadeOut(withDuration: 0.2)]),
            .removeFromParent()
        ]))
        refreshHUD()
    }

    private func checkCarsHit(minX: CGFloat, maxX: CGFloat) {
        for car in cars where car.alive && car.x >= minX && car.x <= maxX {
            smashCar(car)
        }
    }

    private func spawnOnePed() {
        let kinds: [Pedestrian.Kind] = [.walker, .walker, .walker, .dancer, .influencer, .big]
        let fromLeft = Bool.random()
        let ped = buildPedestrian(kind: kinds.randomElement()!,
                                  x: fromLeft ? 130 : worldWidth - 130)
        ped.dir = fromLeft ? 1 : -1
        pedestrians.append(ped)
        world.addChild(ped.node)
    }

    private func pedValue(_ kind: Pedestrian.Kind) -> Int {
        switch kind {
        case .walker: return Scoring.pedestrianValue
        case .dancer: return Scoring.dancerValue
        case .influencer: return Scoring.influencerValue
        case .big: return Scoring.bigPedestrianValue
        }
    }

    private func squashPed(_ ped: Pedestrian) {
        guard ped.alive else { return }
        ped.alive = false
        peopleSquashed += 1
        let value = pedValue(ped.kind) * (activeEvent == .rushHour ? Scoring.eventPedMultiplier : 1)
        damageDollars += value
        let callout: String
        switch ped.kind {
        case .walker: callout = "SQUASHED!"
        case .dancer: callout = "DANCE INTERRUPTED!"
        case .influencer: callout = "INFLUENCER SQUASHED!"
        case .big: callout = "BIG SQUASH BONUS!"
        }
        floatingText("\(callout) +\(Scoring.formatDollars(value))",
                     at: CGPoint(x: ped.x, y: groundY + 76),
                     color: ped.kind == .big
                        ? NSColor(calibratedRed: 1, green: 0.85, blue: 0.35, alpha: 1) : .white,
                     size: ped.kind == .big ? 19 : 15)
        debris(at: CGPoint(x: ped.x, y: groundY + 14), count: 6)
        playSFX("Pop")
        ped.node.run(.sequence([
            .group([.scaleY(to: 0.10, duration: 0.16), .fadeOut(withDuration: 0.2)]),
            .removeFromParent()
        ]))
        refreshHUD()
    }

    private func checkPedsHit(minX: CGFloat, maxX: CGFloat) {
        for ped in pedestrians where ped.alive && ped.x >= minX && ped.x <= maxX {
            squashPed(ped)
        }
    }

    private func swingLimbs(_ ped: Pedestrian) {
        ped.legL.zRotation = sin(CGFloat(ped.phase)) * 0.5
        ped.legR.zRotation = -sin(CGFloat(ped.phase)) * 0.5
        ped.armL.zRotation = -sin(CGFloat(ped.phase)) * 0.4
        if ped.kind != .influencer {
            ped.armR.zRotation = sin(CGFloat(ped.phase)) * 0.4
        }
        ped.bodyG.position.y = abs(sin(CGFloat(ped.phase))) * 2
    }

    // MARK: Effects

    private func floatingText(_ text: String, at pos: CGPoint, color: NSColor, size: CGFloat = 20) {
        let label = makeLabel(text, size: size, color: color, pos: pos)
        label.zPosition = 60
        effects.addChild(label)
        label.run(.sequence([
            .moveBy(x: 0, y: 44, duration: 0.85),
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ]))
    }

    private func debris(at pos: CGPoint, count: Int = 12, big: Bool = false) {
        for _ in 0..<count {
            let size = CGFloat.random(in: big ? 4...11 : 2.5...6)
            let chunk = SKShapeNode(rectOf: CGSize(width: size, height: size))
            chunk.fillColor = NSColor(calibratedRed: 0.75, green: 0.70, blue: 0.62, alpha: 1)
            chunk.strokeColor = .clear
            chunk.position = pos
            chunk.zPosition = 50
            effects.addChild(chunk)
            let dx = CGFloat.random(in: -90...90)
            chunk.run(.sequence([
                .group([
                    .moveBy(x: dx, y: CGFloat.random(in: -120 ... -30), duration: Double.random(in: 0.35...0.6)),
                    .rotate(byAngle: CGFloat.random(in: -3...3), duration: 0.5)
                ]),
                .fadeOut(withDuration: 0.2),
                .removeFromParent()
            ]))
        }
    }

    private func shakeCamera(intensity: CGFloat, duration: Double) {
        cam.removeAction(forKey: "shake")
        let steps = 6
        var actions: [SKAction] = []
        for _ in 0..<steps {
            actions.append(.moveBy(x: CGFloat.random(in: -intensity...intensity),
                                   y: CGFloat.random(in: -intensity / 2...intensity / 2),
                                   duration: duration / Double(steps)))
        }
        actions.append(.moveTo(x: cam.position.x, duration: 0.05)) // x corrected next frame anyway
        cam.run(.sequence(actions), withKey: "shake")
    }

    // MARK: Update

    override func update(_ currentTime: TimeInterval) {
        defer { lastUpdate = currentTime }
        if adTimeLeft > 0 {
            // An ad is playing. It is unskippable. That is the deal.
            let adDt = lastUpdate == 0 ? 0 : min(currentTime - lastUpdate, 0.05)
            adTimeLeft -= adDt
            adCountdownLabel?.text = adTimeLeft > 0
                ? "YOUR POINTS ARRIVE IN \(Int(adTimeLeft.rounded(.up)))… NO SKIPPING. YOU SOLD OUT."
                : ""
            if adTimeLeft <= 0 { finishAd() }
            return
        }
        guard state == .playing, !isPausedGame else { return }
        let dt = lastUpdate == 0 ? 0 : min(currentTime - lastUpdate, 0.05)
        guard dt > 0 else { return }

        // The city clock: one hour per city per season, ticking only
        // while you're in it. Autosave the freeze every 10 seconds.
        sessionElapsed += dt
        timeLeft = max(0, Scoring.cityBudgetSeconds - elapsedBase - sessionElapsed)
        autosaveTimer += dt
        if autosaveTimer >= 10 {
            autosaveTimer = 0
            snapshotProgress(bank: huntBankAtEntry + damageDollars, folded: foldedAtEntry + damageDollars)
        }
        if timeLeft <= 0 {
            endReason = .clockSpent
            refreshHUD()
            showResults()
            return
        }

        // Combo decay: miss the window and the chain breaks.
        if comboTimer > 0 {
            comboTimer -= dt
            if comboTimer <= 0 && comboCount > 0 {
                comboCount = 0
                comboLevel = 1
                refreshHUD()
            }
        }
        // Mid-run events: every ~40–60 seconds, 15 seconds of chaos.
        if let ev = activeEvent {
            eventTimer -= dt
            eventLabel.text = "🚨 \(ev.rawValue) · \(max(0, Int(eventTimer.rounded(.up))))s"
            if eventTimer <= 0 {
                activeEvent = nil
                eventNextIn = Double.random(in: 40...60)
                eventLabel.text = ""
            }
        } else {
            eventNextIn -= dt
            if eventNextIn <= 0 { startEvent() }
        }
        // Mama chimes in from the heavens at random — she has notes.
        mamaTimer += dt
        if mamaTimer >= mamaNextChime {
            mamaTimer = 0
            mamaNextChime = Double.random(in: 55...130)
            mamaChime()
        }

        if attackCooldown > 0 { attackCooldown -= dt }
        if specialCooldown > 0 { specialCooldown -= dt }

        updateTraffic(dt)

        // Walk
        var move: CGFloat = 0
        if keysPressed.contains(Key.left) || keysPressed.contains(Key.a) { move -= 1 }
        if keysPressed.contains(Key.right) || keysPressed.contains(Key.d) { move += 1 }
        if move != 0 {
            facing = move
            walkCycle += dt * 9
            monster.position.x += move * CGFloat(selectedMonster.speed) * CGFloat(dt)
            monster.position.x = min(max(monster.position.x, 70), worldWidth - 70)
        }
        let baseScale = CGFloat(selectedMonster.scale)
        monster.xScale = baseScale * facing
        monster.yScale = baseScale

        // Jump / gravity
        if (keysPressed.contains(Key.up) || keysPressed.contains(Key.w) || keysPressed.contains(Key.space)) && onGround {
            monsterVelY = 860
            onGround = false
        }
        if !onGround {
            monsterVelY -= 2100 * CGFloat(dt)
            monster.position.y += monsterVelY * CGFloat(dt)
            if monster.position.y <= groundY {
                monster.position.y = groundY
                monsterVelY = 0
                onGround = true
                shakeCamera(intensity: 3.5, duration: 0.12)
                // Landing on people (or on Maldo) counts. Obviously.
                checkMaldoHit(minX: monster.position.x - 48, maxX: monster.position.x + 48)
                checkPedsHit(minX: monster.position.x - 48, maxX: monster.position.x + 48)
                checkSnitchHit(minX: monster.position.x - 48, maxX: monster.position.x + 48)
            }
        }

        // Walk bob
        if move != 0 && onGround {
            monsterBodyGroup.position.y = abs(sin(CGFloat(walkCycle))) * 7
            monsterBodyGroup.zRotation = sin(CGFloat(walkCycle)) * 0.03
        } else {
            monsterBodyGroup.position.y = 0
            monsterBodyGroup.zRotation = 0
        }

        // Attacks (held keys repeat at the monster's own pace)
        if keysPressed.contains(Key.j) || keysPressed.contains(Key.x) { trySmash() }
        if keysPressed.contains(Key.k) || keysPressed.contains(Key.s) || keysPressed.contains(Key.down) { tryStomp() }
        if keysPressed.contains(Key.e) || keysPressed.contains(Key.shift) { trySpecial() }

        // Maldo wanders his random stretch of street — until he's flattened
        if maldoAlive {
            maldoPhase += dt * 8
            maldoX += maldoDir * 30 * CGFloat(dt)
            if maldoX > maldoHome + 260 { maldoDir = -1 }
            if maldoX < maldoHome - 260 { maldoDir = 1 }
            if maldoX < 90 { maldoDir = 1 }
            if maldoX > worldWidth - 90 { maldoDir = -1 }
            maldo.position.x = maldoX
            maldo.xScale = maldoDir * 0.92
            maldoLegL.zRotation = sin(CGFloat(maldoPhase)) * 0.45
            maldoLegR.zRotation = -sin(CGFloat(maldoPhase)) * 0.45
        } else {
            maldoRespawn -= dt
            if maldoRespawn <= 0 {
                spawnMaldo()
                floatingText("MALDO LURKS SOMEWHERE IN THE CITY…",
                             at: CGPoint(x: cam.position.x, y: 648),
                             color: NSColor(calibratedRed: 1, green: 0.4, blue: 0.45, alpha: 1), size: 17)
            }
        }

        // The Golden Snitch, out in the city somewhere, talking to a
        // cop — until the monster gets close. Then the cop books it
        // and the little wings earn their keep.
        if snitchPresent && !snitchCaughtRun {
            let goldTalk = NSColor(calibratedRed: 1, green: 0.8, blue: 0.2, alpha: 1)
            let distToMonster = abs(monster.position.x - snitchX)
            let fleeing = !snitchGone && distToMonster < 275
            if !snitchGone {
                snitchPhase += dt * (fleeing ? 17 : 7)
                if fleeing {
                    snitchDir = monster.position.x > snitchX ? -1 : 1
                    // His legs scale to the hunter: always fast,
                    // always catchable. A flat 242 outran the three
                    // slowest girls (210–230) forever — a hunt they
                    // could never finish is a bug, not a challenge.
                    let fleeSpeed: CGFloat = min(242, max(190, CGFloat(selectedMonster.speed) - 8))
                    snitchX += snitchDir * fleeSpeed * CGFloat(dt)
                    if snitchX < 80 || snitchX > worldWidth - 80 {
                        snitchGone = true
                        floatingText("THE GOLDEN SNITCH VANISHED INTO THE CITY! THE HUNT CONTINUES…",
                                     at: CGPoint(x: cam.position.x, y: 648),
                                     color: goldTalk, size: 17)
                        talkBubble.removeFromParent()
                        snitch.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.25), SKAction.removeFromParent()]))
                    }
                } else {
                    // Idle shuffle while he talks — a few steps each way
                    snitchX += snitchDir * 16 * CGFloat(dt)
                    if snitchX > snitchHome + 22 { snitchDir = -1 }
                    if snitchX < snitchHome - 22 { snitchDir = 1 }
                    // The conversation: random banter, taking turns
                    talkTimer -= dt
                    talkBubble.position.x = (talkTurn ? officerX : snitchX) + (talkTurn ? -30 : 42)
                    talkBubble.position.y = groundY + 118 + CGFloat(sin(snitchPhase * 0.6)) * 2
                    if talkTimer <= 0 {
                        talkTimer = 2.6
                        talkTurn.toggle()
                        talkLabel.text = talkTurn
                            ? ["Uh-huh.", "Sir, I'm going to need you to move along.", "We've been over this.", "Just stay where I can see you.", "…Right.", "The wings again?", "You know I have to log this."].randomElement()!
                            : ["I'm a changed man, officer.", "Those wings? Purely decorative.", "I pay ALL my tickets now.", "Golden? It's a family name.", "I was just about to confess… nothing.", "You seen my cousin? Looks like me. Wasn't me.", "We go way back, you and me."].randomElement()!
                    }
                }
                if !snitchGone {
                    snitch.position.x = snitchX
                    snitch.position.y = groundY + 3 + CGFloat(abs(sin(snitchPhase * (fleeing ? 1.6 : 0.9)))) * (fleeing ? 7 : 2.5)
                    snitch.xScale = snitchDir
                    snitchLegL.zRotation = sin(CGFloat(snitchPhase)) * (fleeing ? 0.55 : 0.18)
                    snitchLegR.zRotation = -sin(CGFloat(snitchPhase)) * (fleeing ? 0.55 : 0.18)
                    let flap = sin(CGFloat(snitchPhase) * (fleeing ? 2.4 : 1.4))
                    snitchWingA.zRotation = flap * (fleeing ? 0.5 : 0.22)
                    snitchWingB.zRotation = -flap * (fleeing ? 0.45 : 0.2)
                }
            }
            // The cop: mid-conversation he's still. The moment the
            // monster closes in, he wants no part of this — he runs.
            if officerState == 0 && distToMonster < 275 && !snitchGone {
                officerState = 1
                talkBubble.removeFromParent()
            }
            if officerState == 1 {
                officerPhase += dt * 15
                let away: CGFloat = officerX < monster.position.x ? -1 : 1
                officerX += away * 232 * CGFloat(dt)
                officerRunDist += 232 * CGFloat(dt)
                officer.position.x = officerX
                officer.xScale = away
                officerLegL.zRotation = sin(CGFloat(officerPhase)) * 0.55
                officerLegR.zRotation = -sin(CGFloat(officerPhase)) * 0.55
                if officerRunDist > 300 || officerX < 60 || officerX > worldWidth - 60 {
                    officerState = 2
                    officer.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.18), SKAction.removeFromParent()]))
                }
            }
        }

        // The crowd: strollers stroll, dancers dance (oblivious), influencers
        // film (mostly oblivious). Everyone is squashable; big ones pay most.
        crowdRespawn -= dt
        if pedestrians.reduce(0, { $0 + ($1.alive ? 1 : 0) }) < crowdTarget && crowdRespawn <= 0 {
            spawnOnePed()
            crowdRespawn = 2.5
        }
        for ped in pedestrians where ped.alive {
            ped.phase += dt * (ped.kind == .dancer ? 6.5 : 9)
            let distToMonster = abs(ped.x - monster.position.x)
            switch ped.kind {
            case .dancer:
                // Mid-routine. A giant monster is no reason to stop filming.
                ped.bodyG.position.y = abs(sin(CGFloat(ped.phase))) * 4.5
                ped.bodyG.zRotation = sin(CGFloat(ped.phase) * 0.5) * 0.09
                ped.armL.zRotation = 2.5 + sin(CGFloat(ped.phase)) * 0.55
                ped.armR.zRotation = -2.5 - cos(CGFloat(ped.phase)) * 0.55
            case .influencer:
                var speed = ped.baseSpeed
                if distToMonster < 95 {
                    ped.dir = ped.x >= monster.position.x ? 1 : -1
                    speed = ped.baseSpeed * 2.4
                }
                ped.x += ped.dir * speed * CGFloat(dt)
                swingLimbs(ped)
            case .walker, .big:
                var speed = ped.baseSpeed
                if distToMonster < 200 {
                    ped.dir = ped.x >= monster.position.x ? 1 : -1
                    speed = ped.baseSpeed * (ped.kind == .big ? 1.7 : 2.3)
                }
                ped.x += ped.dir * speed * CGFloat(dt)
                swingLimbs(ped)
            }
            if ped.x < 95 { ped.x = 95; ped.dir = 1 }
            if ped.x > worldWidth - 95 { ped.x = worldWidth - 95; ped.dir = -1 }
            ped.node.position = CGPoint(x: ped.x, y: groundY)
            if ped.kind != .dancer { ped.node.xScale = ped.dir }
        }
        // Simply walking over people squashes them. That's the game.
        if onGround {
            checkPedsHit(minX: monster.position.x - 44, maxX: monster.position.x + 44)
            checkSnitchHit(minX: monster.position.x - 44, maxX: monster.position.x + 44)
        }

        // Camera follows
        let targetX = min(max(monster.position.x, 640), worldWidth - 640)
        cam.position.x += (targetX - cam.position.x) * 0.12
        cam.position.y = 400

        refreshHUD()
    }
}
