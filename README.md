# SwiftUniversalMain

`SwiftUniversalMain` provides extensions to the Swift Main library, adding functionalities for string
manipulation, collection processing, and more.

This package currently lives as a private universal system library inside the
`swift-universal` collective. The package is intended to replace the old
legacy main-library dependency lane inside private `swift-universal` packages.

## 🔑 Key Features

- **🌐 Extended Swift Library**: Enhancements for string manipulation and collection processing.
- **🚀 Performance Oriented**: Optimized for efficiency and speed.
- **🔧 Versatile and Flexible**: Adaptable to a wide range of development needs.

## Compatibility

SwiftUniversalMain requires Swift 6.2 or later and supports:

- iOS 16+
- macOS 11+
- macCatalyst 13+
- tvOS 16+
- visionOS 1+
- watchOS 9+
- Linux

## 📦 Installation

To integrate `SwiftUniversalMain` into your project, follow these steps:

### Swift Package Manager

Add `SwiftUniversalMain` as a local monorepo dependency in your `Package.swift`
file:

```swift
dependencies: [
    .package(name: "swift-universal-main", path: "../swift-universal-main")
]
```

Include `SwiftUniversalMain` in your target dependencies:

```swift
targets: [
    .target(name: "YourTarget", dependencies: ["SwiftUniversalMain"]),
]
```

## 📚 Usage

Import `SwiftUniversalMain` and utilize its extensions:

1. **📥 Import the Library**:

   ```swift
   import SwiftUniversalMain
   ```

2. **🔨 Utilize Extensions**: Leverage various extensions for enhanced functionality:

Example Extensions:

### String Extensions

- `camelCaseToKebabCase()`: Convert a camelCase string to kebab-case.
- `containsUniqueChars()`: Check if a string contains all unique characters.
- `isPermutation(_:)`: Check if a string is a permutation of another string using a frequency-based
  comparison.
- `*` operator: Repeat a string by multiplying it with an integer.

### Collection Extensions

- `search(key:)`: Binary search in a collection.
- `mergeSort()`: Perform a merge sort on a collection.

### Protocol `AnyFlattenable`

- `flattened()`: Unwrap and flatten any value, potentially to `nil`.

### `Optional` Comparable Extension

- `Optional<T>` where `T: Comparable`: Adds `<` and `>` comparison operators for optional values
  without requiring a full `Comparable` conformance.

### Random String Utilities

See [Random.swift](Sources/SwiftUniversalMain/Random/Random.swift).

```swift
let ascii = Random.printableASCII(length: 8)
// For emoji and mixed strings, add the WrkstrmEmoji package and
// call EmojiRandomizer.emojiString(length:) or `.mixedString(...)`.
```

### JSON Helpers

See DocC: open the "SwiftUniversalMain" documentation in Xcode or `swift-docc` and start with the
[JSON Types Index](Sources/SwiftUniversalMain/Documentation.docc/JSONIndex.md). The `JSON` namespace is
split into small files for clarity.

[`KeyedDecodingContainer+FuzzyDecoding.swift`](Sources/SwiftUniversalMain/JSON/KeyedDecodingContainer+FuzzyDecoding.swift)
adds helpers for dealing with inconsistent API responses:

- `decodeAllowingNullOrEmptyObject` maps `null`, the string "null", or `{}` to `nil`.
- `decodeArrayAllowingNullOrSingle` normalizes `null`, a single object, or an array into an optional
  array.

These functions prevent decoding failures for "no data" placeholders while still throwing when a
value has an unexpected shape.

```swift
let object: JSON.AnyDictionary = ["name": "Alice", "age": 30]

struct Wrapper: Decodable {
    let item: Item?
    let items: [Item]?

    enum CodingKeys: String, CodingKey { case item, items }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        item = try container.decodeAllowingNullOrEmptyObject(Item.self, forKey: .item)
        items = try container.decodeArrayAllowingNullOrSingle(Item.self, forKey: .items)
    }
}
```

#### Bridged Writers (via SwiftUniversalFoundation)

SwiftUniversalFoundation extends this `JSON` namespace with human‑friendly writers and formatting:

- `JSON.Formatting.humanEncoder` / `JSON.Formatting.humanOptions`
- `JSON.FileWriter.write(_:,to:)` and `.writeJSONObject(_:,to:)`

