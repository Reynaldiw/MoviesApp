//
//  MovieService.swift
//  MoviesApp
//
//  Created by Reynaldi Wijaya on 20/03/20.
//  Copyright © 2020 Reynaldi Wijaya. All rights reserved.
//

import Foundation

protocol MovieService {
    func fetchMovies(from endpoint : Endpoint, params: [String : String]?, successHandler: @escaping (_ response: MovieResponse) -> Void, errorHandler: @escaping (_ error: Error) -> Void)
}

public enum Endpoint: String, CaseIterable {
    case nowPlaying = "now_playing"
}

public enum MovieError: Error {
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case serializationError
}
