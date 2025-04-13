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
        let endpoint = CreateGameEndpoint(requestBody: .init(playerName: name))
        Task {
            let response = try? await DependencyContainer.shared.networkProvider.request(endpoint)
        }
    }
}
