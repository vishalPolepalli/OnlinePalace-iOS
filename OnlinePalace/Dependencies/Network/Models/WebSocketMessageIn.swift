//
//  WebSocketMessageIn.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation

struct WebSocketMessageIn: Codable {
    let type: MessageType
    let payload: Payload?
    
    struct Payload: Codable {
        let gameId: String?
        let players: [Player]?
        let playerName: String?
    }
    
    enum MessageType: String, Codable {
        case GAME_UPDATE
        case PLAYER_JOINED
        case YOUR_TURN
        case CONNECTION_ESTABLISHED
    }
}
