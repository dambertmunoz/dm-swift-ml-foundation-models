//
//  SearchTool.swift
//  FoundationModelsKit
//
//  Created by Dambert Muñoz
//

import Foundation
import FoundationModels

/// Search tool for knowledge retrieval
/// Extends LLM with external data access
@Tool
public struct SearchTool {
    
    /// Search for information on a topic
    /// - Parameter query: Search query string
    /// - Returns: Array of search results
    @Tool
    public func search(query: String) async throws -> [SearchResult] {
        // In production, this would call a real search API
        // For demo, returning simulated results
        return [
            SearchResult(
                title: "Result for: \(query)",
                snippet: "This is a simulated search result for your query about \(query). In production, this would return real search results from an API.",
                url: "https://example.com/result/1",
                relevanceScore: 0.95
            ),
            SearchResult(
                title: "Related: \(query) - Deep Dive",
                snippet: "An in-depth analysis related to \(query) with comprehensive information and examples.",
                url: "https://example.com/result/2",
                relevanceScore: 0.87
            ),
            SearchResult(
                title: "\(query) - Official Documentation",
                snippet: "Official documentation and guidelines for \(query) with code examples and best practices.",
                url: "https://example.com/result/3",
                relevanceScore: 0.82
            )
        ]
    }
    
    /// Search within a specific domain
    /// - Parameters:
    ///   - query: Search query string
    ///   - domain: Domain to search within (e.g., "apple.com")
    /// - Returns: Array of search results from specified domain
    @Tool
    public func searchDomain(query: String, domain: String) async throws -> [SearchResult] {
        return [
            SearchResult(
                title: "[\(domain)] \(query)",
                snippet: "Results from \(domain) about \(query). This simulates a domain-specific search.",
                url: "https://\(domain)/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)",
                relevanceScore: 0.90
            )
        ]
    }
}

/// Search result structure
public struct SearchResult: Codable, Sendable {
    public let title: String
    public let snippet: String
    public let url: String
    public let relevanceScore: Double
    
    public var description: String {
        """
        \(title)
        \(snippet)
        URL: \(url)
        Relevance: \(String(format: "%.0f", relevanceScore * 100))%
        """
    }
}
