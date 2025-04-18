//
//  JoinGameEndpoint.swift
//  OnlinePalace
//
//  Created by VishalP on 4/14/25.
//

import Foundation

struct JoinGameEndpoint: ServiceEndpointDefining {
    typealias RequestBody = JoinGameRequest
    typealias ResponseBody = JoinGameResponse
    
    var method = HTTPMethod.post
    var requestBody: RequestBody?
    var path: String

    var headers: [String : String]? = nil
    var queryParameters: [String : String]? = nil
    
    init(gameId: String, requestBody: RequestBody) {
        path = "/games/\(gameId)/join"
        self.requestBody = requestBody
    }
}

struct JoinGameRequest: Codable {
    var playerName: String
}

struct JoinGameResponse: Codable {
    var playerId: String
}
