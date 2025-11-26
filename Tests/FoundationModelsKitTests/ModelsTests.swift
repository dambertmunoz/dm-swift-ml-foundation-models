//
//  ModelsTests.swift
//  FoundationModelsKitTests
//
//  Created by Dambert Muñoz
//

import Testing
import Foundation
@testable import FoundationModelsKit

// MARK: - MovieReview Tests

@Suite("MovieReview Model Tests")
struct MovieReviewTests {
    
    @Test("Default initialization creates valid review")
    func testDefaultInitialization() {
        let review = MovieReview()
        
        #expect(review.title.isEmpty)
        #expect(review.sentiment == .neutral)
        #expect(review.rating == 5)
        #expect(review.themes.isEmpty)
        #expect(review.summary.isEmpty)
        #expect(review.isRecommended == false)
    }
    
    @Test("Custom initialization preserves all values")
    func testCustomInitialization() {
        let review = MovieReview(
            title: "Test Movie",
            sentiment: .positive,
            rating: 8,
            themes: ["Action", "Drama"],
            summary: "A great test movie",
            isRecommended: true
        )
        
        #expect(review.title == "Test Movie")
        #expect(review.sentiment == .positive)
        #expect(review.rating == 8)
        #expect(review.themes == ["Action", "Drama"])
        #expect(review.summary == "A great test movie")
        #expect(review.isRecommended == true)
    }
    
    @Test("Rating constraint is within 1-10 range")
    func testRatingConstraint() {
        let review = MovieReview(rating: 7)
        #expect(review.rating >= 1 && review.rating <= 10)
    }
}

// MARK: - Restaurant Tests

@Suite("Restaurant Model Tests")
struct RestaurantTests {
    
    @Test("Default restaurant has valid defaults")
    func testDefaultRestaurant() {
        let restaurant = Restaurant()
        
        #expect(restaurant.name.isEmpty)
        #expect(restaurant.cuisineType == "Other")
        #expect(restaurant.priceRange == .moderate)
        #expect(restaurant.rating == 3.0)
    }
    
    @Test("Nested location initialization")
    func testNestedLocation() {
        let location = RestaurantLocation(
            address: "123 Test St",
            city: "Test City",
            neighborhood: "Downtown",
            zipCode: "12345"
        )
        
        let restaurant = Restaurant(
            name: "Test Restaurant",
            location: location
        )
        
        #expect(restaurant.location.address == "123 Test St")
        #expect(restaurant.location.city == "Test City")
        #expect(restaurant.location.zipCode == "12345")
    }
    
    @Test("All price ranges are accessible")
    func testPriceRanges() {
        let ranges = PriceRange.allCases
        #expect(ranges.count == 4)
        #expect(ranges.contains(.budget))
        #expect(ranges.contains(.luxury))
    }
    
    @Test("Operating hours preserves days")
    func testOperatingHours() {
        let hours = OperatingHours(
            openTime: "09:00",
            closeTime: "21:00",
            daysOpen: [.monday, .tuesday, .wednesday]
        )
        
        #expect(hours.openTime == "09:00")
        #expect(hours.closeTime == "21:00")
        #expect(hours.daysOpen.count == 3)
    }
}

// MARK: - SentimentAnalysis Tests

@Suite("SentimentAnalysis Model Tests")
struct SentimentAnalysisTests {
    
    @Test("Default sentiment is neutral")
    func testDefaultSentiment() {
        let analysis = SentimentAnalysis()
        
        #expect(analysis.primarySentiment == .neutral)
        #expect(analysis.confidence == 0.5)
        #expect(analysis.subjectivity == 0.5)
    }
    
    @Test("Confidence is within valid range")
    func testConfidenceRange() {
        let analysis = SentimentAnalysis(confidence: 0.85)
        #expect(analysis.confidence >= 0.0 && analysis.confidence <= 1.0)
    }
    
    @Test("Emotions are stored correctly")
    func testEmotions() {
        let emotions = [
            EmotionScore(emotion: .joy, intensity: 0.8),
            EmotionScore(emotion: .surprise, intensity: 0.4)
        ]
        
        let analysis = SentimentAnalysis(emotions: emotions)
        
        #expect(analysis.emotions.count == 2)
        #expect(analysis.emotions[0].emotion == .joy)
        #expect(analysis.emotions[0].intensity == 0.8)
    }
    
    @Test("All sentiment levels exist")
    func testSentimentLevels() {
        let sentiments = Sentiment.allCases
        #expect(sentiments.count == 5)
        #expect(sentiments.contains(.veryPositive))
        #expect(sentiments.contains(.veryNegative))
    }
}

