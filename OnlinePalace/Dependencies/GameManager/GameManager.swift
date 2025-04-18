//
//  GameManager.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation
import Combine

class GameManager: ObservableObject {
    
    enum Constants {
        static let webSocketPath = "/ws/game/"
    }
    
    private var webSocketProvider: WebSocketNetworkProvider
    private var cancellables = Set<AnyCancellable>()
    private let queue = DispatchQueue(label: "com.vishal.OnlinePalace.gameManager", qos: .userInitiated)

    @Published var players: [Player] = []
    @Published var playerNames: [String] = []
    @Published var gameId: String? = nil
    @Published var currentPlayer: Player? = nil
    @Published var currentPlayerName: String? = nil
    @Published var currentPlayerId: String? = nil
    @Published var isConnected: Bool = false

    init(webSocketProvider: WebSocketNetworkProvider) {
        self.webSocketProvider = webSocketProvider
    }
    
    func setupAndConnect(playerId: String, gameId: String, playerName: String, useAsyncStream: Bool = false) {
        self.currentPlayerId = playerId
        self.currentPlayerName = playerName
        self.playerNames.append(playerName)
        self.gameId = gameId

        webSocketProvider.connect(path: "\(Constants.webSocketPath)\(gameId)/\(playerId)")
        subscribeToWebSocketUpdates(useAsyncStream: useAsyncStream)
    }

    func disconnect() {
        players = []
        playerNames = []
        gameId = nil
        currentPlayer = nil
        currentPlayerName = nil
        currentPlayerId = nil
        
        webSocketProvider.disconnect()
        // Remove the cancellable here to stop listening to the passthrough subject
        // GameManager will only be deallocated when app is closed
        cancellables.removeAll()
    }
    
    func startGame() async -> Bool {
        guard let gameId else { return false }
        let endpoint = StartGameEndpoint(gameId: gameId)
        
        do {
            try await _ = DependencyContainer.shared.networkProvider.request(endpoint)
            return true
        } catch {
            // TODO: Handle error here
            return false
        }
    }

    private func subscribeToWebSocketUpdates(useAsyncStream: Bool = false) {
        if useAsyncStream {
            Task {
                await subscribeWithAsyncStream()
            }
        } else {
            webSocketProvider.usePassthroughSubject()
            subscribeWithPassthroughSubject()
        }
    }
    
    private func subscribeWithAsyncStream() async {
        guard let stream = webSocketProvider.stream else {
            webSocketProvider.usePassthroughSubject()
            subscribeWithPassthroughSubject()
            return
        }
        
        for await result in stream {
            handleResult(result)
        }
    }
    
    private func subscribeWithPassthroughSubject() {
        webSocketProvider.passthroughSubject
            .receive(on: queue)
            .sink(receiveCompletion: { completion in
                if case .failure(_) = completion {
                     // TODO: Show an error?
                 }
            }, receiveValue: { [weak self] result in
                self?.handleResult(result)
            })
            .store(in: &cancellables)
    }
}
