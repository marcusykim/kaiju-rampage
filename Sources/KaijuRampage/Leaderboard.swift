import Foundation
#if canImport(GameKit)
import GameKit
#endif

/// One finished rampage, as shown on the local leaderboard.
public struct ScoreEntry: Codable, Equatable {
    public let damage: Int
    public let percent: Int
    public let monster: String
    public let city: String
    public let mode: String
    public let date: Date

    public init(damage: Int, percent: Int, monster: String, city: String, mode: String, date: Date) {
        self.damage = damage
        self.percent = percent
        self.monster = monster
        self.city = city
        self.mode = mode
        self.date = date
    }

    // Tolerant decoding, same reason as CityProgress: a board saved
    // by an older build must not vanish because a newer field is
    // absent from its JSON — each field falls back to a default.
    private enum CodingKeys: String, CodingKey {
        case damage, percent, monster, city, mode, date
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        damage = try c.decodeIfPresent(Int.self, forKey: .damage) ?? 0
        percent = try c.decodeIfPresent(Int.self, forKey: .percent) ?? 0
        monster = try c.decodeIfPresent(String.self, forKey: .monster) ?? ""
        city = try c.decodeIfPresent(String.self, forKey: .city) ?? ""
        mode = try c.decodeIfPresent(String.self, forKey: .mode) ?? ""
        date = try c.decodeIfPresent(Date.self, forKey: .date) ?? Date(timeIntervalSince1970: 0)
    }
}

/// Local top-10 leaderboard (UserDefaults). This is the leaderboard that
/// works today, in every build. The Game Center leaderboard
/// ("kaijurampage.damage") takes over for ranked/global scores once the
/// app is registered in App Store Connect — see STORE_LAUNCH_PLAN.md.
public enum Leaderboard {
    private static let key = "kaijurampage.leaderboard.v1"
    public static let maxEntries = 10

    public static func load() -> [ScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([ScoreEntry].self, from: data)
        else { return [] }
        return entries
    }

    /// Records a run and returns the updated board (sorted by damage, top 10).
    @discardableResult
    public static func record(_ entry: ScoreEntry) -> [ScoreEntry] {
        var entries = load()
        entries.append(entry)
        entries.sort { $0.damage > $1.damage }
        entries = Array(entries.prefix(maxEntries))
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
        submitToGameCenter(damage: entry.damage)
        return entries
    }

    public static func rank(of entry: ScoreEntry, in board: [ScoreEntry]) -> Int? {
        board.firstIndex(of: entry).map { $0 + 1 }
    }

    // MARK: Game Center (activates once the leaderboard exists in App Store Connect)

    /// Flip to true after creating the "kaijurampage.damage" leaderboard in
    /// App Store Connect and enabling Game Center for the bundle ID.
    public static let gameCenterEnabled = false
    public static let gameCenterLeaderboardID = "kaijurampage.damage"

    private static func submitToGameCenter(damage: Int) {
        #if canImport(GameKit)
        guard gameCenterEnabled, GKLocalPlayer.local.isAuthenticated else { return }
        GKLeaderboard.submitScore(
            damage, context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [gameCenterLeaderboardID]
        ) { _ in /* best-effort: local board already saved */ }
        #endif
    }
}
