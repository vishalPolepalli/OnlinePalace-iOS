//
//  HomeView.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            mainView
                .navigationDestination(isPresented: $viewModel.shouldNavigateToGameLobby) {
                    GameLobbyView(viewModel: .init())
                        .navigationBarHidden(true)
                }
        }
    }
    
    var mainView: some View {
        VStack(spacing: 20) {

            logoImage
            
            nameTextField
            
            createGameButton
            
            joinGameButton
            
            if viewModel.showJoinGameField {
                enterGameIdView
            }

            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
    }
    
    var logoImage: some View {
        Image(Constants.imageName)
            .resizable()
            .scaledToFit()
            .frame(height: 200)
            .padding(.bottom, 30)
            .padding(.top, 50)
    }
    
    var nameTextField: some View {
        TextField(Constants.namePlaceholder, text: $viewModel.name)
            .textFieldStyle(.roundedBorder)
            .autocapitalization(.words)
            .disableAutocorrection(true)
    }
    
    var createGameButton: some View {
        Button {
            viewModel.createGame()
        } label: {
            Text(Constants.createGame)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
        .disabled(!viewModel.isNameValid)
    }
    
    var joinGameButton: some View {
        Button {
            withAnimation {
                viewModel.joinGameButtonPressed()
            }
        } label: {
            Text(viewModel.showJoinGameField ?
                 Constants.cancelJoin : Constants.joinGame)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .tint(viewModel.showJoinGameField ? .gray : .blue)
    }
    
    var enterGameIdView: some View {
        VStack {
            TextField(Constants.joinIdPlaceholder, text: $viewModel.joinGameId)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button {
                viewModel.joinGame()
            } label: {
                Text(Constants.joinWithId)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!viewModel.isNameValid ||
                      !viewModel.isGameIdValid)
        }
        .padding(.horizontal)
        .transition(.opacity.combined(with: .scale))
    }
}

extension HomeView {
    enum Constants {
        static let imageName = "MainLogo"
        static let namePlaceholder = "Enter your name: "
        static let createGame = "Create Game"
        static let joinGame = "Join Game"
        static let cancelJoin = "Cancel Join"
        static let joinIdPlaceholder = "Enter Game ID: "
        static let joinWithId = "Join with ID"
    }
}

#Preview {
    HomeView(viewModel: .init())
}
