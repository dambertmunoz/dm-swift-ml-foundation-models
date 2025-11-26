//
//  SentimentAnalyzer.swift
//  FoundationModelsKit
//
//  Created by Dambert Muñoz
//

import Foundation
import FoundationModels

/// Use case for analyzing sentiment in text
public final class SentimentAnalyzer: Sendable {
    
    private let sessionManager: AISessionManager
    
    public init(sessionManager: AISessionManager) {
        self.sessionManager = sessionManager
    }
    
    /// Analyze sentiment of a single text
    public func analyze(text: String) async throws -> SentimentAnalysis {
        let prompt = """
        Analyze the sentiment of the following text. Identify the primary sentiment,
        emotions present, key phrases that indicate sentiment, overall tone, and
        how subjective vs objective the text is.
        
        Text to analyze:
        ---
        \(text)
        ---
        """
        
        return try await sessionManager.generate(
            prompt: prompt,
            as: SentimentAnalysis.self
        )
    }
    
    /// Analyze sentiment of multiple texts
    public func analyzeBatch(texts: [String]) async throws -> [SentimentAnalysis] {
        try await withThrowingTaskGroup(of: (Int, SentimentAnalysis).self) { group in
            for (index, text) in texts.enumerated() {
                group.addTask {
                    let result = try await self.analyze(text: text)
                    return (index, result)
                }
            }
            
            var results = [(Int, SentimentAnalysis)]()
            for try await result in group {
                results.append(result)
            }
            
            return results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }
    
    /// Analyze sentiment with streaming updates
    public func analyzeStreaming(
        text: String
    ) -> AsyncThrowingStream<PartiallyGenerated<SentimentAnalysis>, Error> {
        let prompt = """
        Analyze the sentiment of the following text:
        ---
        \(text)
        ---
        """
        
        return sessionManager.generateStreaming(
            prompt: prompt,
            as: SentimentAnalysis.self
        )
    }
    
    /// Compare sentiment between two texts
    public func compareSentiment(
        text1: String,
        text2: String
    ) async throws -> SentimentComparison {
        let prompt = """
        Compare the sentiment between these two texts:
        
        Text 1:
        ---
        \(text1)
        ---
        
        Text 2:
        ---
        \(text2)
        ---
        
        Provide individual analysis for each and a comparison.
        """
        
        return try await sessionManager.generate(
            prompt: prompt,
            as: SentimentComparison.self
        )
    }
}

// MARK: - Comparison Type

@Generable
public struct SentimentComparison {
    public var text1Analysis: SentimentAnalysis
    public var text2Analysis: SentimentAnalysis
    
    @Guide(description: "Which text is more positive: text1, text2, or equal")
    public var morePositive: ComparisonResult
    
    @Guide(.count(1...5))
    public var keyDifferences: [String]
    
    @Guide(.count(0...3))
    public var similarities: [String]
    
    public init(
        text1Analysis: SentimentAnalysis = SentimentAnalysis(),
        text2Analysis: SentimentAnalysis = SentimentAnalysis(),
        morePositive: ComparisonResult = .equal,
        keyDifferences: [String] = [],
        similarities: [String] = []
    ) {
        self.text1Analysis = text1Analysis
        self.text2Analysis = text2Analysis
        self.morePositive = morePositive
        self.keyDifferences = keyDifferences
        self.similarities = similarities
    }
}

@Generable
public enum ComparisonResult: String, CaseIterable, Sendable {
    case text1 = "Text 1"
    case text2 = "Text 2"
    case equal = "Equal"
}
