import StoreKit
import SwiftUI

/// When Peek asks for a rating with the system's prompt, which StoreKit shows at most three times a year and never in
/// TestFlight: right after something went well, once its reader has used the app on three days, once per version of
/// the app, a month after the last ask at the soonest, and never on a day something went wrong in front of them. The
/// days are counted on this iPhone, and nothing of it leaves it.
struct ReviewPrompt {
    /// Days with use before the first ask.
    static let days = 3
    /// Days from one ask to the next, whatever the version.
    static let gap = 30
    /// How long a moment that went well is left to settle before the ask.
    static let settle: Duration = .seconds(2)

    private static let key = "sdt.reviewPrompt.v1"

    private struct Memory: Codable {
        /// The days the app was used on, the latest of them included.
        var days = 0
        var lastDay: Int?
        /// The latest day something went wrong.
        var badDay: Int?
        var askedVersion: String?
        var askedDay: Int?
    }

    private let defaults: UserDefaults
    /// `CFBundleShortVersionString`: each version asks once.
    private let version: String
    /// The reader's calendar, which their days are counted in.
    private let calendar: Calendar

    init(defaults: UserDefaults = .standard, version: String = AppConfiguration.version, timeZone: TimeZone = .current) {
        self.defaults = defaults
        self.version = version
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        self.calendar = calendar
    }

    /// The reader's parcels were in front of them at `date`: its calendar day counts as one with use.
    func used(at date: Date) {
        let day = day(date)
        update { memory in
            guard memory.lastDay != day else { return }
            memory.lastDay = day
            memory.days += 1
        }
    }

    /// Counts the day, and says whether a moment that went well at `date` is the one to ask at: `calm` (nothing about
    /// it is wrong), on the third day with use or a later one, for a version that has not asked, a month after the
    /// last ask, on a day nothing went wrong. Nothing is asked until `asked`.
    func isDue(at date: Date, calm: Bool) -> Bool {
        used(at: date)
        #if DEBUG
        if Self.forced { return calm }
        #endif
        let memory = read()
        let day = day(date)
        guard calm, memory.days >= Self.days, memory.askedVersion != version, memory.badDay != day else { return false }
        if let askedDay = memory.askedDay, day - askedDay < Self.gap { return false }
        return true
    }

    /// Something went wrong in front of the reader at `date`: nothing is asked for the rest of that day.
    func noteBadMoment(at date: Date) {
        let day = day(date)
        update { $0.badDay = day }
    }

    /// The app asked at `date`: this version asks no more, and the next one waits for the gap.
    func asked(at date: Date) {
        let day = day(date)
        update { memory in
            memory.askedVersion = version
            memory.askedDay = day
        }
    }

    /// A screen is about to ask at `date`, a moment after the moment that made it due: true, and remembered as an
    /// ask, while the rule still holds then.
    func take(at date: Date, calm: Bool) -> Bool {
        guard isDue(at: date, calm: calm) else { return false }
        asked(at: date)
        return true
    }

    /// The calendar day of `date` where the reader is, as days since 1970. The day's date is read in the reader's
    /// zone, then counted in UTC, where every day is as long as the next.
    private func day(_ date: Date) -> Int {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = .gmt
        return Int(((utc.date(from: parts) ?? date).timeIntervalSince1970 / 86_400).rounded(.down))
    }

    private func update(_ change: (inout Memory) -> Void) {
        var memory = read()
        change(&memory)
        defaults.set(try? JSONEncoder().encode(memory), forKey: Self.key)
    }

    private func read() -> Memory {
        defaults.data(forKey: Self.key).flatMap { try? JSONDecoder().decode(Memory.self, from: $0) } ?? Memory()
    }
}

extension ReviewPrompt {
    /// Nothing in the app stands in the way of an ask, whatever the screen: someone's own parcels are loaded and
    /// current, and no notice, notification permission, friend's invitation or parcel link is over them. Never over
    /// the demo's made-up parcels or the first screen. The verification check only comes up over the sheets that add
    /// a parcel or change its carrier, or over a parcel link, which the screens and this already wait out.
    @MainActor
    static func settled(session: SessionStore, store: ParcelStore, links: ParcelLinkStore, invitation: FriendInvitationStore) -> Bool {
        let following = switch session.state {
        case .signedIn: true
        // Nobody is signed in: the parcels this iPhone follows, once there are some.
        case .welcome: !store.parcels.isEmpty
        case .demo: asksInDemo
        case .loading, .signedOut, .unconfigured: false
        }
        return following && !store.loading && store.errorMessage == nil && !store.authenticationRequired
            && !store.usingCachedData && !store.notificationEnableInProgress && links.route == nil && !invitation.isPresenting
    }

    /// The demo's parcels are made up: nobody is asked about them, but for a look at the prompt in a debug build.
    private static var asksInDemo: Bool {
        #if DEBUG
        return forced
        #else
        return false
        #endif
    }
}

#if DEBUG
extension ReviewPrompt {
    /// `-sdt.debug.reviewDue YES` makes every calm moment the one to ask at, in the demo too, so that a run in the
    /// simulator, where StoreKit always shows its prompt, shows it.
    static var forced: Bool { UserDefaults.standard.bool(forKey: "sdt.debug.reviewDue") }
}
#endif

extension Parcel {
    /// Nothing about the parcel is wrong or waits on its reader: its carrier is known and answers, and nothing on it
    /// needs attention. Only then is an answer that its page is right the moment to ask for a rating.
    func untroubled(now: Date = Date()) -> Bool {
        displayedCarrier != .unknown && ![.error, .unsupported, .waiting].contains(syncStatus) && attention(now: now) == nil
    }
}

extension View {
    /// Asks for a rating a moment after `due` comes, once the screen is `ready`: nothing over it, in front of the
    /// reader. `take` has the last word, and an ask is counted. A screen that stops being ready waits to be again.
    /// Never from a tap: StoreKit may show nothing, and a button that does nothing would be a broken one.
    func askingForReview(due: Bool, ready: Bool, take: @escaping @MainActor () -> Bool) -> some View {
        modifier(ReviewAsk(due: due, ready: ready, take: take))
    }
}

private struct ReviewAsk: ViewModifier {
    let due: Bool
    let ready: Bool
    let take: @MainActor () -> Bool

    @Environment(\.requestReview) private var requestReview

    func body(content: Content) -> some View {
        content.task(id: Wait(due: due, ready: ready)) {
            guard due, ready else { return }
            try? await Task.sleep(for: ReviewPrompt.settle)
            guard !Task.isCancelled, take() else { return }
            requestReview()
            DeliveryAnalytics.shared.action("review-ask")
        }
    }

    private struct Wait: Equatable {
        var due: Bool
        var ready: Bool
    }
}
