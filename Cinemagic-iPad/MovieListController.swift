//
//  MovieListController.swift
//  Cinemagic-iPad
//
//  Created by Ayşe Bayık on 23.02.2021.
//

import UIKit
import Alamofire
import Kingfisher

class MovieListController: UITableViewController {
    
    var categories = ["Popular" , "Top Rated" , "Revenue" , "Release Date"]
    var arrPopularMovies: [Result] = []
    var arrTopRatedMovies: [Result] = []
    var arrRevenueMovies: [Result] = []
    var arrReleaseDateMovies: [Result] = []
    var arrMovies: [[Result]] = [[]]
    

    override func viewDidLoad() {
//        clearCache()
        
        super.viewDidLoad()
    }
    
    func clearCache(){
        let cache = ImageCache.default
        cache.clearMemoryCache()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var sort_by_data:String
        
        for category in categories {
            switch category {
            case "Popular":
                sort_by_data = "popularity.desc"
            case "Top Rated":
                sort_by_data = "vote_count.desc"
            case "Revenue":
                sort_by_data = "revenue.desc"
            case "Release Date":
                sort_by_data = "release_date.desc"
            default:
                sort_by_data=""
                print("No matching queries.")
            }
        
            let params = [ "api_key":"10e40fc1cc467732a5409989a89be80d", "language":"en-US", "sort_by":sort_by_data, "include_adult":"false" , "include_video":"false" , "page":"1"]
        
            let url = "https://api.themoviedb.org/3/discover/movie"
        
            AF.request(url, method: .get, parameters: params).responseJSON { (res) in
        
                // Standard response for successful HTTP requests control.
                if ( res.response?.statusCode == 200 ) {
        
                    let movie = try? JSONDecoder().decode(Movie.self, from: res.data!)
                    if (movie?.results != nil){
                        switch category {
                        case "Popular":
                            self.arrPopularMovies = movie!.results
                        case "Top Rated":
                            self.arrTopRatedMovies = movie!.results
                        case "Revenue":
                            self.arrRevenueMovies = movie!.results
                        case "Release Date":
                            self.arrReleaseDateMovies = movie!.results
                        default:
                            print("No matching MovieArrays")
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Table view data source
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "popularCell", for: indexPath)
        
        arrMovies = [arrPopularMovies,arrTopRatedMovies,arrRevenueMovies,arrReleaseDateMovies]
        
        
        switch indexPath.section {
        case 0:
            if let  popCell = tableView.dequeueReusableCell(withIdentifier: "popularCell", for: indexPath) as? PopularRow {
                
                popCell.configure(with: categories[indexPath.section],sourceData: arrPopularMovies)
                popCell.MovieCollectionView.delegate = self
                popCell.MovieCollectionView.reloadData()
                
                cell = popCell
            }
        case 1:
            if let  topCell = tableView.dequeueReusableCell(withIdentifier: "topRatedCell", for: indexPath) as? TopRatedRow {
                
                topCell.configure(with: categories[indexPath.section],sourceData: arrTopRatedMovies)
                
                topCell.MovieCollectionView2.delegate = self
                topCell.MovieCollectionView2.reloadData()
                
                cell = topCell
            }
        case 2:
            if let  revCell = tableView.dequeueReusableCell(withIdentifier: "revenueCell", for: indexPath) as? RevenueRow {
                
                revCell.configure(with: categories[indexPath.section],sourceData: arrRevenueMovies)
                
                revCell.MovieCollectionView3.delegate = self
                revCell.MovieCollectionView3.reloadData()
                
                cell = revCell
            }
        case 3:
            if let  releaseCell = tableView.dequeueReusableCell(withIdentifier: "releaseDateCell", for: indexPath) as? ReleaseDateRow {
                
                releaseCell.configure(with: categories[indexPath.section],sourceData: arrReleaseDateMovies)
                
                releaseCell.MovieCollectionView4.delegate = self
                releaseCell.MovieCollectionView4.reloadData()
                
                cell = releaseCell
            }
        default:
            print("out of index section")
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let vc = segue.destination as! MovieDetail
            vc.item = sender as? Result
        }
    }
    
    func loadImage(sourceData : [Result], indexPath: IndexPath, cell:CustomMovieCollectionCell ){
        let firstPath = "https://image.tmdb.org/t/p/w500"
        if sourceData.isEmpty == false{
            if sourceData[indexPath.row].posterPath?.isEmpty == false{
                let imagePath = sourceData[indexPath.row].posterPath
                let fullPath = firstPath + imagePath!
                
                let downloadURL = URL(string: fullPath)
                let resource = ImageResource(downloadURL: downloadURL!)
                
                cell.ImageMovie.kf.indicatorType = .activity
                cell.ImageMovie.kf.setImage(with: resource) { result in
                    switch result {
                    case .success(let value):
                        print("Cache Type: ",value.cacheType)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            else {
                cell.ImageMovie.image = UIImage(named: "noMovie")
            }
        }
    }
}


extension MovieListController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow:CGFloat = 3
        let hardCodedPadding:CGFloat = 5
        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        return CGSize(width: itemWidth, height: itemHeight)
    }
  
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var item : Result!
        
        if collectionView.dataSource?.isKind(of: PopularRow.self) == true{
            item = self.arrPopularMovies[indexPath.row]
        }else if collectionView.dataSource?.isKind(of: TopRatedRow.self) == true{
            item = self.arrTopRatedMovies[indexPath.row]
        }else if collectionView.dataSource?.isKind(of: RevenueRow.self) == true{
            item = self.arrRevenueMovies[indexPath.row]
        }else if collectionView.dataSource?.isKind(of: ReleaseDateRow.self) == true{
            item = self.arrReleaseDateMovies[indexPath.row]
        }
        
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetail") as! MovieDetail
        
        vc.item = item
        
        splitViewController?.showDetailViewController(vc, sender: nil)

    }
}
