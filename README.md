# Foundation Models Framework: On-Device LLM for Swift

[![Swift](https://img.shields.io/badge/Swift-6.2+-F05138.svg?style=flat&logo=swift)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-26.0+-007AFF.svg?style=flat&logo=apple)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> Run Apple's ~3B parameter LLM entirely on-device. No API keys. No cloud. No cost per token.

---

## What Is Foundation Models Framework?

WWDC 2025 introduced the **Foundation Models framework**—Apple's most significant AI announcement for developers. It provides direct Swift access to the same on-device large language model that powers Apple Intelligence.

**Key characteristics:**
- **~3B parameters** running on Apple Silicon
- **100% on-device** — works offline, completely private
- **Zero API costs** — no tokens, no billing
- **Type-safe Swift API** — not just string in/string out

---

## Why This Matters

Before Foundation Models, on-device AI meant:
- Core ML with custom models (complex setup)
- Third-party SDKs (privacy concerns, costs)
- Server calls (latency, connectivity required)

Now you can do this:

```swift
import FoundationModels

let session = LanguageModelSession()
let response = try await session.respond(to: "Summarize this article...")
print(response.content)
```

That's a 3-billion parameter LLM in three lines of Swift.

---

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/dambertmunoz/dm-swift-ml-foundation-models", from: "1.0.0")
]
```

**Requirements:**
- iOS 26.0+ / macOS 26.0+
- Swift 6.2+
- Device with Apple Intelligence support

---

## Core Concepts

### 1. SystemLanguageModel

The entry point. Check availability before using:

```swift
import FoundationModels

let model = SystemLanguageModel.default

switch model.availability {
case .available:
    print("Ready to use")
case .unavailable(let reason):
    switch reason {
    case .deviceNotEligible:
        print("This device doesn't support Apple Intelligence")
    case .appleIntelligenceNotEnabled:
        print("User hasn't enabled Apple Intelligence")
    case .modelNotReady:
        print("Model is still downloading")
    }
}
```

**Specialized models:**

```swift
// General purpose (creative generation, Q&A)
let generalModel = SystemLanguageModel.default

// Optimized for tagging and extraction
let taggingModel = SystemLanguageModel(useCase: .contentTagging)
```

### 2. LanguageModelSession

Sessions maintain conversation context:

```swift
let session = LanguageModelSession(
    model: .default,
    instructions: {
        "You are a helpful iOS development assistant. Be concise."
    }
)

// First message
let response1 = try await session.respond(to: "What is SwiftUI?")

// Follow-up (session remembers context)
let response2 = try await session.respond(to: "Show me an example")
```

**Session configuration:**

```swift
let session = LanguageModelSession(
    model: SystemLanguageModel(useCase: .contentTagging),
    guardrails: .default,
    tools: [WeatherTool(), RestaurantTool()],
    instructions: { "Your system prompt here" }
)
```

### 3. Generation Options

Control model behavior:

```swift
let options = GenerationOptions(
    sampling: .greedy,           // Most deterministic
    temperature: 0.7,            // 0.0-2.0, higher = more creative
    maximumResponseTokens: 500   // Limit response length
)

let response = try await session.respond(
    to: "Write a haiku about Swift",
    options: options
)
```

**Sampling strategies:**

| Strategy | Use Case |
|----------|----------|
| `.greedy` | Deterministic, always picks most likely token |
| `.topK(k: 40)` | Sample from top 40 tokens |
| `.topP(p: 0.9)` | Nucleus sampling |
| `.topK(..., seed: 42)` | Reproducible results |

---

## Guided Generation: Type-Safe LLM Output

This is the killer feature. Instead of parsing JSON strings, you get native Swift types.

### The @Generable Macro

```swift
import FoundationModels

@Generable
struct MovieReview {
    let title: String
    let rating: Int
    let summary: String
    let pros: [String]
    let cons: [String]
}
```

The compiler generates a JSON schema automatically. The model outputs valid JSON that decodes directly to your struct.

**Using it:**

```swift
let review: MovieReview = try await session.respond(
    to: "Review the movie Inception",
    generating: MovieReview.self
).content
```

No JSON parsing. No string manipulation. Type-safe from model to Swift.

### The @Guide Macro

Add constraints and hints to individual fields:

```swift
@Generable
struct Restaurant {
    let name: String
    
    @Guide(description: "The type of cuisine served")
    let cuisine: String
    
    @Guide(.anyOf(["$", "$$", "$$$", "$$$$"]))
    let priceRange: String
    
    @Guide(.range(1...5))
    let rating: Int
    
    @Guide(.count(3))  // Exactly 3 items
    let topDishes: [String]
}
```

**Guide options:**

| Option | Description |
|--------|-------------|
| `description:` | Hint for the model |
| `.anyOf([...])` | Restrict to specific values |
| `.range(1...5)` | Numeric constraints |
| `.count(n)` | Exact array length |
| `.regex(pattern)` | String pattern matching |

### Enums Work Too

```swift
@Generable
enum Sentiment: String {
    case positive
    case negative
    case neutral
}

@Generable
struct SentimentAnalysis {
    let text: String
    let sentiment: Sentiment
    let confidence: Double
}
```

---

## Streaming: Real-Time UI Updates

Don't make users wait for complete responses:

```swift
@Generable
struct Article {
    let title: String
    let sections: [String]
    let conclusion: String
}

let stream = try await session.streamResponse(
    to: "Write an article about Swift concurrency",
    generating: Article.self
)

for try await partial in stream {
    // partial.title might be set while sections is still nil
    updateUI(with: partial)
}
```

The `PartiallyGenerated` type has all properties optional, filling in as generation progresses.

**SwiftUI integration:**

```swift
struct ArticleView: View {
    @State private var article: Article.PartiallyGenerated?
    
    var body: some View {
        VStack {
            if let title = article?.title {
                Text(title).font(.title)
            }
            
            ForEach(article?.sections ?? [], id: \.self) { section in
                Text(section)
            }
        }
        .task {
            await generateArticle()
        }
    }
    
    func generateArticle() async {
        let session = LanguageModelSession()
        let stream = try? await session.streamResponse(
            to: "Write about SwiftUI",
            generating: Article.self
        )
        
        for try await partial in stream ?? [] {
            article = partial
        }
    }
}
```

---

## Tool Calling: Extend the Model's Capabilities

The model can't access the internet or your data. Tools bridge that gap.

### Implementing a Tool

```swift
import FoundationModels

final class WeatherTool: Tool {
    let name = "getCurrentWeather"
    let description = "Get current weather for a location"
    
    @Generable
    struct Arguments {
        @Guide(description: "City name")
        let city: String
        
        @Guide(.anyOf(["celsius", "fahrenheit"]))
        let unit: String
    }
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        // Call WeatherKit or your API
        let weather = await WeatherService.fetch(
            city: arguments.city,
            unit: arguments.unit
        )
        
        return ToolOutput("""
            Weather in \(arguments.city):
            Temperature: \(weather.temp)°
            Condition: \(weather.condition)
            """)
    }
}
```

### Using Tools

```swift
let session = LanguageModelSession(
    tools: [WeatherTool(), RestaurantTool(), CalendarTool()]
)

