// The Swift Programming Language
// https://docs.swift.org/swift-book

import CoreGraphics
import SwiftUI
import Testing
import UniformTypeIdentifiers

@MainActor @_spi(Internals)
public var _configuration: SnapshotTestingConfiguration {
    get {
        if let test = Test.current {
            for trait in test.traits.reversed() {
                if let configuration = (trait as? _SnapshotsTestTrait)?.configuration {
                    return configuration
                }
            }
        }
        return SnapshotTestingConfiguration.current
    }
}

@MainActor
/// Assert in SwiftUI view against a saved snapshot which is identified by the `named` parameter.
/// - Parameters:
///   - of: The closure that contains the view to snapshot.
///   - named: The name of the snapshot file to compare against and or save the new snapshot under.
///   - sourceLocation: Location in source code.
public func assertSnapshot<V>(
    @ViewBuilder of view: () -> V,
    named: String,
    sourceLocation: SourceLocation = #_sourceLocation
) where V : View {
    assertSnapshot(of: view(), named: named, sourceLocation: sourceLocation)
}

@MainActor
/// Assert in SwiftUI view against a saved snapshot which is identified by the `named` parameter.
/// - Parameters:
///   - view: The view to snapshot.
///   - named: The name of the snapshot file to compare against and or save the new snapshot under.
///   - sourceLocation: Location in source code.
public func assertSnapshot<V>(
    of view: V,
    named: String,
    sourceLocation: SourceLocation = #_sourceLocation
) where V : View {
    do {
        try runSnapshot(of: view, named: named, sourceLocation: sourceLocation)
    } catch let error as SnapshotError {
        Issue.record(error, sourceLocation: sourceLocation)
    } catch {
        Issue.record("Failed to run snapshot tests.", sourceLocation: sourceLocation)
    }
}

@MainActor
func runSnapshot<V>(
    of view: V,
    named: String,
    sourceLocation: SourceLocation = #_sourceLocation
) throws where V : View {
    guard let newImage = view.snapshot() else {
        throw SnapshotError.failedToCreateSnapshotImage
    }
    
    let configuration = _configuration
    let record = configuration.record
    
    let directoryName = configuration.directoryName
    let imageType = configuration.snapshotImageType
    
    try createSnapshotDirectory(testFilePath: sourceLocation._filePath, directoryName: directoryName)
    let snapshotURL = getSnapshotUrl(testFilePath: sourceLocation._filePath, named: named, directoryName: directoryName, imageType: imageType)
    
    if record.contains(.missing),
       !FileManager.default.fileExists(atPath: snapshotURL.path()) {
        try saveSnapshot(
            image: newImage,
            url: snapshotURL,
            imageType: imageType
        )
        throw SnapshotError.recordMissingSnapshot
    }
    
    guard let previousImage = getSavedSnapshot(url: snapshotURL) else {
        try saveSnapshot(
            image: newImage,
            url: snapshotURL,
            imageType: imageType
        )
        throw SnapshotError.failedToFindSnapshot
    }
    
    if newImage.pngData() != previousImage.pngData() {
        
        if record.contains(.failed) ||
            ProcessInfo.processInfo.arguments.contains("SNAPSHOT_SAVE_FAILURE_COMPARISON")  {
            let snapshotComparisonImage = try createFailedSnapshotComparison(
                savedSnapshot: previousImage,
                newSnapshot: newImage
            )
            let snapshotFailedURL = getSnapshotUrl(
                testFilePath: sourceLocation._filePath,
                named: "\(named)-FAILED",
                directoryName: directoryName,
                imageType: imageType
            )
            try saveSnapshot(
                image: snapshotComparisonImage,
                url: snapshotFailedURL,
                imageType: imageType
            )
        }
        
        throw SnapshotError.notMatch
    }
}

private func createSnapshotDirectory(testFilePath: String, directoryName: String) throws {
    let snapshotTestDirectoryUrl = getSnapshotDirectoryUrl(
        testFilePath: testFilePath,
        directoryName: directoryName
    )
    
    try FileManager.default.createDirectory(at: snapshotTestDirectoryUrl, withIntermediateDirectories: true)
}

private func getSavedSnapshot(url: URL) -> CGImage? {
    
    guard FileManager.default.fileExists(atPath: url.path()) else {
        return nil
    }
    
    guard let image = UIImage(contentsOfFile: url.path())?.cgImage else {
        return nil
    }
    
    return image
}

private func saveSnapshot(image: CGImage, url: URL, imageType: UTType) throws {
    try writeCGImage(image, to: url, imageType: imageType)
}

private func writeCGImage(_ image: CGImage, to destinationURL: URL, imageType: UTType) throws {
    guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, imageType.identifier as CFString, 1, nil) else {
        throw SnapshotError.snapshotNotSaved
    }
    CGImageDestinationAddImage(destination, image, nil)
    if !CGImageDestinationFinalize(destination) {
        throw SnapshotError.snapshotNotSaved
    }
}

private func deleteSnapshots(url: URL) throws {
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: url.path()) {
        try fileManager.removeItem(at: url)
    }
}

