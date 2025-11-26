//
//  ContentSummarizer.swift
//  FoundationModelsKit
//
//  Created by Dambert Muñoz
//

import Foundation
import FoundationModels

/// Use case for summarizing content with configurable detail levels
public final class ContentSummarizer: Sendable {
    
    private let sessionManager: AISessionManager
    
    public init(sessionManager: AISessionManager) {
        self.sessionManager = sessionManager
    }
    
    /// Summarize text content
    /// - Parameters:
    ///   - content: The content to summarize
    ///   - style: The summary style (brief, detailed, bullet points)
    /// - Returns: Structured summary
    public func summarize(
        content: String,
        style: SummaryStyle = .detailed
    ) async throws -> ContentSummary {
        let prompt = buildPrompt(content: content, style: style)
        return try await sessionManager.generate(
            prompt: prompt,
            as: ContentSummary.self
        )
    }
    
    /// Summarize with streaming for real-time updates
    public func summarizeStreaming(
        content: String,
        style: SummaryStyle = .detailed
    ) -> AsyncThrowingStream<PartiallyGenerated<ContentSummary>, Error> {
        let prompt = buildPrompt(content: content, style: style)
        return sessionManager.generateStreaming(
            prompt: prompt,
            as: ContentSummary.self
        )
    }
    
    private func buildPrompt(content: String, style: SummaryStyle) -> String {
        """
        Summarize the following content in a \(style.rawValue) style:
        
        ---
        \(content)
        ---
        
        Provide a structured summary with key points, main themes, and actionable insights if applicable.
        """
    }
}

// MARK: - Supporting Types

public enum SummaryStyle: String, Sendable {
    case brief = "brief and concise"
    case detailed = "detailed and comprehensive"
    case bulletPoints = "bullet point format"
    case executive = "executive summary format"
}

@Generable
public struct ContentSummary {
    /// One-line summary
    @Guide(.count(10...50))
    public var oneLiner: String
    
    /// Main summary paragraph
    @Guide(.count(50...300))
    public var mainSummary: String
    
    /// Key points extracted
    @Guide(.count(3...7))
    public var keyPoints: [String]
    
    /// Main themes identified
    @Guide(.count(1...5))
    public var themes: [String]
    
    /// Actionable insights if any
    @Guide(.count(0...5))
    public var actionableInsights: [String]
    
    /// Estimated reading time of original in minutes
    @Guide(.range(1...120))
    public var originalReadingTime: Int
    
    public init(
        oneLiner: String = "",
        mainSummary: String = "",
        keyPoints: [String] = [],
        themes: [String] = [],
        actionableInsights: [String] = [],
        originalReadingTime: Int = 1
    ) {
        self.oneLiner = oneLiner
        self.mainSummary = mainSummary
        self.keyPoints = keyPoints
        self.themes = themes
        self.actionableInsights = actionableInsights
        self.originalReadingTime = originalReadingTime
    }
}
