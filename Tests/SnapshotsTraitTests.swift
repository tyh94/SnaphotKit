//
//  File.swift
//  SnapshotsKit
//
//  Created by Татьяна Макеева on 01.02.2025.
//

import Testing
@_spi(Internals) import SnapshotsKit

@MainActor
@Suite(.snapshots(record: .all))
struct SnapshotsTraitTests {
    @Test
    func config() {
        #expect(_configuration.record == .all)
    }
}

@MainActor
@Suite(.snapshots(record: .failed))
struct OverrideDiffToolAndRecord {
    @Test
    func config() {
        #expect(_configuration.record == .failed)
    }
}
