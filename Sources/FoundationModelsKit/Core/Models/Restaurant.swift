//
//  Restaurant.swift
//  FoundationModelsKit
//
//  Created by Dambert Muñoz
//

import Foundation
import FoundationModels

/// Restaurant information extracted from unstructured text
/// Shows complex nested structures with multiple @Guide constraints
@Generable
public struct Restaurant {
    
    /// Restaurant name
    public var name: String
    
    /// Type of cuisine
    @Guide(.anyOf(["Italian", "Mexican", "Japanese", "Chinese", "Indian", "French", "American", "Thai", "Mediterranean", "Other"]))
    public var cuisineType: String
    
    /// Price range indicator
    @Guide(description: "Price range from $ (cheap) to $$$$ (expensive)")
    public var priceRange: PriceRange
    
    /// Location details
    public var location: RestaurantLocation
    
    /// Operating hours
    public var hours: OperatingHours
    
    /// Special features
    @Guide(.count(0...10))
    public var features: [RestaurantFeature]
    
    /// Average rating
    @Guide(.range(1.0...5.0))
    public var rating: Double
    
    public init(
        name: String = "",
        cuisineType: String = "Other",
        priceRange: PriceRange = .moderate,
        location: RestaurantLocation = RestaurantLocation(),
        hours: OperatingHours = OperatingHours(),
        features: [RestaurantFeature] = [],
        rating: Double = 3.0
    ) {
        self.name = name
        self.cuisineType = cuisineType
        self.priceRange = priceRange
        self.location = location
        self.hours = hours
        self.features = features
        self.rating = rating
    }
}

@Generable
public enum PriceRange: String, CaseIterable, Sendable {
    case budget = "$"
    case moderate = "$$"
    case upscale = "$$$"
    case luxury = "$$$$"
}

@Generable
public struct RestaurantLocation {
    public var address: String
    public var city: String
    public var neighborhood: String
    
    @Guide(.regex(#"^\d{5}(-\d{4})?$"#), description: "US ZIP code format")
    public var zipCode: String
    
    public init(
        address: String = "",
        city: String = "",
        neighborhood: String = "",
        zipCode: String = "00000"
    ) {
        self.address = address
        self.city = city
        self.neighborhood = neighborhood
        self.zipCode = zipCode
    }
}

@Generable
public struct OperatingHours {
    @Guide(description: "Opening time in HH:MM format")
    public var openTime: String
    
    @Guide(description: "Closing time in HH:MM format")
    public var closeTime: String
    
    public var daysOpen: [DayOfWeek]
    
    public init(
        openTime: String = "11:00",
        closeTime: String = "22:00",
        daysOpen: [DayOfWeek] = DayOfWeek.allCases
    ) {
        self.openTime = openTime
        self.closeTime = closeTime
        self.daysOpen = daysOpen
    }
}

@Generable
public enum DayOfWeek: String, CaseIterable, Sendable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

@Generable
public enum RestaurantFeature: String, CaseIterable, Sendable {
    case outdoorSeating = "Outdoor Seating"
    case delivery = "Delivery"
    case takeout = "Takeout"
    case reservations = "Reservations"
    case wifi = "Free WiFi"
    case parking = "Parking"
    case vegetarianOptions = "Vegetarian Options"
    case veganOptions = "Vegan Options"
    case glutenFree = "Gluten-Free Options"
    case liveMusic = "Live Music"
}