// MARK: - Article Tests

@Suite("Article Model Tests")
struct ArticleTests {
    
    @Test("Article section preserves content")
    func testArticleSection() {
        let section = ArticleSection(
            title: "Introduction",
            content: "This is the introduction section with enough content to meet the minimum requirement.",
            bulletPoints: ["Point 1", "Point 2"]
        )
        
        #expect(section.title == "Introduction")
        #expect(section.bulletPoints.count == 2)
    }
    
    @Test("Article stores multiple sections")
    func testArticleSections() {
        let article = Article(
            headline: "Test Article",
            sections: [
                ArticleSection(title: "Section 1", content: "Content for section one with sufficient length."),
                ArticleSection(title: "Section 2", content: "Content for section two with sufficient length.")
            ],
            keyTakeaways: ["Takeaway 1", "Takeaway 2", "Takeaway 3"]
        )
        
        #expect(article.headline == "Test Article")
        #expect(article.sections.count == 2)
        #expect(article.keyTakeaways.count == 3)
    }
    
    @Test("Complexity levels are all available")
    func testComplexityLevels() {
        let levels = ContentComplexity.allCases
        #expect(levels.count == 4)
    }
}

// MARK: - ContactInfo Tests

@Suite("ContactInfo Model Tests")
struct ContactInfoTests {
    
    @Test("Contact stores all fields")
    func testContactFields() {
        let contact = ContactInfo(
            firstName: "John",
            lastName: "Doe",
            email: "john@example.com",
            phone: "555-1234",
            company: "Test Corp",
            jobTitle: "Engineer"
        )
        
        #expect(contact.firstName == "John")
        #expect(contact.lastName == "Doe")
        #expect(contact.email == "john@example.com")
        #expect(contact.company == "Test Corp")
    }
    
    @Test("Social media handles are stored")
    func testSocialMedia() {
        let social = SocialMediaHandle(platform: "LinkedIn", handle: "johndoe")
        let contact = ContactInfo(socialMedia: [social])
        
        #expect(contact.socialMedia.count == 1)
        #expect(contact.socialMedia[0].platform == "LinkedIn")
    }
}

// MARK: - Tool Tests

@Suite("Tool Tests")
struct ToolTests {
    
    @Test("Weather tool returns valid data")
    func testWeatherTool() async throws {
        let tool = WeatherTool()
        let weather = try await tool.getCurrentWeather(location: "Test City")
        
        #expect(weather.location == "Test City")
        #expect(weather.temperature >= 15 && weather.temperature <= 35)
        #expect(weather.humidity >= 30 && weather.humidity <= 90)
    }
    
    @Test("Forecast returns correct number of days")
    func testForecast() async throws {
        let tool = WeatherTool()
        let forecast = try await tool.getForecast(location: "Test City", days: 5)
        
        #expect(forecast.count == 5)
    }
    
    @Test("Forecast is capped at 7 days")
    func testForecastCap() async throws {
        let tool = WeatherTool()
        let forecast = try await tool.getForecast(location: "Test City", days: 10)
        
        #expect(forecast.count == 7)
    }
    
    @Test("Search tool returns results")
    func testSearchTool() async throws {
        let tool = SearchTool()
        let results = try await tool.search(query: "test query")
        
        #expect(results.count == 3)
        #expect(results[0].relevanceScore > 0)
    }
}

// MARK: - Session Configuration Tests

@Suite("SessionConfiguration Tests")
struct SessionConfigurationTests {
    
    @Test("Default configuration has correct values")
    func testDefaultConfig() {
        let config = SessionConfiguration.default
        
        #expect(config.temperature == 0.7)
        #expect(config.maxTokens == 4096)
    }
    
    @Test("Creative configuration is more creative")
    func testCreativeConfig() {
        let config = SessionConfiguration.creative
        
        #expect(config.temperature == 0.9)
    }
    
    @Test("Precise configuration is deterministic")
    func testPreciseConfig() {
        let config = SessionConfiguration.precise
        
        #expect(config.temperature == 0.3)
    }
    
    @Test("Temperature is clamped to valid range")
    func testTemperatureClamping() {
        let highConfig = SessionConfiguration(temperature: 1.5, maxTokens: 1000)
        let lowConfig = SessionConfiguration(temperature: -0.5, maxTokens: 1000)
        
        #expect(highConfig.temperature == 1.0)
        #expect(lowConfig.temperature == 0.0)
    }
    
    @Test("Max tokens has minimum value")
    func testMaxTokensMinimum() {
        let config = SessionConfiguration(temperature: 0.5, maxTokens: 10)
        
        #expect(config.maxTokens >= 100)
    }
}
