//
//  GameLobbyViewModel.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation
import Combine

class GameLobbyViewModel: ObservableObject {
    var gameId: String
    var playerName: String
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isLoading = false
    @Published var statusMessage = "Waiting for players..."
    @Published var shouldNavigateToGame = false
    @Published var playerList: [String] = []

    init() {
        self.gameId = DependencyContainer.shared.gameManager.gameId ?? ""
        self.playerName = DependencyContainer.shared.gameManager.currentPlayerName ?? ""
        
        playerList.append(playerName)
        
        setUpPublisher()
    }
    
    func startGame() {
        Task {
            let gameStarted = await DependencyContainer.shared.gameManager.startGame()
            
            await MainActor.run {
                shouldNavigateToGame = gameStarted
            }
        }
    }
    
    private func setUpPublisher() {
        DependencyContainer.shared.gameManager.$playerNames
            .receive(on: RunLoop.main)
            .assign(to: \.playerList, on: self)
            .store(in: &cancellables)
    }
}