private func createFailedSnapshotComparison(savedSnapshot: CGImage, newSnapshot: CGImage) throws -> CGImage {
    
    let verticalSpacing: Int = 8
    let horizontalSpacing: Int = 4
    let fontSize: Int = 14
    let headerSpacing = fontSize + horizontalSpacing
    
    let maxWidth = max(savedSnapshot.width, newSnapshot.width)
    let maxHeight = max(savedSnapshot.height, newSnapshot.height)
    
    let width = (maxWidth * 2) + verticalSpacing
    let height = (maxHeight * 2) + (headerSpacing * 2)
    
    let size = CGSize(
        width: width,
        height: height
    )
    
    var savedTitlePoint: CGPoint {
        CGPoint(x: 0, y: 0)
    }
    
    var savedImagePoint: CGPoint {
        CGPoint(x: 0, y: savedSnapshot.height + headerSpacing)
    }
    
    var newTitlePoint: CGPoint {
        CGPoint(x: savedSnapshot.width + verticalSpacing, y: 0)
    }
    
    var newImagePoint: CGPoint {
        CGPoint(x: savedSnapshot.width + verticalSpacing, y: savedSnapshot.height + headerSpacing)
    }
    
    var overlayTitlePoint: CGPoint {
        CGPoint(x: 0, y: savedSnapshot.height + headerSpacing)
    }
    
    var overlayImagePoint: CGPoint {
        CGPoint(x: 0, y: 0)
    }
    
    guard
        let colorspace = CGColorSpace(name: CGColorSpace.sRGB),
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 16,
            bytesPerRow: 0,
            space: colorspace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue |
            CGBitmapInfo.byteOrder16Little.rawValue |
            CGBitmapInfo.floatComponents.rawValue
        ) else {
        throw SnapshotError.faliedToCompare
    }
    
    UIGraphicsPushContext(context)

    let translate = CGAffineTransform(translationX: 0.0, y: size.height).scaledBy(x: 1.0, y: -1.0)
    context.concatenate(translate)
    
    let savedTitle = "Saved Snapshot"
    savedTitle.draw(at: savedTitlePoint, withAttributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
        NSAttributedString.Key.foregroundColor: UIColor.black
    ])
    
    context.concatenate(translate.inverted())
    
    context.draw(savedSnapshot, in: CGRect(origin: savedImagePoint, size: CGSize(width: savedSnapshot.width, height: savedSnapshot.height)))
    context.concatenate(translate)
    
    let newTitle = "New Snapshot"
    newTitle.draw(at: newTitlePoint, withAttributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
        NSAttributedString.Key.foregroundColor: UIColor.black
    ])
    
    context.concatenate(translate.inverted())
    context.draw(newSnapshot, in: CGRect(origin: newImagePoint, size: CGSize(width: newSnapshot.width, height: newSnapshot.height)))
    
    // Draw new snapshot on top of the saved snapshot for comparison with 50% opacity and the title "Overlay"
    context.concatenate(translate)
    let overlayTitle = "Both Overlayed"
    overlayTitle.draw(at: overlayTitlePoint, withAttributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
        NSAttributedString.Key.foregroundColor: UIColor.black
    ])
    
    context.concatenate(translate.inverted())
    context.draw(savedSnapshot, in: CGRect(origin: overlayImagePoint, size: CGSize(width: savedSnapshot.width, height: savedSnapshot.height)))
    context.setAlpha(0.5)
    context.draw(newSnapshot, in: CGRect(origin: overlayImagePoint, size: CGSize(width: newSnapshot.width, height: newSnapshot.height)))
    
    UIGraphicsPopContext()
    
    guard let image = context.makeImage() else {
        throw SnapshotError.faliedToCompare
    }
    return image
}

private func getSnapshotDirectoryUrl(testFilePath: String, directoryName: String) -> URL {
    let testFileUrl = URL(filePath: String(testFilePath))
    let testFileName = testFileUrl.lastPathComponent.split(separator: ".").first ?? "unknown"
    
    return testFileUrl
        .deletingLastPathComponent()
        .appending(path: directoryName)
        .appending(path: testFileName)
}

private func getSnapshotUrl(testFilePath: String, named: String, directoryName: String, imageType: UTType) -> URL {
    
    let snapshotName = "\(named).\(imageType.preferredFilenameExtension!)"
    let snapshotTestDirectoryUrl = getSnapshotDirectoryUrl(testFilePath: testFilePath, directoryName: directoryName)
    
    return snapshotTestDirectoryUrl.appending(path: snapshotName)
}

extension CGImage {
    fileprivate func pngData() -> Data? {
        let cfdata: CFMutableData = CFDataCreateMutable(nil, 0)
        if let destination = CGImageDestinationCreateWithData(cfdata, UTType.png.identifier as CFString, 1, nil) {
            CGImageDestinationAddImage(destination, self, nil)
            if CGImageDestinationFinalize(destination) {
                return cfdata as Data
            }
        }
        
        return nil
    }
}
