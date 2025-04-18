//
//  GameModels.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation

struct Player: Codable, Equatable {
    let id: String
    let name: String
    let faceDownCount: Int
    let hand: [Card]?
    let faceUp: [Card]?
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}

struct Card: Codable, Equatable {
    let rank: String
    let suit: String
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }
}

