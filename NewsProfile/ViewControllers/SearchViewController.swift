//
//  SearchViewController.swift
//  NewsProfile
//
//  Created by Apple on 16/05/25.
//
import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var articles: [Article] = []
    private var currentPage = 1
    private var isLoading = false
    private var currentQuery = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchBar.delegate = self
        searchBar.placeholder = "Search news..."
        let nib = UINib(nibName: "ArticleCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ArticleCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
    }
    private func searchNews(query: String, page: Int = 1) {
        if Reachability.isConnectedToNetwork(){
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        let apiKey = "246f2b4e33a64b079a5bc0d90a741f3c"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://newsapi.org/v2/everything?q=\(encodedQuery)&page=\(page)&pageSize=20&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            if let error = error {
                print("Fetch error: \(error)")
                return
            }
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(NewsResponse.self, from: data)
                DispatchQueue.main.async {
                    if page == 1 {
                        self.articles = result.articles ?? []
                    } else {
                        self.articles += result.articles ?? []
                    }
                    self.collectionView.reloadData()
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
        }else{
            let alert = UIAlertController(title: "No Internet Connection",
                                                  message: "Please check your network settings.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
    }
}
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        currentQuery = searchBar.text ?? ""
        currentPage = 1
        isLoading = false
        articles = []
        collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.collectionView.setContentOffset(.zero, animated: false)
            self.searchNews(query: self.currentQuery, page: self.currentPage)
        }

        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout & UICollectionViewDataSource

extension SearchViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let article = articles[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        cell.configure(with: article)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width / 2) - 10
        return CGSize(width: cellWidth, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

// MARK: - UIScrollViewDelegate for Pagination

extension SearchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height

        if offsetY > contentHeight - scrollViewHeight - 100 {
            if !isLoading && !currentQuery.isEmpty {
                currentPage += 1
                searchNews(query: currentQuery, page: currentPage)
            }
        }
    }
}
