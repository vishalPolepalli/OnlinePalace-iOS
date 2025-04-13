//
//  NetworkError.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case encodingError(Error)
    case httpError(statusCode: Int, data: Data?)
    case unknown(Error)
}
