//
//  StartGameEndpoint.swift
//  OnlinePalace
//
//  Created by VishalP on 4/18/25.
//

import Foundation

struct StartGameEndpoint: ServiceEndpointDefining {
    typealias RequestBody = EmptyRequest
    typealias ResponseBody = EmptyResponse
    
    var method = HTTPMethod.post
    var requestBody: RequestBody?
    var path: String

    var headers: [String : String]? = nil
    var queryParameters: [String : String]? = nil
    
    init(gameId: String) {
        path = "/games/\(gameId)/start"
    }
}
