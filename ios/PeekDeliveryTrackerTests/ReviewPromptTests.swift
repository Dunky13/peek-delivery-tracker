import XCTest
@testable import PeekDeliveryTracker

/// When the app asks for a rating: at a calm moment, from the third day with use, once per version, a month apart at
/// the soonest and never on a day something went wrong; and the "Yes" on a parcel's page that makes the moment.
@MainActor
final class ReviewPromptTests: XCTestCase {
    private final class Clock {
        var now: Date
        init(_ now: Date) { self.now = now }
    }

    private let start = ISO8601DateFormatter().date(from: "2026-10-01T09:00:00Z")!

    private func date(_ text: String) -> Date {
        ISO8601DateFormatter().date(from: text)!
    }

    private func day(_ days: Int, hours: Double = 0) -> Date {
        start.addingTimeInterval(Double(days) * 86_400 + hours * 3_600)
    }

    /// A store of its own, so that the tests write nothing to the app's.
    private func defaults() -> (UserDefaults, String) {
        let suite = "ReviewPromptTests.\(UUID().uuidString)"
        return (UserDefaults(suiteName: suite)!, suite)
    }

    // MARK: - The rule

    func testAsksOnTheThirdDayWithUseThenNotAgain() {
        let (store, suite) = defaults()
        defer { store.removePersistentDomain(forName: suite) }
        let prompt = ReviewPrompt(defaults: store, version: "1.0", timeZone: .gmt)
        XCTAssertFalse(prompt.isDue(at: day(0), calm: true))
        // Days without use do not count.
        XCTAssertFalse(prompt.isDue(at: day(5), calm: true))
        XCTAssertTrue(prompt.isDue(at: day(9), calm: true))
        prompt.asked(at: day(9))
        XCTAssertFalse(prompt.isDue(at: day(10), calm: true))
        XCTAssertFalse(prompt.isDue(at: day(90), calm: true))
    }

    func testStaysDueUntilTheAppAsks() {
        let (store, suite) = defaults()
        defer { store.removePersistentDomain(forName: suite) }
        let prompt = ReviewPrompt(defaults: store, version: "1.0", timeZone: .gmt)
        // A day the parcels were in front of the reader counts as much as a good moment.
        prompt.used(at: day(0))
        XCTAssertFalse(prompt.isDue(at: day(1), calm: true))
        XCTAssertTrue(prompt.isDue(at: day(2), calm: true))
        XCTAssertTrue(prompt.isDue(at: day(2, hours: 1), calm: true))
        XCTAssertTrue(prompt.take(at: day(2, hours: 1), calm: true))
        XCTAssertFalse(prompt.isDue(at: day(2, hours: 2), calm: true))
        XCTAssertFalse(prompt.take(at: day(2, hours: 2), calm: true))
    }

    func testCountsTheReadersOwnDays() {
        let (store, suite) = defaults()
        defer { store.removePersistentDomain(forName: suite) }
        let prompt = ReviewPrompt(defaults: store, version: "1.0", timeZone: TimeZone(identifier: "America/Sao_Paulo")!)
        // 22:00 on the 1st and 01:00 on the 2nd in São Paulo: two days there, one in UTC.
        prompt.used(at: date("2026-10-02T01:00:00Z"))
        XCTAssertFalse(prompt.isDue(at: date("2026-10-02T04:00:00Z"), calm: true))
        // Noon on the 2nd is the same day there.
        XCTAssertFalse(prompt.isDue(at: date("2026-10-02T15:00:00Z"), calm: true))
        // Noon and 20:00 on the 3rd: the third day, counted once.
        XCTAssertTrue(prompt.isDue(at: date("2026-10-03T15:00:00Z"), calm: true))
        prompt.asked(at: date("2026-10-03T15:00:00Z"))
        XCTAssertFalse(prompt.isDue(at: date("2026-10-03T23:00:00Z"), calm: true))
        // 21:00 on 1 November there is 29 days after the ask; 01:00 on the 2nd is 30, though both are the 2nd in UTC.
        let next = ReviewPrompt(defaults: store, version: "1.1", timeZone: TimeZone(identifier: "America/Sao_Paulo")!)
        XCTAssertFalse(next.isDue(at: date("2026-11-02T00:00:00Z"), calm: true))
        XCTAssertTrue(next.isDue(at: date("2026-11-02T04:00:00Z"), calm: true))
    }

