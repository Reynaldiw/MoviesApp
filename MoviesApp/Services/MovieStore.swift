//
//  MovieStore.swift
//  MoviesApp
//
//  Created by Reynaldi Wijaya on 02/09/20.
//  Copyright © 2020 Reynaldi Wijaya. All rights reserved.
//

import Foundation

class MovieStore: MovieService {
    
    public static let shared = MovieStore()
    private init() {}
    private let apiKey = "YOUR_API_KEY"
    private let baseAPIURL = "https://api.themoviedb.org/3"
    private let urlSession = URLSession.shared
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    func fetchMovies(from endpoint: Endpoint, params: [String : String]?, successHandler: @escaping (MovieResponse) -> Void, errorHandler: @escaping (Error) -> Void) {
        
        guard var urlComponents = URLComponents(string: "\(baseAPIURL)/movie/\(endpoint.rawValue)") else {
            errorHandler(MovieError.invalidEndpoint)
            return
        }
        
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        if let params = params {
            queryItems.append(contentsOf: params.map {
                URLQueryItem(name: $0.key, value: $0.value)
            })
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            errorHandler(MovieError.invalidEndpoint)
            return
        }
                        
        urlSession.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.handleError(errorHandler: errorHandler, error: MovieError.apiError)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode else {
                    self.handleError(errorHandler: errorHandler, error: MovieError.invalidResponse)
                    
                    return
            }
            
            guard let data = data else {
                self.handleError(errorHandler: errorHandler, error: MovieError.noData)
                return
            }
            
            do {
                let movieResponse = try self.jsonDecoder.decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    successHandler(movieResponse)
                }
            } catch {
                self.handleError(errorHandler: errorHandler, error: MovieError.serializationError)
            }
        }.resume()
    }
    
    func searchMovie(query: String, params: [String : String]?, successHandler: @escaping (MovieResponse) -> Void, errorHandler: @escaping (Error) -> Void) {
        
        guard var urlComponents = URLComponents(string: "\(baseAPIURL)/search/movie") else {
            errorHandler(MovieError.invalidEndpoint)
            return
        }
        
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey),
                          URLQueryItem(name: "language", value: "en-US"),
                          URLQueryItem(name: "include_adult", value: "false"),
                          URLQueryItem(name: "region", value: "US"),
                          URLQueryItem(name: "query", value: query)
        ]
        
        if let params = params {
            queryItems.append(contentsOf: params.map {
                URLQueryItem(name: $0.key, value: $0.value)
            })
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            errorHandler(MovieError.invalidEndpoint)
            return
        }
        
        urlSession.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.handleError(errorHandler: errorHandler, error: MovieError.apiError)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                self.handleError(errorHandler: errorHandler, error: MovieError.serializationError)
                return
            }
            
            guard let data = data else {
                self.handleError(errorHandler: errorHandler, error: MovieError.noData)
                return
            }
            
            do {
                let movieResponse = try self.jsonDecoder.decode(MovieResponse.self, from: data)
                DispatchQueue.main.async {
                    successHandler(movieResponse)
                }
            } catch {
                self.handleError(errorHandler: errorHandler, error: MovieError.serializationError)
            }
        }.resume()
    }
    
    
    private func handleError(errorHandler: @escaping (_ error: Error) -> Void, error: Error) {
        DispatchQueue.main.async {
            errorHandler(error)
        }
    }
    
}
