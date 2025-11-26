//
//  Article.swift
//  FoundationModelsKit
//
//  Created by Dambert Muñoz
//

import Foundation
import FoundationModels

/// Article structure for content extraction and summarization
@Generable
public struct Article {
    
    /// Article headline
    public var headline: String
    
    /// Article subheadline or deck
    public var subheadline: String
    
    /// Main content sections
    @Guide(.count(1...10))
    public var sections: [ArticleSection]
    
    /// Article category
    @Guide(.anyOf(["Technology", "Business", "Science", "Health", "Sports", "Entertainment", "Politics", "World", "Opinion", "Other"]))
    public var category: String
    
    /// Key takeaways
    @Guide(.count(3...7))
    public var keyTakeaways: [String]
    
    /// Reading time in minutes
    @Guide(.range(1...60))
    public var readingTimeMinutes: Int
    
    /// Content complexity level
    public var complexity: ContentComplexity
    
    /// Target audience
    @Guide(.count(1...3))
    public var targetAudience: [String]
    
    public init(
        headline: String = "",
        subheadline: String = "",
        sections: [ArticleSection] = [],
        category: String = "Other",
        keyTakeaways: [String] = [],
        readingTimeMinutes: Int = 5,
        complexity: ContentComplexity = .intermediate,
        targetAudience: [String] = []
    ) {
        self.headline = headline
        self.subheadline = subheadline
        self.sections = sections
        self.category = category
        self.keyTakeaways = keyTakeaways
        self.readingTimeMinutes = readingTimeMinutes
        self.complexity = complexity
        self.targetAudience = targetAudience
    }
}

@Generable
public struct ArticleSection {
    public var title: String
    
    @Guide(.count(50...500))
    public var content: String
    
    @Guide(.count(0...5))
    public var bulletPoints: [String]
    
    public init(
        title: String = "",
        content: String = "",
        bulletPoints: [String] = []
    ) {
        self.title = title
        self.content = content
        self.bulletPoints = bulletPoints
    }
}

@Generable
public enum ContentComplexity: String, CaseIterable, Sendable {
    case beginner
    case intermediate
    case advanced
    case expert
}
