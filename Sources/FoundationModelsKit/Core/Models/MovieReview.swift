//
//  MovieReview.swift
//  FoundationModelsKit
//
//  Created by Dambert Muñoz
//

import Foundation
import FoundationModels

/// Movie review analysis with structured output
/// Demonstrates @Generable with nested types and @Guide constraints
@Generable
public struct MovieReview {
    
    /// Movie title extracted from review
    public var title: String
    
    /// Overall sentiment of the review
    @Guide(description: "Overall sentiment: positive, negative, or neutral")
    public var sentiment: ReviewSentiment
    
    /// Rating on a 1-10 scale
    @Guide(.range(1...10))
    public var rating: Int
    
    /// Key themes identified in the review
    @Guide(.count(1...5), description: "Main themes discussed in the review")
    public var themes: [String]
    
    /// Brief summary of the review
    @Guide(.count(10...100), description: "Concise summary in 10-100 words")
    public var summary: String
    
    /// Whether the reviewer recommends the movie
    public var isRecommended: Bool
    
    public init(
        title: String = "",
        sentiment: ReviewSentiment = .neutral,
        rating: Int = 5,
        themes: [String] = [],
        summary: String = "",
        isRecommended: Bool = false
    ) {
        self.title = title
        self.sentiment = sentiment
        self.rating = rating
        self.themes = themes
        self.summary = summary
        self.isRecommended = isRecommended
    }
}

/// Sentiment classification for reviews
@Generable
public enum ReviewSentiment: String, CaseIterable, Sendable {
    case positive
    case negative
    case neutral
    case mixed
}
