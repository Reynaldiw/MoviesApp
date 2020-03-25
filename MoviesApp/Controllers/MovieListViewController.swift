//
//  MovieListViewController.swift
//  MoviesApp
//
//  Created by Reynaldi Wijaya on 19/03/20.
//  Copyright © 2020 Reynaldi Wijaya. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

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
    var movieListViewViewModel : MovieListViewViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        movieListViewViewModel = MovieListViewViewModel(endpoint: .from(optional: Endpoint.nowPlaying), movieService: movieService)
        
        movieListViewViewModel.movies.drive(onNext: { [unowned self] (_) in
            self.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        movieListViewViewModel.isFetching.drive(activityIndicatorView.rx.isAnimating)
        .disposed(by: disposeBag)
        
        movieListViewViewModel
            .error
            .drive(onNext: { [unowned self] (error) in
                self.infoLabel.isHidden = !self.movieListViewViewModel.hasError
                self.infoLabel.text = error
            }).disposed(by: disposeBag)
        
        setupTableView()

    }
    
    func setupTableView() {
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
}

extension MovieListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieListViewViewModel.numberOfMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        if let viewModel = movieListViewViewModel.viewModelForMovie(at: indexPath.row) {
            cell.configure(viewModel: viewModel)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
