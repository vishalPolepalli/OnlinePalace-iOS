//
//  DependencyContainer.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation

class DependencyContainer: ObservableObject {
    static let shared = DependencyContainer()
    
    var networkProvider = NetworkProvider()
    
}
