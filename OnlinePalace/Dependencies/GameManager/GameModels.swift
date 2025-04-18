//
//  GameModels.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation
import SwiftUICore

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
    let suit: Suit
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }
    
    enum Suit: String, Codable {
        case hearts = "H"
        case clubs = "C"
        case spades = "S"
        case diamonds = "D"
        
        var symbol: String {
            switch self {
            case .hearts:
                "♥️"
            case .clubs:
                "♣️"
            case .spades:
                "♠️"
            case .diamonds:
                "♦️"
            }
        }
        
        var color: Color {
            switch self {
            case .hearts:
                    .red
            case .clubs:
                    .black
            case .spades:
                    .black
            case .diamonds:
                    .red
            }
        }
    }
}

