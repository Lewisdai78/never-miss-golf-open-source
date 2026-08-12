import XCTest
@testable import NeverMissGolf

final class ReminderStateMachineTests: XCTestCase {
    func testEntrySchedulesDwellReminder() {
        let transition = ReminderReducer.reduce(state: .armedOutside, event: .entered)

        XCTAssertEqual(transition.state, .dwellPending)
        XCTAssertEqual(transition.command, .scheduleDwell)
    }

    func testRepeatedEntryDoesNotDuplicateReminder() {
        let transition = ReminderReducer.reduce(state: .dwellPending, event: .entered)

        XCTAssertEqual(transition.state, .dwellPending)
        XCTAssertEqual(transition.command, .none)
    }

    func testExitAlwaysCancelsReminderAndRearms() {
        let transition = ReminderReducer.reduce(state: .snoozed, event: .exited)

        XCTAssertEqual(transition.state, .armedOutside)
        XCTAssertEqual(transition.command, .cancelReminders)
    }

    func testNotTodaySuppressesCurrentVisit() {
        let transition = ReminderReducer.reduce(state: .prompted, event: .notToday)

        XCTAssertEqual(transition.state, .suppressedThisVisit)
        XCTAssertEqual(transition.command, .cancelReminders)
    }

    func testSnoozeNeverOpensWorkout() {
        let transition = ReminderReducer.reduce(state: .prompted, event: .snooze)

        XCTAssertEqual(transition.state, .snoozed)
        XCTAssertEqual(transition.command, .scheduleSnooze)
    }

    func testOpenWorkoutRequiresExplicitEvent() {
        let transition = ReminderReducer.reduce(state: .prompted, event: .openWorkout)

        XCTAssertEqual(transition.state, .workoutOpenRequested)
        XCTAssertEqual(transition.command, .requestWorkoutOpen)
    }

    func testUnknownConditionNeverSchedulesOrOpens() {
        let transition = ReminderReducer.reduce(state: .dwellPending, event: .conditionUnknown)

        XCTAssertEqual(transition.state, .needsRecheck)
        XCTAssertEqual(transition.command, .none)
    }
}

