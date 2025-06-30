# SnapshotsKit

A modern framework for snapshot testing SwiftUI views, built on top of the new Swift Testing framework.

## 📋 Description

SnapshotsKit provides a simple and powerful way to create snapshot tests for SwiftUI views. The framework automatically creates images of your views and compares them with saved reference images, allowing you to quickly detect visual regressions.

## ✨ Features

- 🎯 **Easy to use** - minimal code required to create snapshot tests
- 🔧 **Flexible configuration** - customizable recording modes and image formats
- 📱 **SwiftUI native support** - specifically designed for SwiftUI views
- 🧪 **Swift Testing integration** - uses the modern Swift Testing framework
- 📊 **Visual comparison** - automatic creation of comparison images for failed tests
- 🎨 **Multiple format support** - PNG, JPEG and other image formats

## 📦 Installation

### Swift Package Manager

Add SnapshotsKit to your project dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/SnapshotsKit.git", from: "1.0.0")
]
```

### Requirements

- iOS 18.0+
- Swift 6.0+
- Xcode 15.0+

## 🚀 Quick Start

### Basic Usage

```swift
import Testing
import SnapshotsKit
import SwiftUI

@MainActor
@Suite(.snapshots(record: .all))
struct MySnapshotTests {
    
    @Test
    func testButtonView() {
        let buttonView = Button("Tap me") {
            // action
        }
        .padding()
        
        assertSnapshot(of: buttonView, named: "button-view")
    }
    
    @Test
    func testCustomView() {
        assertSnapshot {
            VStack {
                Text("Title")
                    .font(.title)
                Text("Subtitle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        } named: "custom-stack-view"
    }
}
```

### Test Configuration

```swift
// Global configuration for entire test suite
@MainActor
@Suite(.snapshots(record: .failed))
struct ConfiguredTests {
    
    @Test
    func testWithCustomConfiguration() {
        // This test will use the configuration from Suite
        assertSnapshot(of: MyView(), named: "my-view")
    }
}

// Configuration for individual tests
@MainActor
struct IndividualTestConfiguration {
    
    @Test(.snapshots(record: .missing))
    func testWithIndividualConfig() {
        assertSnapshot(of: MyView(), named: "individual-config-view")
    }
}
```

## ⚙️ Configuration

### Recording Modes

```swift
// Record all snapshots (default)
.snapshots(record: .all)

// Record only failed tests
.snapshots(record: .failed)

// Record only missing snapshots
.snapshots(record: .missing)

// Don't record anything
.snapshots(record: .never)
```

### Custom Configuration

```swift
let customConfig = SnapshotTestingConfiguration(
    record: .failed,
    snapshotImageType: .jpeg,
    directoryName: "CustomSnapshots"
)

@Suite(.snapshots(customConfig))
struct CustomConfiguredTests {
    // tests with custom configuration
}
```

## 📁 File Structure

Snapshots are automatically saved in the following structure:

```
Tests/
├── YourTestFile.swift
└── __Snapshots__/
    ├── YourTestFile/
    │   ├── button-view.png
    │   ├── custom-stack-view.png
    │   └── button-view-FAILED.png (on test failure)
    └── AnotherTestFile/
        └── another-view.png
```

## 🔍 Debugging Failed Tests

When a snapshot test fails, SnapshotsKit automatically creates a comparison image showing:
- Original snapshot
- New snapshot
- Differences between them

This helps you quickly understand what changed in the view.

## 🛠️ API Reference

### Main Functions

#### `assertSnapshot(of:named:sourceLocation:)`

Creates a snapshot of a view and compares it with the saved one.

```swift
assertSnapshot(of: myView, named: "my-view")
```

#### `assertSnapshot(of:named:sourceLocation:)`

Creates a snapshot from a closure returning a view.

```swift
assertSnapshot {
    VStack {
        Text("Hello")
        Text("World")
    }
} named: "hello-world"
```

### Traits

#### `.snapshots(record:)`

Configures the snapshot recording mode for a test suite or individual test.

```swift
@Suite(.snapshots(record: .failed))
@Test(.snapshots(record: .missing))
```

## 🧪 Examples

### Testing Different States

```swift
@MainActor
@Suite(.snapshots(record: .all))
struct StateSnapshotTests {
    
    @Test
    func testLoadingState() {
        assertSnapshot(of: LoadingView(), named: "loading-state")
    }
    
    @Test
    func testErrorState() {
        assertSnapshot(of: ErrorView(message: "Loading error"), named: "error-state")
    }
    
    @Test
    func testSuccessState() {
        assertSnapshot(of: SuccessView(data: mockData), named: "success-state")
    }
}
```

### Testing Adaptability

```swift
@MainActor
struct AdaptiveSnapshotTests {
    
    @Test
    func testCompactLayout() {
        assertSnapshot {
            AdaptiveView()
                .frame(width: 320, height: 568) // iPhone SE
        } named: "compact-layout"
    }
    
    @Test
    func testRegularLayout() {
        assertSnapshot {
            AdaptiveView()
                .frame(width: 414, height: 896) // iPhone 11 Pro Max
        } named: "regular-layout"
    }
}
```

## 📄 License

SnapshotsKit is distributed under the MIT license. See the [LICENSE](LICENSE) file for details.

---

**Note**: This framework is under active development. The API may change in future versions.