    func testWaitsForACalmMoment() {
        let (store, suite) = defaults()
        defer { store.removePersistentDomain(forName: suite) }
        let prompt = ReviewPrompt(defaults: store, version: "1.0", timeZone: .gmt)
        for days in 0..<2 {
            XCTAssertFalse(prompt.isDue(at: day(days), calm: true))
        }
        XCTAssertFalse(prompt.isDue(at: day(2), calm: false))
        XCTAssertFalse(prompt.take(at: day(2, hours: 1), calm: false))
        XCTAssertTrue(prompt.isDue(at: day(2, hours: 2), calm: true))
    }

    func testEachVersionAsksOnceAMonthAfterTheLastAsk() {
        let (store, suite) = defaults()
        defer { store.removePersistentDomain(forName: suite) }
        let first = ReviewPrompt(defaults: store, version: "1.0", timeZone: .gmt)
        for days in 0..<2 {
            XCTAssertFalse(first.isDue(at: day(days), calm: true))
        }
        XCTAssertTrue(first.take(at: day(2), calm: true))

        // A new version the next day waits for the month to pass.
        let next = ReviewPrompt(defaults: store, version: "1.1", timeZone: .gmt)
        XCTAssertFalse(next.isDue(at: day(3), calm: true))
        XCTAssertFalse(next.isDue(at: day(2 + ReviewPrompt.gap - 1), calm: true))
        XCTAssertTrue(next.isDue(at: day(2 + ReviewPrompt.gap), calm: true))
        next.asked(at: day(2 + ReviewPrompt.gap))
        XCTAssertFalse(next.isDue(at: day(2 + 3 * ReviewPrompt.gap), calm: true))
    }

    func testNothingIsAskedOnADayThatWentWrong() {
        let (store, suite) = defaults()
        defer { store.removePersistentDomain(forName: suite) }
        let prompt = ReviewPrompt(defaults: store, version: "1.0", timeZone: .gmt)
        prompt.used(at: day(0))
        prompt.used(at: day(1))
        prompt.noteBadMoment(at: day(2))
        XCTAssertFalse(prompt.isDue(at: day(2, hours: 3), calm: true))
        XCTAssertFalse(prompt.take(at: day(2, hours: 14), calm: true))
        // The next day starts afresh.
        XCTAssertTrue(prompt.isDue(at: day(3), calm: true))
    }

    // MARK: - A parcel's page

    func testOnlyAParcelWithNothingWrongIsCalm() {
        let now = date("2026-10-03T09:00:00Z")
        XCTAssertTrue(parcel().untroubled(now: now))
        XCTAssertFalse(parcel(carrier: .unknown).untroubled(now: now))
        for sync in [SyncStatus.error, .unsupported, .waiting] {
            XCTAssertFalse(parcel(sync: sync).untroubled(now: now), sync.rawValue)
        }
        for stage in [TrackingStage.failedAttempt, .exception, .customs, .readyForPickup] {
            XCTAssertFalse(parcel(stage: stage).untroubled(now: now), stage.rawValue)
        }
        // Five days without a scan: stalled.
        XCTAssertFalse(parcel().untroubled(now: date("2026-10-07T09:00:00Z")))
        // The page says so of its parcel.
        let delivered = parcel(stage: .delivered)
        XCTAssertEqual(page(of: delivered)?.untroubled, true)
        XCTAssertEqual(page(of: parcel(stage: .delivered, sync: .error))?.untroubled, false)
    }

    func testAYesTheServiceTookOnACalmParcelIsTheMomentToAsk() async {
        let (store, suite) = defaults()
        defer { store.removePersistentDomain(forName: suite) }
        let clock = Clock(day(2))
        usedTwoDays(store)

        let model = visit(page(), store, clock)
        await model.right()
        XCTAssertTrue(model.reviewDue)
        XCTAssertTrue(model.takeReviewMoment())
        XCTAssertFalse(model.reviewDue)
        XCTAssertFalse(model.takeReviewMoment())

        // This version has asked: another "Yes" is just a "Yes".
        clock.now = day(3)
        let again = visit(page(), store, clock)
        await again.right()
        XCTAssertFalse(again.reviewDue)
    }

