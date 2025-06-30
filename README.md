# SnapshotsKit

Современный фреймворк для снепшот-тестирования SwiftUI представлений, построенный на основе нового Swift Testing framework.

## 📋 Описание

SnapshotsKit предоставляет простой и мощный способ создания снепшот-тестов для SwiftUI представлений. Фреймворк автоматически создает изображения ваших представлений и сравнивает их с сохраненными эталонными изображениями, что позволяет быстро обнаруживать визуальные регрессии.

## ✨ Особенности

- 🎯 **Простота использования** - минимальный код для создания снепшот-тестов
- 🔧 **Гибкая конфигурация** - настройка режимов записи и форматов изображений
- 📱 **SwiftUI нативная поддержка** - специально разработан для SwiftUI представлений
- 🧪 **Swift Testing интеграция** - использует современный Swift Testing framework
- 📊 **Визуальное сравнение** - автоматическое создание изображений сравнения при неудачных тестах
- 🎨 **Поддержка различных форматов** - PNG, JPEG и другие форматы изображений

## 📦 Установка

### Swift Package Manager

Добавьте SnapshotsKit в зависимости вашего проекта:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/SnapshotsKit.git", from: "1.0.0")
]
```

### Требования

- iOS 18.0+
- Swift 6.0+
- Xcode 15.0+

## 🚀 Быстрый старт

### Базовое использование

```swift
import Testing
import SnapshotsKit
import SwiftUI

@MainActor
@Suite(.snapshots(record: .all))
struct MySnapshotTests {
    
    @Test
    func testButtonView() {
        let buttonView = Button("Нажми меня") {
            // действие
        }
        .padding()
        
        assertSnapshot(of: buttonView, named: "button-view")
    }
    
    @Test
    func testCustomView() {
        assertSnapshot {
            VStack {
                Text("Заголовок")
                    .font(.title)
                Text("Подзаголовок")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        } named: "custom-stack-view"
    }
}
```

### Конфигурация тестов

```swift
// Глобальная конфигурация для всего тестового набора
@MainActor
@Suite(.snapshots(record: .failed))
struct ConfiguredTests {
    
    @Test
    func testWithCustomConfiguration() {
        // Этот тест будет использовать конфигурацию из Suite
        assertSnapshot(of: MyView(), named: "my-view")
    }
}

// Конфигурация для отдельных тестов
@MainActor
struct IndividualTestConfiguration {
    
    @Test(.snapshots(record: .missing))
    func testWithIndividualConfig() {
        assertSnapshot(of: MyView(), named: "individual-config-view")
    }
}
```

## ⚙️ Конфигурация

### Режимы записи

```swift
// Записывать все снепшоты (по умолчанию)
.snapshots(record: .all)

// Записывать только неудачные тесты
.snapshots(record: .failed)

// Записывать только отсутствующие снепшоты
.snapshots(record: .missing)

// Не записывать ничего
.snapshots(record: .never)
```

### Пользовательская конфигурация

```swift
let customConfig = SnapshotTestingConfiguration(
    record: .failed,
    snapshotImageType: .jpeg,
    directoryName: "CustomSnapshots"
)

@Suite(.snapshots(customConfig))
struct CustomConfiguredTests {
    // тесты с пользовательской конфигурацией
}
```

## 📁 Структура файлов

Снепшоты автоматически сохраняются в следующей структуре:

```
Tests/
├── YourTestFile.swift
└── __Snapshots__/
    ├── YourTestFile/
    │   ├── button-view.png
    │   ├── custom-stack-view.png
    │   └── button-view-FAILED.png (при неудачном тесте)
    └── AnotherTestFile/
        └── another-view.png
```

## 🔍 Отладка неудачных тестов

При неудачном снепшот-тесте SnapshotsKit автоматически создает изображение сравнения, показывающее:
- Оригинальный снепшот
- Новый снепшот
- Различия между ними

Это помогает быстро понять, что изменилось в представлении.

## 🛠️ API Reference

### Основные функции

#### `assertSnapshot(of:named:sourceLocation:)`

Создает снепшот представления и сравнивает его с сохраненным.

```swift
assertSnapshot(of: myView, named: "my-view")
```

#### `assertSnapshot(of:named:sourceLocation:)`

Создает снепшот из замыкания, возвращающего представление.

```swift
assertSnapshot {
    VStack {
        Text("Hello")
        Text("World")
    }
} named: "hello-world"
```

### Трейты

#### `.snapshots(record:)`

Настраивает режим записи снепшотов для тестового набора или отдельного теста.

```swift
@Suite(.snapshots(record: .failed))
@Test(.snapshots(record: .missing))
```

## 🧪 Примеры

### Тестирование различных состояний

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
        assertSnapshot(of: ErrorView(message: "Ошибка загрузки"), named: "error-state")
    }
    
    @Test
    func testSuccessState() {
        assertSnapshot(of: SuccessView(data: mockData), named: "success-state")
    }
}
```

### Тестирование адаптивности

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

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие SnapshotsKit! Пожалуйста, создавайте issues для багов и feature requests, а также pull requests для улучшений.

## 📄 Лицензия

SnapshotsKit распространяется под лицензией MIT. См. файл [LICENSE](LICENSE) для подробностей.

## 👥 Авторы

- Татьяна Макеева - основной разработчик

---

**Примечание**: Этот фреймворк находится в активной разработке. API может изменяться в будущих версиях.

