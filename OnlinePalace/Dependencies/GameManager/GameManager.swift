//
//  GameManager.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation
import Combine

class GameManager: ObservableObject {
    private var webSocketProvider: WebSocketNetworkProvider
    private var cancellables = Set<AnyCancellable>()

    @Published var players: [Player] = []
    @Published var playerNames: [String] = []
    @Published var type: WebSocketMessageIn.MessageType?
    @Published var gameId: String? = nil
    @Published var currentPlayer: Player? = nil
    @Published var currentPlayerName: String? = nil
    @Published var currentPlayerId: String? = nil
    @Published var connectionStatus: Bool = false

    init(webSocketProvider: WebSocketNetworkProvider) {
        self.webSocketProvider = webSocketProvider
        subscribeToWebSocketUpdates()
    }

    private func subscribeToWebSocketUpdates() {
        webSocketProvider.webSocketUpdateSubject
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(_) = completion {
                     // TODO: Show an error?
                 }
            }, receiveValue: { [weak self] value in
                guard let payload = value.payload else {
                    self?.type = value.type
                    return
                }
                
                if value.type == .GAME_UPDATE {
                    if let players = payload.players {
                        self?.players = players
                        
                        self?.currentPlayer = players.first { player in
                            self?.currentPlayerId == player.id
                        }
                    }
                    
                    if let gameId = payload.gameId
                    {
                        self?.gameId = gameId
                    }
                } else if value.type == .PLAYER_JOINED {
                    guard let newName = payload.playerName else { return }
                    self?.playerNames.append(newName)
                }

                self?.type = value.type
            })
            .store(in: &cancellables)

        webSocketProvider.$isConnected
            .receive(on: RunLoop.main)
            .assign(to: \.connectionStatus, on: self)
            .store(in: &cancellables)
    }

    func setupAndConnect(playerId: String, gameId: String, playerName: String) {
        let urlString = "wss://palacedev.vishalpolepalli.com/api/ws/game/\(gameId)/\(playerId)"
        
        guard let url = URL(string: urlString) else {
            print("GameManager: Invalid WebSocket URL")
            return
        }

        self.currentPlayerId = playerId
        self.currentPlayerName = playerName
        self.playerNames.append(playerName)
        
        self.gameId = gameId

        webSocketProvider.connect(url: url)
    }

    func disconnect() {
        webSocketProvider.disconnect()
        players = []
        gameId = nil
        currentPlayer = nil
    }
}
