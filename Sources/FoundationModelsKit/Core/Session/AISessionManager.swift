//
//  AISessionManager.swift
//  FoundationModelsKit
//
//  Created by Dambert Muñoz
//

import Foundation
import FoundationModels

/// Central manager for AI model sessions
/// Handles session lifecycle, configuration, and tool registration
public actor AISessionManager {
    
    // MARK: - Properties
    
    private var model: SystemLanguageModel?
    private var session: LanguageModelSession?
    private var registeredTools: [any Tool] = []
    
    /// Current session configuration
    public private(set) var configuration: SessionConfiguration
    
    /// Whether the model is available on this device
    public var isModelAvailable: Bool {
        get async {
            guard let model = model else { return false }
            return await model.isAvailable
        }
    }
    
    // MARK: - Initialization
    
    public init(configuration: SessionConfiguration = .default) {
        self.configuration = configuration
    }
    
    // MARK: - Session Management
    
    /// Initialize the AI session with the system language model
    public func initialize() async throws {
        // Get the system language model
        model = SystemLanguageModel.default
        
        guard let model = model else {
            throw AISessionError.modelUnavailable
        }
        
        // Check availability
        guard await model.isAvailable else {
            throw AISessionError.modelNotReady
        }
        
        // Create session with configuration
        let options = GenerationOptions(
            temperature: configuration.temperature,
            maximumResponseTokens: configuration.maxTokens
        )
        
        session = LanguageModelSession(
            model: model,
            options: options,
            tools: registeredTools
        )
    }
    
    /// Reset the current session (clears conversation history)
    public func resetSession() async throws {
        session = nil
        try await initialize()
    }
    
    // MARK: - Tool Registration
    
    /// Register a tool for the AI to use
    public func registerTool(_ tool: any Tool) {
        registeredTools.append(tool)
    }
    
    /// Register multiple tools
    public func registerTools(_ tools: [any Tool]) {
        registeredTools.append(contentsOf: tools)
    }
    
    /// Remove all registered tools
    public func clearTools() {
        registeredTools.removeAll()
    }
    
    // MARK: - Generation
    
    /// Generate a simple text response
    public func generate(prompt: String) async throws -> String {
        guard let session = session else {
            throw AISessionError.sessionNotInitialized
        }
        
        let response = try await session.respond(to: prompt)
        return response.content
    }
    
    /// Generate structured output conforming to a Generable type
    public func generate<T: Generable>(
        prompt: String,
        as type: T.Type
    ) async throws -> T {
        guard let session = session else {
            throw AISessionError.sessionNotInitialized
        }
        
        return try await session.respond(to: prompt, generating: type)
    }
    
    /// Generate with streaming for real-time UI updates
    public func generateStreaming<T: Generable>(
        prompt: String,
        as type: T.Type
    ) -> AsyncThrowingStream<PartiallyGenerated<T>, Error> {
        AsyncThrowingStream { continuation in
            Task {
                guard let session = session else {
                    continuation.finish(throwing: AISessionError.sessionNotInitialized)
                    return
                }
                
                do {
                    let stream = session.streamResponse(
                        to: prompt,
                        generating: type
                    )
                    
                    for try await partial in stream {
                        continuation.yield(partial)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Configuration Updates
    
    /// Update session configuration
    public func updateConfiguration(_ newConfig: SessionConfiguration) async throws {
        configuration = newConfig
        try await resetSession()
    }
}

// MARK: - Supporting Types

/// Configuration for AI session behavior
public struct SessionConfiguration: Sendable {
    /// Temperature for generation (0.0 = deterministic, 1.0 = creative)
    public var temperature: Double
    
    /// Maximum tokens in response
    public var maxTokens: Int
    
    /// Default configuration
    public static let `default` = SessionConfiguration(
        temperature: 0.7,
        maxTokens: 4096
    )
    
    /// Creative configuration for more varied outputs
    public static let creative = SessionConfiguration(
        temperature: 0.9,
        maxTokens: 4096
    )
    
    /// Precise configuration for consistent outputs
    public static let precise = SessionConfiguration(
        temperature: 0.3,
        maxTokens: 4096
    )
    
    public init(temperature: Double, maxTokens: Int) {
        self.temperature = min(max(temperature, 0.0), 1.0)
        self.maxTokens = max(maxTokens, 100)
    }
}

/// Errors specific to AI session management
public enum AISessionError: LocalizedError {
    case modelUnavailable
    case modelNotReady
    case sessionNotInitialized
    case generationFailed(String)
    case toolExecutionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "The system language model is not available on this device."
        case .modelNotReady:
            return "The model is not ready. It may be downloading or initializing."
        case .sessionNotInitialized:
            return "Session not initialized. Call initialize() first."
        case .generationFailed(let reason):
            return "Generation failed: \(reason)"
        case .toolExecutionFailed(let reason):
            return "Tool execution failed: \(reason)"
        }
    }
}
