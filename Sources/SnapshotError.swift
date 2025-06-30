//
//  SnapshotError.swift
//  GoutTracker
//
//  Created by Татьяна Макеева on 10.02.2025.
//

import Testing

enum SnapshotError: Comment, Error {
    case snapshotNotSaved
    case faliedToCompare
    case failedToCreateSnapshotImage = "Failed to create a snapshot image."
    case recordMissingSnapshot = "Record missing snapshot"
    case failedToFindSnapshot = "Failed to find an existing snapshot."
    case notMatch = "Snapshots do not match."
}
