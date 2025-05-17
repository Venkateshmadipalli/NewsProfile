//
//  NewsPagingViewController.swift
//  NewsProfile
//
//  Created by Apple on 16/05/25.
//
import UIKit
class NewsPagingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var profileIMG: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var view1: UIView!
    private let viewModel = NewsViewModel()
    private var LocalNews : [NewsDataModel] = []
    let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshTheData()
        (UIApplication.shared.delegate as? AppDelegate)?.scheduleAppRefresh()
        collectionView.dataSource = self
        collectionView.delegate = self
       let nib = UINib(nibName: "NewsPageCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "NewsPageCell")
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .vertical
                    layout.minimumLineSpacing = 0
                    collectionView.isPagingEnabled = true
                }
        profileIMG.layer.cornerRadius = 20
        
               refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
               collectionView.refreshControl = refreshControl
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        showProfilePic()
    }
    
    
    func refreshTheData(){
        if Reachability.isConnectedToNetwork(){
            UserDefaults.standard.set(true, forKey: "Reachability")
            loadNews()
        }else{
            LocalNews = SGalleryHelper.shared.getAllDataFromNews()
            UserDefaults.standard.set(false, forKey: "Reachability")
            self.viewModel.articles = self.LocalNews.map { local in
                
                return Article(
                    source: Source(id: local.id, name: local.name),
                    author: local.author,
                    title: local.title,
                    description: local.des,
                    url: local.img.base64EncodedString(),
                    urlToImage: nil,
                    publishedAt: nil,
                    content: local.content
                    
                )
            } ?? []
        }
    }
    
    func showProfilePic(){
        let photoURL = UserDefaults.standard.string(forKey: "UseProfileImg")
        if let imageData = UserDefaults.standard.data(forKey: "UserProfileImageData"),
           let image = UIImage(data: imageData) {
                   profileIMG.image = image
        }else{
            if let photoURLString = photoURL,
               let photoURL = URL(string: photoURLString) {
                URLSession.shared.dataTask(with: photoURL) { data, response, error in
                    if let error = error {
                        print("Failed to download image: \(error.localizedDescription)")
                        return
                    }
                    guard let data = data,
                          let image = UIImage(data: data) else {
                        print("Invalid image data")
                        return
                    }
                    DispatchQueue.main.async {
                        self.profileIMG.image = image
                    }
                }.resume()
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    @objc private func refreshNews() {
        if Reachability.isConnectedToNetwork(){
            viewModel.reset()
            viewModel.fetchNews { [weak self] success in
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                    self?.collectionView.reloadData()
                }
            }
        }else{
            self.refreshControl.endRefreshing()
        }
       }
    private func loadNews() {
        if Reachability.isConnectedToNetwork(){
            viewModel.fetchNews { [weak self] success in
                let artical = self?.viewModel.articles
                if artical?.isEmpty == true {
                    self?.viewModel.articles = self?.LocalNews.map { local in
                        return Article(
                            source: Source(id: local.id, name: local.name),
                            author: local.author,
                            title: local.title,
                            description: local.des,
                            url: nil,
                            urlToImage: nil,
                            publishedAt: nil,
                            content: local.content
                        )
                    } ?? []
                }
                if let artical = artical{
                    for i in artical{
                        if !SGalleryHelper.shared.newsItemExists(id: i.source.id ?? "", name: i.source.name ?? ""){
                            let locationInfo = [
                                "author": i.author ?? "",
                                "content": i.content ?? "",
                                "title": i.title ?? "",
                                "des": i.description ?? "",
                                "name": i.source.name,
                                "id" : i.source.id,"index" : SGalleryHelper.shared.getFileIndex()] as [String: Any]
                            if let url = URL(string: i.urlToImage ?? ""){
                                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                                    guard let self = self, let data = data else { return }
                                    DispatchQueue.main.async {
                                        let tmp = ["img": data] as [String: Any]
                                        let combinedDictionary: [String: Any] = tmp.merging(locationInfo) { $1 }
                                        SGalleryHelper.shared.saveData(galleryInfo: combinedDictionary)
                                    }
                                }.resume()
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }else{
            let alert = UIAlertController(title: "No Internet Connection",
                                          message: "Please check your network settings.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.articles.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsPageCell", for: indexPath) as! NewsPageCell
        let article = viewModel.articles[indexPath.item]
        
        
        cell.configure(with: article)
        cell.onSwipeRight = { [weak self] in
            guard let self = self else { return }
            if Reachability.isConnectedToNetwork(){
                self.viewModel.articles.remove(at: indexPath.item)
                collectionView.deleteItems(at: [indexPath])
                collectionView.reloadData()
            }else{
                SGalleryHelper.shared.deleteNewsData(withId: article.source.name!)
                refreshTheData()
                collectionView.reloadData()
            }
        }
        cell.onSwipeLeft = { [weak self] in
            let alert = UIAlertController(title: article.title, message: article.description, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
            self!.present(alert, animated: true)
            
            
            
        }
        return cell
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleIndex = Int(scrollView.contentOffset.y / scrollView.frame.height)
        if visibleIndex >= viewModel.articles.count - 3 {
            loadNews()
        }
    }
}

extension NewsPagingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
   
}
