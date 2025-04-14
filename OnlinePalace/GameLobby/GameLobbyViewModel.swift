//
//  GameLobbyViewModel.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation

class GameLobbyViewModel: ObservableObject {
    var gameId: String
    var playerName: String
    
    @Published var isLoading = false
    @Published var statusMessage = "Waiting for players..."
    
    @Published var playerList: [String] = []

    init(gameId: String, playerName: String) {
        self.gameId = gameId
        self.playerName = playerName
        
        playerList.append(playerName)
    }
}
