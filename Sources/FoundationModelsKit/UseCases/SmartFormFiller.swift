//
//  SmartFormFiller.swift
//  FoundationModelsKit
//
//  Created by Dambert Muñoz
//

import Foundation
import FoundationModels

/// Use case for intelligently extracting form data from unstructured text
public final class SmartFormFiller: Sendable {
    
    private let sessionManager: AISessionManager
    
    public init(sessionManager: AISessionManager) {
        self.sessionManager = sessionManager
    }
    
    /// Extract contact information from unstructured text
    public func extractContact(from text: String) async throws -> ContactInfo {
        let prompt = """
        Extract contact information from the following text. Look for:
        - Name (first and last)
        - Email addresses
        - Phone numbers
        - Company/organization
        - Job title
        - Address
        - Social media handles
        
        Text:
        ---
        \(text)
        ---
        """
        
        return try await sessionManager.generate(
            prompt: prompt,
            as: ContactInfo.self
        )
    }
    
    /// Extract event details from text
    public func extractEvent(from text: String) async throws -> EventInfo {
        let prompt = """
        Extract event information from the following text. Look for:
        - Event name/title
        - Date and time
        - Location
        - Description
        - Attendees mentioned
        - RSVP/registration info
        
        Text:
        ---
        \(text)
        ---
        """
        
        return try await sessionManager.generate(
            prompt: prompt,
            as: EventInfo.self
        )
    }
    
    /// Extract product information from description
    public func extractProduct(from text: String) async throws -> ProductInfo {
        let prompt = """
        Extract product information from the following text:
        
        Text:
        ---
        \(text)
        ---
        """
        
        return try await sessionManager.generate(
            prompt: prompt,
            as: ProductInfo.self
        )
    }
}

// MARK: - Supporting Types

@Generable
public struct ContactInfo {
    public var firstName: String
    public var lastName: String
    
    @Guide(.regex(#"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#))
    public var email: String
    
    @Guide(description: "Phone number in any format")
    public var phone: String
    
    public var company: String
    public var jobTitle: String
    public var address: String
    
    @Guide(.count(0...5))
    public var socialMedia: [SocialMediaHandle]
    
    public init(
        firstName: String = "",
        lastName: String = "",
        email: String = "unknown@example.com",
        phone: String = "",
        company: String = "",
        jobTitle: String = "",
        address: String = "",
        socialMedia: [SocialMediaHandle] = []
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.company = company
        self.jobTitle = jobTitle
        self.address = address
        self.socialMedia = socialMedia
    }
}

@Generable
public struct SocialMediaHandle {
    @Guide(.anyOf(["Twitter", "LinkedIn", "GitHub", "Instagram", "Facebook", "Other"]))
    public var platform: String
    
    public var handle: String
    
    public init(platform: String = "Other", handle: String = "") {
        self.platform = platform
        self.handle = handle
    }
}

@Generable
public struct EventInfo {
    public var title: String
    
    @Guide(description: "Event date in ISO 8601 format if possible")
    public var date: String
    
    @Guide(description: "Event time or time range")
    public var time: String
    
    public var location: String
    public var isVirtual: Bool
    public var virtualLink: String
    
    @Guide(.count(10...500))
    public var description: String
    
    @Guide(.count(0...20))
    public var attendees: [String]
    
    public var hasRSVP: Bool
    public var rsvpDeadline: String
    
    public init(
        title: String = "",
        date: String = "",
        time: String = "",
        location: String = "",
        isVirtual: Bool = false,
        virtualLink: String = "",
        description: String = "No description available",
        attendees: [String] = [],
        hasRSVP: Bool = false,
        rsvpDeadline: String = ""
    ) {
        self.title = title
        self.date = date
        self.time = time
        self.location = location
        self.isVirtual = isVirtual
        self.virtualLink = virtualLink
        self.description = description
        self.attendees = attendees
        self.hasRSVP = hasRSVP
        self.rsvpDeadline = rsvpDeadline
    }
}

@Generable
public struct ProductInfo {
    public var name: String
    
    @Guide(.count(20...500))
    public var description: String
    
    @Guide(.range(0.0...1000000.0))
    public var price: Double
    
    @Guide(.anyOf(["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "Other"]))
    public var currency: String
    
    @Guide(.count(0...10))
    public var features: [String]
    
    @Guide(.count(0...5))
    public var categories: [String]
    
    public var brand: String
    public var sku: String
    public var inStock: Bool
    
    @Guide(.range(0...10000))
    public var quantity: Int
    
    public init(
        name: String = "",
        description: String = "Product description not available",
        price: Double = 0.0,
        currency: String = "USD",
        features: [String] = [],
        categories: [String] = [],
        brand: String = "",
        sku: String = "",
        inStock: Bool = false,
        quantity: Int = 0
    ) {
        self.name = name
        self.description = description
        self.price = price
        self.currency = currency
        self.features = features
        self.categories = categories
        self.brand = brand
        self.sku = sku
        self.inStock = inStock
        self.quantity = quantity
    }
}
