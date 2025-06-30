//
//  View+Snapshot.swift
//
//
//  Created by Ryan Cole on 7/03/24.
//

import SwiftUI

extension View {
    @MainActor
    func snapshot() -> CGImage? {
        ImageRenderer(content: self).cgImage
    }
}
