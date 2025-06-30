//
//  File.swift
//  SnapshotsKit
//
//  Created by Татьяна Макеева on 01.02.2025.
//

import Foundation
import UniformTypeIdentifiers

/// The configuration for a snapshot test.
public struct SnapshotTestingConfiguration: Sendable {
    @_spi(Internals)
    @TaskLocal public static var current: Self = .default
    
    /// The recording strategy to use while running snapshot tests.
    public let record: Record

    public let snapshotImageType: UTType
    
    public let directoryName: String
    
    public init(
        record: Record,
        snapshotImageType: UTType = .png,
        directoryName: String = "__Snapshots__"
    ) {
        self.record = record
        self.snapshotImageType = snapshotImageType
        self.directoryName = directoryName
    }
    
    /// The record mode of the snapshot test.
    public struct Record: OptionSet, Equatable, Sendable {
        public let rawValue: Int
        /// Records all snapshots to disk, no matter what.
        public static let all: Self = [.failed, .missing]
        
        /// Does not record any snapshots. If a snapshot is missing a test failure will be raised. This
        /// option is appropriate when running tests on CI so that re-tries of tests do not
        /// surprisingly pass after snapshots are unexpectedly generated.
        public static let never: Self = []
        /// Records snapshots for assertions that fail. This can be useful for tests that use precision
        /// thresholds so that passing tests do not re-record snapshots that are subtly different but
        /// still within the threshold.
        public static let failed = Self(rawValue: 1 << 1)
        /// Records only the snapshots that are missing from disk.
        public static let missing = Self(rawValue: 1 << 2)
        
        // TODO: override action
        public static let override = Self(rawValue: 2)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

extension SnapshotTestingConfiguration {
    static let `default` = SnapshotTestingConfiguration(
        record: .all
    )
}
