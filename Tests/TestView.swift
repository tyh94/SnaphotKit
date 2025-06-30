//
//  TestView.swift
//
//
//  Created by Ryan Cole on 7/03/24.
//

import Testing
import SwiftUI
@testable import SnapshotsKit

@Suite(.snapshots(record: .all))
struct SnapshotsKitRecordAllTests {
    @Test func testView() async throws {
        await assertSnapshot(of: Text("Hello World!"), named: "hello-world")
    }
    
    @Test func testFailedView() async throws {
        do {
            try await runSnapshot(of: Text("Hello World1!"), named: "hello-world")
        } catch {
            let error = try #require(error as? SnapshotError)
            #expect(error == SnapshotError.notMatch)
        }
    }
    
    @Test func testRecordMissing() async throws {
        do {
            try await runSnapshot(of: Text("Hello World!"), named: "missing")
        } catch {
            let error = try #require(error as? SnapshotError)
            #expect(error == SnapshotError.recordMissingSnapshot)
        }
    }
}
