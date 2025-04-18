//
//  ServiceEndpointDefining.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation

protocol ServiceEndpointDefining {
    associatedtype RequestBody: Codable
    associatedtype ResponseBody: Codable

    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var requestBody: RequestBody? { get set } 
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct EmptyResponse: Codable {}
struct EmptyRequest: Codable {}