    func testTheWayBackAsksOnceItsThanksHasGone() async {
        let (store, suite) = defaults()
        defer { store.removePersistentDomain(forName: suite) }
        let clock = Clock(day(2))
        usedTwoDays(store)

        let model = visit(page(), store, clock)
        await model.right(.back)
        XCTAssertEqual(model.word, .backRight)
        XCTAssertTrue(model.reviewDue)
        model.wordLeft(.backRight)
        XCTAssertTrue(model.takeReviewMoment())
    }

    func testAParcelInTroubleAsksNothing() async {
        let (store, suite) = defaults()
        defer { store.removePersistentDomain(forName: suite) }
        let clock = Clock(day(2))
        usedTwoDays(store)

        let model = visit(page(untroubled: false), store, clock)
        await model.right()
        XCTAssertFalse(model.reviewDue)
        // A day that went well otherwise still asks at the next calm "Yes".
        let calm = visit(page(), store, clock)
        await calm.right()
        XCTAssertTrue(calm.reviewDue)
    }

    func testANotQuiteOrAFailedSendKeepsTheDayFromAsking() async {
        let (store, suite) = defaults()
        defer { store.removePersistentDomain(forName: suite) }
        let clock = Clock(day(2))
        usedTwoDays(store)

        let off = visit(page(), store, clock)
        off.notQuite()
        let model = visit(page(), store, clock)
        await model.right()
        XCTAssertFalse(model.reviewDue)

        clock.now = day(3)
        let failing = visit(page(), store, clock, fails: true)
        await failing.right()
        XCTAssertEqual(failing.word, .failed)
        XCTAssertFalse(failing.reviewDue)
        let later = visit(page(), store, clock)
        await later.right()
        XCTAssertFalse(later.reviewDue)

        clock.now = day(4)
        let elsewhere = visit(page(.unknown), store, clock)
        elsewhere.elsewhere()
        let next = visit(page(), store, clock)
        await next.right()
        XCTAssertFalse(next.reviewDue)

        clock.now = day(5)
        let fine = visit(page(), store, clock)
        await fine.right()
        XCTAssertTrue(fine.reviewDue)
    }

    // MARK: - Helpers

    private func usedTwoDays(_ store: UserDefaults) {
        let prompt = ReviewPrompt(defaults: store, version: "1.0.2", timeZone: .gmt)
        prompt.used(at: day(0))
        prompt.used(at: day(1))
    }

    private func parcel(carrier: CarrierID = .dhl, stage: TrackingStage = .inTransit, sync: SyncStatus = .ok) -> Parcel {
        let id = UUID()
        return Parcel(
            id: id, trackingNumber: "TESTPARCEL123789", label: "", carrier: carrier, createdAt: "2026-10-01T08:00:00Z",
            syncStatus: sync, archivedAt: nil, notificationsMuted: false,
            trackingEvents: [TrackingEvent(id: UUID(), packageID: id, stage: stage, description: "", occurredAt: "2026-10-02T08:00:00Z")]
        )
    }

    private func page(of parcel: Parcel) -> ParcelFeedbackModel.Page? {
        ParcelFeedbackModel.Page(parcel: parcel, subject: .parcel(parcel.id), showsHistory: true, madeUp: false, carrier: "DHL", language: .en)
    }

    private func page(_ question: ParcelFeedbackQuestion = .found, untroubled: Bool = true) -> ParcelFeedbackModel.Page {
        ParcelFeedbackModel.Page(subject: .parcel(UUID()), question: question, scan: "1:2026-10-02T08:00:00Z", carrier: "DHL",
                                 language: .en, untroubled: untroubled)
    }

    /// A parcel's page as one visit holds it, over the same store as the others.
    private func visit(_ page: ParcelFeedbackModel.Page, _ store: UserDefaults, _ clock: Clock, fails: Bool = false) -> ParcelFeedbackModel {
        let model = ParcelFeedbackModel(memory: ParcelFeedbackMemory(defaults: store, now: { clock.now }), now: { clock.now },
                                        report: { _, _ in }, review: ReviewPrompt(defaults: store, version: "1.0.2", timeZone: .gmt))
        model.show(page, through: ParcelFeedbackClient { _ in
            if fails { throw DeliveryAPIError.serviceFailed(500) }
        })
        return model
    }
}
