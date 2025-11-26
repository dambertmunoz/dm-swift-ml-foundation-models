//
//  SentimentAnalysis.swift
//  FoundationModelsKit
//
//  Created by Dambert Muñoz
//

import Foundation
import FoundationModels

/// Detailed sentiment analysis result
/// Demonstrates fine-grained emotion detection
@Generable
public struct SentimentAnalysis {
    
    /// Primary sentiment category
    public var primarySentiment: Sentiment
    
    /// Confidence score for the analysis
    @Guide(.range(0.0...1.0))
    public var confidence: Double
    
    /// Detected emotions with their intensities
    @Guide(.count(1...5))
    public var emotions: [EmotionScore]
    
    /// Key phrases that influenced the analysis
    @Guide(.count(1...10))
    public var keyPhrases: [String]
    
    /// Overall tone of the text
    public var tone: TextTone
    
    /// Subjectivity score (0 = objective, 1 = subjective)
    @Guide(.range(0.0...1.0))
    public var subjectivity: Double
    
    public init(
        primarySentiment: Sentiment = .neutral,
        confidence: Double = 0.5,
        emotions: [EmotionScore] = [],
        keyPhrases: [String] = [],
        tone: TextTone = .neutral,
        subjectivity: Double = 0.5
    ) {
        self.primarySentiment = primarySentiment
        self.confidence = confidence
        self.emotions = emotions
        self.keyPhrases = keyPhrases
        self.tone = tone
        self.subjectivity = subjectivity
    }
}

@Generable
public enum Sentiment: String, CaseIterable, Sendable {
    case veryPositive = "Very Positive"
    case positive = "Positive"
    case neutral = "Neutral"
    case negative = "Negative"
    case veryNegative = "Very Negative"
}

@Generable
public struct EmotionScore {
    public var emotion: Emotion
    
    @Guide(.range(0.0...1.0))
    public var intensity: Double
    
    public init(emotion: Emotion = .neutral, intensity: Double = 0.0) {
        self.emotion = emotion
        self.intensity = intensity
    }
}

@Generable
public enum Emotion: String, CaseIterable, Sendable {
    case joy
    case sadness
    case anger
    case fear
    case surprise
    case disgust
    case trust
    case anticipation
    case neutral
}

@Generable
public enum TextTone: String, CaseIterable, Sendable {
    case formal
    case informal
    case professional
    case casual
    case academic
    case conversational
    case neutral
}
