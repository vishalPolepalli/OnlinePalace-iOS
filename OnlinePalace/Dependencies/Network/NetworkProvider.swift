//
//  NetworkProvider.swift
//  OnlinePalace
//
//  Created by VishalP on 4/13/25.
//

import Foundation

class NetworkProvider {
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let baseURL: URL?

    init(configuration: URLSessionConfiguration = .default) {
        self.urlSession = URLSession(configuration: configuration)
        self.jsonDecoder = JSONDecoder()
        self.jsonEncoder = JSONEncoder()
        self.baseURL = URL.init(string: "http://127.0.0.1:8000")
    }

    func request<T: ServiceEndpointDefining>(_ endpoint: T) async throws -> T.ResponseBody {
        guard let baseURL else { throw NetworkError.invalidURL }
        
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)
        if let queryParams = endpoint.queryParameters {
            components?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        endpoint.headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        if let body = endpoint.requestBody {
            do {
                urlRequest.httpBody = try jsonEncoder.encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }


        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await urlSession.data(for: urlRequest)
        } catch {
            throw NetworkError.requestFailed(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        do {
            if T.ResponseBody.self == EmptyResponse.self {
                 guard let empty = EmptyResponse() as? T.ResponseBody else {
                     throw NetworkError.decodingError(DecodingError.typeMismatch(EmptyResponse.self, DecodingError.Context(codingPath: [], debugDescription: "Expected EmptyResponse type")))
                 }
                 return empty
            } else {
                let decodedObject = try jsonDecoder.decode(T.ResponseBody.self, from: data)
                return decodedObject
            }
        } catch let decodingError as DecodingError {
             throw NetworkError.decodingError(decodingError)
         } catch {
             throw NetworkError.unknown(error)
         }
    }
}
