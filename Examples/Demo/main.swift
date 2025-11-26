//
//  main.swift
//  FoundationModelsDemo
//
//  Created by Dambert Muñoz
//
//  Executable demo showcasing Foundation Models Framework capabilities
//

import Foundation
import FoundationModelsKit

// MARK: - Demo Runner

@main
struct FoundationModelsDemo {
    
    static func main() async {
        print("""
        ════════════════════════════════════════════════════════════
        🧠 Foundation Models Framework Demo
        ════════════════════════════════════════════════════════════
        
        This demo showcases Apple's on-device LLM capabilities
        introduced in iOS 26 / macOS 26.
        
        Features demonstrated:
        • @Generable structured output
        • @Guide constraints validation
        • Tool integration
        • Session management
        • Real-world use cases
        
        """)
        
        // Run all demos
        await runModelStructuresDemo()
        await runSentimentAnalysisDemo()
        await runContentExtractionDemo()
        await runToolIntegrationDemo()
        await runSessionManagementDemo()
        
        print("""
        
        ════════════════════════════════════════════════════════════
        ✅ Demo Complete!
        ════════════════════════════════════════════════════════════
        
        Repository: github.com/dambertmunoz/dm-swift-ml-foundation-models
        Author: Dambert Muñoz - Senior iOS Engineer
        """)
    }
}

// MARK: - Demo: Model Structures

