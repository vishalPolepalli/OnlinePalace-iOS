//
//  GameModels.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation

struct Player: Codable {
    let id: String
    let name: String
    let faceDownCount: Int
    let hand: [Card]?
    let faceUp: [Card]?
}

struct Card: Codable {
    let rank: String
    let suit: String
}

