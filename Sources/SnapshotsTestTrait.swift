//
//  File.swift
//  SnapshotsKit
//
//  Created by Татьяна Макеева on 01.02.2025.
//

import Testing

extension Trait where Self == _SnapshotsTestTrait {
  /// Configure snapshot testing in a suite or test.
  ///
  /// - Parameters:
  ///   - record: The record mode of the test.
  public static func snapshots(
    record: SnapshotTestingConfiguration.Record = .all
  ) -> Self {
    _SnapshotsTestTrait(
      configuration: SnapshotTestingConfiguration(
        record: record
      )
    )
  }

  /// Configure snapshot testing in a suite or test.
  ///
  /// - Parameter configuration: The configuration to use.
  public static func snapshots(
    _ configuration: SnapshotTestingConfiguration
  ) -> Self {
    _SnapshotsTestTrait(configuration: configuration)
  }
}

/// A type representing the configuration of snapshot testing.
public struct _SnapshotsTestTrait: SuiteTrait, TestTrait {
  public let isRecursive = true
  let configuration: SnapshotTestingConfiguration
}
