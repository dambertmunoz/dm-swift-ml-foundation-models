//
//  WeatherTool.swift
//  FoundationModelsKit
//
//  Created by Dambert Muñoz
//

import Foundation
import FoundationModels

/// Weather tool that extends the LLM's capabilities
/// Demonstrates the Tool protocol for function calling
@Tool
public struct WeatherTool {
    
    /// Get current weather for a location
    /// - Parameter location: City name or coordinates
    /// - Returns: Current weather information
    @Tool
    public func getCurrentWeather(location: String) async throws -> WeatherInfo {
        // In production, this would call a real weather API
        // For demo, returning simulated data
        return WeatherInfo(
            location: location,
            temperature: Double.random(in: 15...35),
            condition: WeatherCondition.allCases.randomElement() ?? .sunny,
            humidity: Int.random(in: 30...90),
            windSpeed: Double.random(in: 0...30)
        )
    }
    
    /// Get weather forecast for upcoming days
    /// - Parameters:
    ///   - location: City name or coordinates
    ///   - days: Number of days to forecast (1-7)
    /// - Returns: Array of daily forecasts
    @Tool
    public func getForecast(location: String, days: Int) async throws -> [DailyForecast] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<min(days, 7)).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: today) ?? today
            return DailyForecast(
                date: date,
                highTemperature: Double.random(in: 20...38),
                lowTemperature: Double.random(in: 10...20),
                condition: WeatherCondition.allCases.randomElement() ?? .sunny,
                precipitationChance: Double.random(in: 0...100)
            )
        }
    }
}

/// Current weather information
public struct WeatherInfo: Codable, Sendable {
    public let location: String
    public let temperature: Double
    public let condition: WeatherCondition
    public let humidity: Int
    public let windSpeed: Double
    
    public var description: String {
        """
        Weather in \(location):
        Temperature: \(String(format: "%.1f", temperature))°C
        Condition: \(condition.rawValue)
        Humidity: \(humidity)%
        Wind: \(String(format: "%.1f", windSpeed)) km/h
        """
    }
}

/// Daily weather forecast
public struct DailyForecast: Codable, Sendable {
    public let date: Date
    public let highTemperature: Double
    public let lowTemperature: Double
    public let condition: WeatherCondition
    public let precipitationChance: Double
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    public var description: String {
        """
        \(Self.dateFormatter.string(from: date)):
        High: \(String(format: "%.1f", highTemperature))°C
        Low: \(String(format: "%.1f", lowTemperature))°C
        \(condition.rawValue), \(String(format: "%.0f", precipitationChance))% chance of rain
        """
    }
}

/// Weather conditions
public enum WeatherCondition: String, Codable, CaseIterable, Sendable {
    case sunny = "Sunny"
    case partlyCloudy = "Partly Cloudy"
    case cloudy = "Cloudy"
    case rainy = "Rainy"
    case stormy = "Stormy"
    case snowy = "Snowy"
    case foggy = "Foggy"
    case windy = "Windy"
}
