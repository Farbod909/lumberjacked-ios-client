//
//  EditableSetTests.swift
//  LumberjackedTests
//

import XCTest
@testable import Lumberjacked

final class EditableSetTests: XCTestCase {

    // MARK: - Init from LogSet

    func testInitFromLogSetCopiesAllFields() {
        let logSet = LogSet(reps: 10, load: 135.5, type: "working", rest_time: 120)
        let editable = EditableSet(from: logSet)

        XCTAssertEqual(editable.reps, "10")
        XCTAssertEqual(editable.load, 135.5)
        XCTAssertEqual(editable.type, "working")
        XCTAssertEqual(editable.rest_time, 120)
        XCTAssertFalse(editable.isChecked)
    }

    func testInitFromLogSetWithNilLoad() {
        let logSet = LogSet(reps: 8, load: nil, type: "warmup", rest_time: nil)
        let editable = EditableSet(from: logSet)

        XCTAssertNil(editable.load)
        XCTAssertNil(editable.rest_time)
    }

    // MARK: - Init from TemplateSet

    func testInitFromTemplateSetCopiesAllFields() {
        let templateSet = TemplateSet(reps: "8-10", type: "working", rest_time: 120)
        let editable = EditableSet(from: templateSet)

        XCTAssertEqual(editable.reps, "8-10")
        XCTAssertEqual(editable.type, "working")
        XCTAssertEqual(editable.rest_time, 120)
    }

    func testInitFromTemplateSetFreeTextReps() {
        let templateSet = TemplateSet(reps: "AMRAP", type: "failure", rest_time: nil)
        let editable = EditableSet(from: templateSet)

        XCTAssertEqual(editable.reps, "AMRAP")
        XCTAssertNil(editable.rest_time)
    }

    // MARK: - Conversion to LogSet

    func testAsLogSetConvertsRepsToInt() {
        var editable = EditableSet(type: "working", reps: "12", load: 200.0, rest_time: 90)
        let logSet = editable.asLogSet

        XCTAssertEqual(logSet.reps, 12)
        XCTAssertEqual(logSet.load, 200.0)
        XCTAssertEqual(logSet.type, "working")
        XCTAssertEqual(logSet.rest_time, 90)
    }

    func testAsLogSetWithInvalidRepsFallsBackToZero() {
        var editable = EditableSet(type: "working", reps: "abc", load: nil, rest_time: nil)
        XCTAssertEqual(editable.asLogSet.reps, 0)
    }

    func testAsLogSetWithEmptyRepsFallsBackToZero() {
        var editable = EditableSet(type: "working", reps: "", load: nil, rest_time: nil)
        XCTAssertEqual(editable.asLogSet.reps, 0)
    }

    // MARK: - Conversion to TemplateSet

    func testAsTemplateSetPreservesStringReps() {
        var editable = EditableSet(type: "working", reps: "8-10", load: nil, rest_time: 120)
        let templateSet = editable.asTemplateSet

        XCTAssertEqual(templateSet.reps, "8-10")
        XCTAssertEqual(templateSet.type, "working")
        XCTAssertEqual(templateSet.rest_time, 120)
    }

    // MARK: - Set type display

    func testDisplayLabelForWarmup() {
        let editable = EditableSet(type: "warmup", reps: "5", load: nil, rest_time: nil)
        XCTAssertEqual(editable.displayLabel(workingSetIndex: 1), "W")
    }

    func testDisplayLabelForFailure() {
        let editable = EditableSet(type: "failure", reps: "0", load: nil, rest_time: nil)
        XCTAssertEqual(editable.displayLabel(workingSetIndex: 1), "F")
    }

    func testDisplayLabelForMyoreps() {
        let editable = EditableSet(type: "myoreps", reps: "0", load: nil, rest_time: nil)
        XCTAssertEqual(editable.displayLabel(workingSetIndex: 1), "M")
    }

    func testDisplayLabelForWorkingSetUsesIndex() {
        let editable = EditableSet(type: "working", reps: "10", load: nil, rest_time: nil)
        XCTAssertEqual(editable.displayLabel(workingSetIndex: 3), "3")
    }

    func testDisplayLabelUnknownTypeFallsBackToWorking() {
        let editable = EditableSet(type: "unknown", reps: "5", load: nil, rest_time: nil)
        // SetType init falls back to .working
        XCTAssertEqual(editable.displayLabel(workingSetIndex: 2), "2")
    }

    // MARK: - Working set numbering

    func testWorkingSetIndexCountsOnlyWorkingSets() {
        let sets: [EditableSet] = [
            EditableSet(type: "warmup",  reps: "5",  load: nil, rest_time: nil),
            EditableSet(type: "working", reps: "10", load: nil, rest_time: nil),
            EditableSet(type: "working", reps: "10", load: nil, rest_time: nil),
            EditableSet(type: "failure", reps: "8",  load: nil, rest_time: nil),
            EditableSet(type: "working", reps: "10", load: nil, rest_time: nil),
        ]
        XCTAssertEqual(sets.workingSetIndex(for: sets[1].id), 1)
        XCTAssertEqual(sets.workingSetIndex(for: sets[2].id), 2)
        XCTAssertEqual(sets.workingSetIndex(for: sets[4].id), 3)
    }

    func testWorkingSetIndexWithNoWorkingSets() {
        let sets: [EditableSet] = [
            EditableSet(type: "warmup", reps: "5", load: nil, rest_time: nil),
        ]
        // Warmup is not counted; index returned is the current counter = 1
        XCTAssertEqual(sets.workingSetIndex(for: sets[0].id), 1)
    }

    // MARK: - Default working set

    func testDefaultWorkingSetCopiesRestTimeFromPrior() {
        let prior = EditableSet(type: "working", reps: "10", load: 135, rest_time: 90)
        let newSet = EditableSet.defaultWorkingSet(copyingRestFrom: prior)

        XCTAssertEqual(newSet.type, "working")
        XCTAssertEqual(newSet.rest_time, 90)
        XCTAssertEqual(newSet.reps, "")
        XCTAssertNil(newSet.load)
    }

    func testDefaultWorkingSetWithNoPriorHasNilRestTime() {
        let newSet = EditableSet.defaultWorkingSet(copyingRestFrom: nil)
        XCTAssertNil(newSet.rest_time)
    }

    // MARK: - Set type mutation

    func testSetTypeChangesTypeString() {
        var editable = EditableSet(type: "working", reps: "10", load: nil, rest_time: nil)
        editable.setType = .warmup
        XCTAssertEqual(editable.type, "warmup")
    }

    // MARK: - Round-trip

    func testRoundTripLogSet() {
        let original = LogSet(reps: 8, load: 185.5, type: "failure", rest_time: 60)
        let editable = EditableSet(from: original)
        let result = editable.asLogSet

        XCTAssertEqual(result.reps, original.reps)
        XCTAssertEqual(result.load, original.load)
        XCTAssertEqual(result.type, original.type)
        XCTAssertEqual(result.rest_time, original.rest_time)
    }

    func testRoundTripTemplateSet() {
        let original = TemplateSet(reps: "6-8", type: "myoreps", rest_time: 30)
        let editable = EditableSet(from: original)
        let result = editable.asTemplateSet

        XCTAssertEqual(result.reps, original.reps)
        XCTAssertEqual(result.type, original.type)
        XCTAssertEqual(result.rest_time, original.rest_time)
    }
}
