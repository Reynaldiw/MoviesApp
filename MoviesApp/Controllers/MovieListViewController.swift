//
//  MovieListViewController.swift
//  MoviesApp
//
//  Created by Reynaldi Wijaya on 02/09/20.
//  Copyright © 2020 Reynaldi Wijaya. All rights reserved.
//

import UIKit

class MovieListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    
    let dateFormatter: DateFormatter = {
        $0.dateStyle = .medium
        $0.timeStyle = .none
        return $0
    }(DateFormatter())
    
    let movieService: MovieService = MovieStore.shared
    
    var movies = [Movie]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupTableView()
        fetchMovies()

    }
    
    func setupTableView() {
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
    
    func fetchMovies() {
        self.movies = []
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        infoLabel.isHidden = true
        
        movieService.fetchMovies(from: Endpoint.nowPlaying, params: nil, successHandler: { [unowned self] (response) in
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            self.tableView.isHidden = false
            self.movies = response.results
        }) { [unowned self] (error) in
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            self.infoLabel.text = error.localizedDescription
            self.tableView.isHidden = true
            self.infoLabel.isHidden = false
        }
    }
}

extension MovieListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies[indexPath.row]
        
        cell.titleLabel.text = movie.title
        cell.releaseDateLabel.text = dateFormatter.string(from: movie.releaseDate)
        cell.overviewLabel.text = movie.overview
        cell.posterImageView.loadRemoteImage(url: movie.posterURL)
        
        let rating = Int(movie.voteAverage)
        let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
            return acc + "⭐️"
        }
        cell.ratingLabel.text = ratingText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
