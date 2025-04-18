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
        static let webSocketUrl = "wss://palacedev.vishalpolepalli.com/api/ws/game/"
    }
    
    private var webSocketProvider: WebSocketNetworkProvider
    private var cancellables = Set<AnyCancellable>()

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
        let urlString = "\(Constants.webSocketUrl)\(gameId)/\(playerId)"
        
        guard let url = URL(string: urlString) else {
            // TODO: Show an error
            return
        }

        self.currentPlayerId = playerId
        self.currentPlayerName = playerName
        self.playerNames.append(playerName)
        self.gameId = gameId

        webSocketProvider.connect(url: url)
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


    private func subscribeToWebSocketUpdates(useAsyncStream: Bool = false) {
        if useAsyncStream {
            Task {
                await subscribeWithAsyncStream()
            }
        } else {
            webSocketProvider.usePassthroughSubject()
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
            .receive(on: RunLoop.main)
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
