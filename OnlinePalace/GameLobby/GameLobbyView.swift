//
//  GameLobbyView.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import SwiftUI

struct GameLobbyView: View {
    
    // Use @StateObject to manage the ViewModel's lifecycle within this view
    @StateObject var viewModel: GameLobbyViewModel
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView("Loading Lobby...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            mainView
        }
    }
    
    // MARK: Main View
    var mainView: some View {
        VStack(alignment: .leading, spacing: 15) {
            header
                                            
            playersList
            
            Spacer()
            
            footer
        }
        .padding()
    }
    
    // MARK: Subviews
    var header: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Game ID: \(viewModel.gameId)")
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                Button {
                    UIPasteboard.general.string = viewModel.gameId
                 } label: {
                     Image(systemName: "doc.on.doc")
                 }
                 .padding(.leading, 5)
            }
            .padding(.top, 40)
            
            Text("Your Name: \(viewModel.playerName)")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .padding(.bottom)
    }
    
    var playersList: some View {
        Group {
            Text("Players (\(viewModel.playerList.count)):")
                .font(.headline)
            
            List {
                ForEach(viewModel.playerList, id: \.self) { player in
                    HStack {
                        Text(player)
                        if player == viewModel.playerName {
                            Spacer()
                            Text("(You)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .frame(minHeight: 100, maxHeight: 300)
        }
    }
    
    var footer: some View {
        VStack(spacing: 10) {
            Text(viewModel.statusMessage)
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Button {
            } label: {
                Text("Start Game")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }
}
#Preview {
    GameLobbyView(viewModel: .init())
}