Import SwiftUniversalFoundation alongside SwiftUniversalMain to access these APIs.

## 🏁 Flagship + Docs

SwiftUniversalMain is a flagship library: we pressure‑test best practices here (API design, DocC, tests,
observability). Explore the DocC articles under `Sources/SwiftUniversalMain/Documentation.docc/` for
symbol topics and indices.

### Path Utilities

Filter arrays of path strings using the `sourceFiles`, `nibFiles`, `baseLocalizedNibFiles`, and
`unlocalizedNibFiles` properties.

See the
[Source File Filters documentation](Sources/SwiftUniversalMain/Documentation.docc/SourceFileFilters.md) for
more examples.

```swift
let paths = ["View.swift", "Main.storyboard", "Base.lproj/Main.storyboard"]
let sources = paths.sourceFiles      // ["View.swift"]
let nibs = paths.nibFiles            // ["Main.storyboard", "Base.lproj/Main.storyboard"]
```

### Custom Collections

Custom collection types are available in
[BinaryTree.swift](Sources/SwiftUniversalMain/CustomCollections/Classes/BinaryTree.swift),
[SortedArray.swift](Sources/SwiftUniversalMain/CustomCollections/Structs/SortedArray.swift) and
[IndexedCollection.swift](Sources/SwiftUniversalMain/CustomCollections/Structs/IndexedCollection.swift).

```swift
let tree = BinaryTree(5)
tree.insert(3)
tree.insert(7)

var numbers = SortedArray(unsorted: [3, 1, 2])
numbers.insert(5)

for (index, element) in ["a", "b"].indexed() {
    print(index, element)
}
```

### `Injectable` Protocol Usage

See [Injectable.swift](Sources/SwiftUniversalMain/Protocols/Injectable.swift).

```swift
struct NetworkService { }

final class UserViewModel: Injectable {
    typealias Resource = NetworkService
    private var service: NetworkService?

    func inject(_ resource: NetworkService) { service = resource }
    func assertDependencies() { precondition(service != nil) }
}

let vm = UserViewModel()
vm.inject(NetworkService())
vm.assertDependencies()
```

## 🎨 Customization

`SwiftUniversalMain` is built with extension in mind. You can tailor it to fit your project by tapping into
a few key extension points:

- **Random generators** – Extend the `Random` namespace with custom routines for generating
  domain‑specific strings.

  ```swift
  extension Random {
      /// Random hexadecimal string
      public static func hex(length: Int) -> String {
          let hex = "0123456789ABCDEF"
          return String((0..<length).map { _ in hex.randomElement()! })
      }
  }
  ```

- **Custom collection types** – Build domain‑specific collections by composing existing types such
  as `SortedArray` or by conforming to Swift's `Collection` protocols.

These hooks make `SwiftUniversalMain` easy to integrate with project‑specific types and behaviors.

## 🧩 Dependency Injection

Adopt the `Injectable` protocol to keep dependencies loosely coupled. Conforming types can accept
resources from the outside and verify that everything is wired correctly.

```swift
struct NetworkService {
    func request(_ path: String) { /* ... */ }
}

final class UserViewModel: Injectable {
    typealias Resource = NetworkService
    private var service: NetworkService?

    func inject(_ resource: NetworkService) {
        service = resource
    }

    func assertDependencies() {
        precondition(service != nil, "NetworkService must be injected")
    }
}
```

See the [Injectable documentation](Sources/SwiftUniversalMain/Documentation.docc/Injectable.md) for a
deeper explanation and more examples.

## 🧪 Testing

Automated tests protect this library from regressions and document its expected behavior. They
surface edge cases—like the permutation bug captured by our failing regression test—and give
contributors confidence when refactoring. Please run `swift test` before submitting changes to
ensure the codebase remains stable.

## 🤝 Contributing

🌟 Contributions are what make the open-source community such an amazing place to learn, inspire,
and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

📄 Distributed under the MIT License. See `LICENSE` for more information.

## 📬 Contact

🔗 Package Home: `private/universal/substrate/collectives/swift-universal/private/universal/domain/system/spm/swift-universal-main`

## 💖 Acknowledgments

- Developed by github.com/@rismay

---
