//
//  ContentView.swift
//  OnlinePalace
//
//  Created by Personal on 4/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView(viewModel: .init())
        }
    }
}

#Preview {
    ContentView()
}
