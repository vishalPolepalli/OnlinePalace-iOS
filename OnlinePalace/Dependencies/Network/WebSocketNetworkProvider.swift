//
//  WebSocketNetworkProvider.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation
import Combine

class WebSocketNetworkProvider: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession
    private var useAsyncStream = true
    private var continuation: AsyncStream<WebSocketResult>.Continuation?
    private var pingTimer: Timer?
    private let timerQueue = DispatchQueue(label: "com.vishal.OnlinePalace.pingTimer", qos: .userInitiated)

    let passthroughSubject = PassthroughSubject<WebSocketResult, Error>()
    var stream: AsyncStream<WebSocketResult>?
    var baseURL: String?
    
    init() {
        self.urlSession = URLSession(configuration: .default)
        self.baseURL = ProcessInfo.processInfo.environment["WEBSOCKET_BASE_URL"]
    }
    
    /// This function can be used to switch to `PassthroughSubject` publisher.
    /// By default `WebSocketProvider` uses `AsyncStream`
    func usePassthroughSubject(_ value: Bool = true) {
        // Why in god did I do it this way ugh
        useAsyncStream = !value
    }

    func connect(path: String) {
        guard let baseURL,
              let url = URL(string: baseURL + path) else { return }
        
        disconnect()
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        schedulePing(interval: 30)
        listenForMessages()
        emitWebSocketResult(.connected)
        
        let (stream, continuation) = AsyncStream.makeStream(of: WebSocketResult.self)
        self.stream = stream
        self.continuation = continuation
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        emitWebSocketResult(.connectionLost)
        continuation?.finish()
        continuation = nil
        stream = nil
        useAsyncStream = true
        cancelPing()
    }
    
    private func schedulePing(interval: TimeInterval) {
        timerQueue.async {
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.sendPing()
            }
            RunLoop.current.run()
        }
    }

    private func sendPing() {
        webSocketTask?.sendPing { _ in }
    }

    private func cancelPing() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    private func listenForMessages() {
        guard let task = webSocketTask else { return }

        task.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                self.emitWebSocketResult(.failure(.serverError(error)))
                disconnect()
            case .success(let message):
                self.handleMessage(message)
            }
            self.listenForMessages()
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let string):
            guard let data = string.data(using: .utf8) else {
                emitWebSocketResult(.failure(.failedDataConversion))
                return
            }
            self.decodeMessage(data: data)
        case .data(let data):
            self.decodeMessage(data: data)
        @unknown default:
            emitWebSocketResult(.failure(.messageTypeNotSupported))
            return
        }
    }

    private func decodeMessage(data: Data) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let message = try decoder.decode(WebSocketMessageIn.self, from: data)
            emitWebSocketResult(.success(message))
        } catch {
            emitWebSocketResult(.failure(.failedToDecode(error)))
        }
    }
    
    private func emitWebSocketResult(_ result: WebSocketResult) {
        if useAsyncStream {
            continuation?.yield(result)
        } else {
            passthroughSubject.send(result)
        }
    }

    func send<T: Codable>(message: T) {
        guard let task = webSocketTask else {
            print("WebSocket: Cannot send message, not connected.")
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            let data = try encoder.encode(message)
            if let jsonString = String(data: data, encoding: .utf8) {
                 print("WebSocket: Sending message: \(jsonString)") // Log the outgoing message
                 task.send(.string(jsonString)) { error in
                     if let error = error {
                         print("WebSocket: Failed to send message: \(error)")
                         // Handle send errors (e.g., notify UI, retry)
                     } else {
                         print("WebSocket: Message sent successfully.")
                     }
                 }
            } else {
                 print("WebSocket: Failed to convert encoded data to JSON string.")
            }

        } catch {
            print("WebSocket: Failed to encode message: \(error)")
        }
    }
}

enum WebSocketError: Error {
    case messageTypeNotSupported
    case failedDataConversion
    case failedToDecode(Error)
    case serverError(Error)
}

enum WebSocketResult {
    case success(WebSocketMessageIn)
    case failure(WebSocketError)
    case connectionLost
    case connected
}
