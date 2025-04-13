//
//  CreateGameEndpoint.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation

struct CreateGameEndpoint: ServiceEndpointDefining {
    typealias RequestBody = CreateGameRequestBody
    typealias ResponseBody = CreateGameResponseBody
    
    var path = "/games"
    var method = HTTPMethod.post
    var requestBody: RequestBody?
    
    var headers: [String : String]? = nil
    var queryParameters: [String : String]? = nil
}

struct CreateGameRequestBody: Codable {
    var playerName: String
}

struct CreateGameResponseBody: Codable {
    var gameId: String
    var playerId: String
}