func runModelStructuresDemo() async {
    print("""
    
    ────────────────────────────────────────────────────────────
    📝 Demo 1: @Generable Model Structures
    ────────────────────────────────────────────────────────────
    
    The @Generable macro enables type-safe structured output from LLM.
    Combined with @Guide constraints, you get validated, predictable results.
    
    """)
    
    // MovieReview example
    print("  ▶ MovieReview Structure:")
    let review = MovieReview(
        title: "Inception",
        sentiment: .positive,
        rating: 9,
        themes: ["Dreams", "Reality", "Time", "Memory"],
        summary: "A mind-bending thriller that challenges perception of reality through layered dream sequences.",
        isRecommended: true
    )
    print("    Title: \(review.title)")
    print("    Sentiment: \(review.sentiment.rawValue)")
    print("    Rating: \(review.rating)/10")
    print("    Themes: \(review.themes.joined(separator: ", "))")
    print("    Recommended: \(review.isRecommended ? "Yes" : "No")")
    
    // Restaurant example
    print("\n  ▶ Restaurant Structure (nested types):")
    let restaurant = Restaurant(
        name: "Sakura Garden",
        cuisineType: "Japanese",
        priceRange: .upscale,
        location: RestaurantLocation(
            address: "123 Cherry Blossom Ave",
            city: "San Francisco",
            neighborhood: "Japantown",
            zipCode: "94115"
        ),
        hours: OperatingHours(
            openTime: "11:30",
            closeTime: "22:00",
            daysOpen: [.tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        ),
        features: [.reservations, .vegetarianOptions, .outdoorSeating],
        rating: 4.7
    )
    print("    Name: \(restaurant.name)")
    print("    Cuisine: \(restaurant.cuisineType)")
    print("    Price: \(restaurant.priceRange.rawValue)")
    print("    Rating: \(restaurant.rating)/5.0")
    print("    Location: \(restaurant.location.neighborhood), \(restaurant.location.city)")
    print("    Features: \(restaurant.features.map { $0.rawValue }.joined(separator: ", "))")
}

// MARK: - Demo: Sentiment Analysis

func runSentimentAnalysisDemo() async {
    print("""
    
    ────────────────────────────────────────────────────────────
    😊 Demo 2: Sentiment Analysis
    ────────────────────────────────────────────────────────────
    
    Fine-grained emotion detection with confidence scores.
    @Guide constraints ensure valid ranges and categories.
    
    """)
    
    let analysis = SentimentAnalysis(
        primarySentiment: .positive,
        confidence: 0.87,
        emotions: [
            EmotionScore(emotion: .joy, intensity: 0.8),
            EmotionScore(emotion: .anticipation, intensity: 0.6),
            EmotionScore(emotion: .trust, intensity: 0.5)
        ],
        keyPhrases: ["absolutely loved", "exceeded expectations", "highly recommend"],
        tone: .casual,
        subjectivity: 0.75
    )
    
    print("  Sample Analysis Result:")
    print("    Primary: \(analysis.primarySentiment.rawValue)")
    print("    Confidence: \(String(format: "%.0f", analysis.confidence * 100))%")
    print("    Tone: \(analysis.tone.rawValue)")
    print("    Subjectivity: \(String(format: "%.0f", analysis.subjectivity * 100))%")
    print("\n    Emotions Detected:")
    for emotion in analysis.emotions {
        let bar = String(repeating: "█", count: Int(emotion.intensity * 10))
        print("      \(emotion.emotion.rawValue.padding(toLength: 12, withPad: " ", startingAt: 0)) \(bar) \(String(format: "%.0f", emotion.intensity * 100))%")
    }
    print("\n    Key Phrases: \(analysis.keyPhrases.joined(separator: ", "))")
}

// MARK: - Demo: Content Extraction

func runContentExtractionDemo() async {
    print("""
    
    ────────────────────────────────────────────────────────────
    📋 Demo 3: Smart Form Filling
    ────────────────────────────────────────────────────────────
    
    Extract structured data from unstructured text.
    @Guide with regex ensures proper format validation.
    
    """)
    
    // Contact extraction example
    print("  ▶ Contact Information Extraction:")
    print("""    
        Input: "Hi, I'm John Smith from TechCorp. Reach me at
                john.smith@techcorp.com or 415-555-0123."
    """)
    
    let contact = ContactInfo(
        firstName: "John",
        lastName: "Smith",
        email: "john.smith@techcorp.com",
        phone: "415-555-0123",
        company: "TechCorp",
        jobTitle: "",
        address: "",
        socialMedia: []
    )
    
    print("\n    Extracted:")
    print("      Name: \(contact.firstName) \(contact.lastName)")
    print("      Email: \(contact.email)")
    print("      Phone: \(contact.phone)")
    print("      Company: \(contact.company)")
    
    // Event extraction example
    print("\n  ▶ Event Information Extraction:")
    let event = EventInfo(
        title: "Swift Meetup",
        date: "2025-02-15",
        time: "6:00 PM - 9:00 PM",
        location: "Apple Park Visitor Center",
        isVirtual: false,
        virtualLink: "",
        description: "Monthly meetup for Swift developers featuring talks on Foundation Models Framework.",
        attendees: ["Tim", "Craig", "John"],
        hasRSVP: true,
        rsvpDeadline: "2025-02-10"
    )
    
    print("    Title: \(event.title)")
    print("    Date: \(event.date) at \(event.time)")
    print("    Location: \(event.location)")
    print("    RSVP Required: \(event.hasRSVP ? "Yes, by \(event.rsvpDeadline)" : "No")")
}

// MARK: - Demo: Tool Integration

func runToolIntegrationDemo() async {
    print("""
    
    ────────────────────────────────────────────────────────────
    🔧 Demo 4: Tool Integration
    ────────────────────────────────────────────────────────────
    
    Extend LLM capabilities with custom tools.
    The @Tool macro enables function calling patterns.
    
    """)
    
    print("  ▶ Weather Tool:")
    let weatherTool = WeatherTool()
    
    do {
        let weather = try await weatherTool.getCurrentWeather(location: "San Francisco")
        print("\n\(weather.description.split(separator: "\n").map { "    \($0)" }.joined(separator: "\n"))")
        
        print("\n  ▶ 3-Day Forecast:")
        let forecast = try await weatherTool.getForecast(location: "San Francisco", days: 3)
        for day in forecast {
            print("    \(day.description.split(separator: "\n").first ?? "")")
        }
    } catch {
        print("    Error: \(error.localizedDescription)")
    }
    
    print("\n  ▶ Search Tool:")
    let searchTool = SearchTool()
    
    do {
        let results = try await searchTool.search(query: "Foundation Models Framework")
        print("    Found \(results.count) results:")
        for (index, result) in results.prefix(2).enumerated() {
            print("\n    [\(index + 1)] \(result.title)")
            print("        Relevance: \(String(format: "%.0f", result.relevanceScore * 100))%")
        }
    } catch {
        print("    Error: \(error.localizedDescription)")
    }
}

// MARK: - Demo: Session Management

func runSessionManagementDemo() async {
    print("""
    
    ────────────────────────────────────────────────────────────
    ⚙️ Demo 5: Session Configuration
    ────────────────────────────────────────────────────────────
    
    Fine-tune model behavior with GenerationOptions.
    Different configurations for different use cases.
    
    """)
    
    let configs: [(String, SessionConfiguration)] = [
        ("Default", .default),
        ("Creative", .creative),
        ("Precise", .precise)
    ]
    
    print("  Available Configurations:\n")
    for (name, config) in configs {
        print("    ● \(name):")
        print("        Temperature: \(config.temperature)")
        print("        Max Tokens: \(config.maxTokens)")
        print("")
    }
    
    print("""    
    Usage:
    
      let session = AISessionManager(configuration: .creative)
      await session.initialize()
      
      // Register tools
      await session.registerTool(WeatherTool())
      await session.registerTool(SearchTool())
      
      // Generate structured output
      let review = try await session.generate(
          prompt: "Analyze this movie review...",
          as: MovieReview.self
      )
    """)
}