// The model automatically calls tools when needed
let response = try await session.respond(
    to: "What's the weather in Tokyo and recommend a restaurant there"
)
// Model calls WeatherTool, then RestaurantTool, then synthesizes response
```

**Tool calling flow:**
1. Model receives prompt
2. Decides which tools to call (can be multiple, parallel or sequential)
3. Framework executes your `call()` methods
4. Model receives tool outputs
5. Model generates final response

---

## Advanced Patterns

### Prewarm for Instant Response

```swift
// Load model before user interaction
let session = LanguageModelSession()
try await session.prewarm(promptPrefix: "You are a helpful assistant")

// Later, response is faster
let response = try await session.respond(to: userInput)
```

### Check Generation Status

```swift
if session.isResponding {
    showLoadingIndicator()
}
```

### Access Conversation History

```swift
for entry in session.transcript {
    switch entry {
    case .prompt(let text):
        print("User: \(text)")
    case .response(let text):
        print("Assistant: \(text)")
    case .toolCall(let name, let args):
        print("Called tool: \(name)")
    }
}
```

### Error Handling

```swift
do {
    let response = try await session.respond(to: prompt)
} catch let error as LanguageModelSession.GenerationError {
    switch error {
    case .modelUnavailable:
        showUnavailableUI()
    case .guardrailViolation:
        showContentWarning()
    case .contextLengthExceeded:
        startNewSession()
    }
}
```

---

## Real-World Use Cases

| Use Case | Implementation |
|----------|----------------|
| **Summarization** | Pass long text, get structured summary |
| **Content tagging** | Use `.contentTagging` model + @Generable tags |
| **Form autofill** | Extract structured data from unstructured input |
| **Smart search** | Natural language to search filters |
| **Personalized recommendations** | Combine with user data via tools |
| **Accessibility** | Generate alt text, simplify content |

---

## Project Structure

```
Sources/FoundationModelsKit/
├── Core/
│   ├── Models/           # @Generable structs
│   │   ├── MovieReview.swift
│   │   ├── Restaurant.swift
│   │   └── SentimentAnalysis.swift
│   ├── Tools/            # Tool implementations
│   │   ├── WeatherTool.swift
│   │   └── SearchTool.swift
│   └── Session/          # Session management
│       └── AISessionManager.swift
└── UseCases/             # Real-world examples
    ├── ContentSummarizer.swift
    ├── SmartFormFiller.swift
    └── SentimentAnalyzer.swift

Examples/Demo/
└── main.swift            # Run: swift run Demo

Tests/
└── FoundationModelsKitTests/
```

---

## Run the Demo

```bash
git clone https://github.com/dambertmunoz/dm-swift-ml-foundation-models.git
cd dm-swift-ml-foundation-models
swift run Demo
```

**Note:** Requires a device with Apple Intelligence enabled (iPhone 15 Pro+, M-series Mac).

---

## Key Takeaways

1. **Foundation Models = on-device LLM** with zero cloud dependency
2. **@Generable gives you type-safe output** — no JSON parsing
3. **Streaming enables responsive UIs** — show progress as it generates
4. **Tools extend capabilities** — connect to your data and services
5. **Privacy by default** — everything stays on device

---

## Resources

- [Meet the Foundation Models framework (WWDC25)](https://developer.apple.com/videos/play/wwdc2025/286/)
- [Deep dive into Foundation Models (WWDC25)](https://developer.apple.com/videos/play/wwdc2025/301/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/FoundationModels)

---

## Author

**Dambert Muñoz** — Senior iOS Engineer

- [GitHub](https://github.com/dambertmunoz)
- [LinkedIn](https://linkedin.com/in/dambert-m-4b772397)

## License

MIT License - see [LICENSE](LICENSE) for details.
