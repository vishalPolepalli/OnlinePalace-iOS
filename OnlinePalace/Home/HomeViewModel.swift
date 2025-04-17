//
//  HomeViewModel.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var name = ""
    @Published var showJoinGameField = false
    @Published var joinGameId = ""
    @Published var isLoading = false
    
    @Published var shouldNavigateToGameLobby = false
        
    var isNameValid: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
    
    var isGameIdValid: Bool {
        joinGameId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
    
    func joinGameButtonPressed() {
        showJoinGameField.toggle()
        
        if showJoinGameField == false {
            joinGameId = ""
        }
    }
    
    func createGame() {
        isLoading = true
        let endpoint = CreateGameEndpoint(requestBody: .init(playerName: name))
        Task {
            do {
                let response = try await DependencyContainer.shared.networkProvider.request(endpoint)
                DependencyContainer.shared.gameManager.setupAndConnect(playerId: response.playerId,
                                                                       gameId: response.gameId,
                                                                       playerName: name)
                await MainActor.run {
                    shouldNavigateToGameLobby = true
                }
                
            } catch {
                // show error alert here
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func joinGame() {
        isLoading = true
        let endpoint = JoinGameEndpoint(gameId: joinGameId, requestBody: .init(playerName: name))
        Task {
            do {
                let response = try await DependencyContainer.shared.networkProvider.request(endpoint)
                DependencyContainer.shared.gameManager.setupAndConnect(playerId: response.playerId, gameId: joinGameId, playerName: name)
                
                await MainActor.run {
                    shouldNavigateToGameLobby = true
                }
            } catch {
                // show error alert her
            }
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
