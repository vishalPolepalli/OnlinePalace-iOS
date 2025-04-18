//
//  GameManager_Handler.swift
//  OnlinePalace
//
//  Created by VishalP on 4/17/25.
//

import Foundation

extension GameManager {
    func handleResult(_ result: WebSocketResult) {
        switch result {
        case .connected:
            isConnected = true
        case .connectionLost:
            isConnected = false
        case .success(let message):
            handleMessage(message)
        case .failure(_):
            return
            // TODO: Show an error?
        }
    }
    
    func handleMessage(_ message: WebSocketMessageIn) {
        switch message.type {
        case .GAME_UPDATE:
            handleGameUpdate(payload: message.payload)
        case .PLAYER_JOINED:
            handleNewPlayer(payload: message.payload)
        case .GAME_STARTED:
            handleGameUpdate(payload: message.payload)
        case .YOUR_TURN:
            // TODO
            return
        case .CONNECTION_ESTABLISHED:
            isConnected = true
            handleGameUpdate(payload: message.payload)
        }
    }
    
    private func handleGameUpdate(payload: WebSocketMessageIn.Payload?) {
        guard let payload else { return }
        updateGameId(gameId)
        updatePlayers(payload.players)
    }
    
    private func handleNewPlayer(payload: WebSocketMessageIn.Payload?) {
        guard let payload,
              let player = payload.newPlayer,
              players.contains(player)  == false else { return }
        // Not sure if need to remove the player and add them again
        players.append(player)
        playerNames.append(player.name)
    }
    
    // Not sure if this is really needed???
    private func updateGameId(_ gameId: String?) {
        guard let gameId else { return }
        self.gameId = gameId
    }
    
    private func updatePlayers(_ players: [Player]?) {
        guard let players else { return }
        self.players = players
        
        playerNames = players.map { player in
            player.name
        }
    }
}
