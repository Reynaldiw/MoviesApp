//
//  MovieSearchViewController.swift
//  MoviesApp
//
//  Created by Reynaldi Wijaya on 02/09/20.
//  Copyright © 2020 Reynaldi Wijaya. All rights reserved.
//

import UIKit

class MovieSearchViewController: UIViewController {

    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var searchActivityIndicatorView: UIActivityIndicatorView!
    
    let dateFormatter: DateFormatter = {
        $0.dateStyle = .medium
        $0.timeStyle = .none
        return $0
    }(DateFormatter())
    
    let service: MovieService = MovieStore.shared
    var movies = [Movie]() {
        didSet {
            searchTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchActivityIndicatorView.isHidden = true
        setupNavigationBar()
        setupTableView()

    }
    
    func setupNavigationBar() {
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        self.definesPresentationContext = true
        navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        
        navigationItem.searchController?.searchBar.sizeToFit()
        navigationItem.searchController?.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func searchMovie(query: String) {
        self.movies = []
        searchActivityIndicatorView.isHidden = false
        self.searchActivityIndicatorView.startAnimating()
        self.infoLabel.isHidden = true
        
        service.searchMovie(query: query, params: nil, successHandler: { [unowned self] (response) in
            self.searchActivityIndicatorView.stopAnimating()
            self.searchActivityIndicatorView.isHidden = true
            if response.totalResults == 0 {
                self.infoLabel.text = "No results for \(query)"
                self.infoLabel.isHidden = false
            }
            self.movies = Array(response.results.prefix(5))

        }) { [unowned self] (error) in
            self.searchActivityIndicatorView.stopAnimating()
            self.searchActivityIndicatorView.isHidden = true
            self.infoLabel.isHidden = false
            self.infoLabel.text = error.localizedDescription
        }
    }
    
    private func setupTableView() {
        searchTableView.tableFooterView = UIView()
        searchTableView.rowHeight = UITableView.automaticDimension
        searchTableView.estimatedRowHeight = 100
        searchTableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
}

extension MovieSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchTableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
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
}

extension MovieSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        searchMovie(query: searchBar.text!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        self.movies = []
        self.infoLabel.text = "Start searching your favourite movies"
        self.infoLabel.isHidden = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.movies = []
        if searchText.isEmpty {
            self.infoLabel.text = "Start searching your favourite movies"
            self.infoLabel.isHidden = false
        }
    }
}
