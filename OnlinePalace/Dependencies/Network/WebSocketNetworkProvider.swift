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
    
    let webSocketUpdateSubject = PassthroughSubject<WebSocketMessageIn, Error>()

    @Published var isConnected: Bool = false

    init() {
        self.urlSession = URLSession(configuration: .default)
    }

    func connect(url: URL) {
        disconnect()

        print("WebSocket: Connecting to \(url)...")
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        listenForMessages()
        
        isConnected = true
    }

    func disconnect() {
        print("WebSocket: Disconnecting...")
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

    private func listenForMessages() {
        guard let task = webSocketTask else { return }

        task.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("WebSocket: Failed to receive message: \(error)")

                self.isConnected = false
                self.webSocketUpdateSubject.send(completion: .failure(error))

            case .success(let message):
                switch message {
                case .string(let text):
                    print("WebSocket: Received text message")
                    
                    if let data = text.data(using: .utf8) {
                        self.decodeMessage(data: data)
                    } else {
                        print("WebSocket: Could not convert received text to data.")
                    }
                case .data(let data):
                    print("WebSocket: Received binary message")
                    
                    self.decodeMessage(data: data)
                @unknown default:
                    print("WebSocket: Received unknown message type")
                }
                self.listenForMessages()
            }
        }
    }

    private func decodeMessage(data: Data) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let message = try decoder.decode(WebSocketMessageIn.self, from: data)
            print("WebSocket: Received message of type: \(message.type)")

            self.webSocketUpdateSubject.send(message)
        } catch {
            print("WebSocket: Failed to decode message: \(error)")
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
