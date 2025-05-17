//
//  NewsViewModel.swift
//  NewsProfile
//
//  Created by Apple on 16/05/25.
//
//
import Foundation
class NewsViewModel {
    public var currentPage = 1
    private let pageSize = 10
    private var isFetching = false
    var articles: [Article] = []
    func fetchNews(completion: @escaping (Bool) -> Void) {
        
        guard !isFetching else { return }
        isFetching = true
        let urlString = "https://newsapi.org/v2/top-headlines?country=us&pageSize=\(pageSize)&page=\(currentPage)&apiKey=246f2b4e33a64b079a5bc0d90a741f3c"
        print(urlString)
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { self.isFetching = false }

            guard let data = data, error == nil else {
                completion(false)
                return
            }

            do {
                let response = try JSONDecoder().decode(NewsResponse.self, from: data)
                self.articles.append(contentsOf: response.articles ?? [])
                self.currentPage += 1
                completion(true)
            } catch {
                print("Error decoding:", error)
                completion(false)
            }
        }.resume()
    }
    func reset() {
           currentPage = 1
           articles.removeAll()
       }
}
import Foundation

//class NewsViewModel {
//    private var currentPage = 1
//    private let pageSize = 10
//    private var isFetching = false
//    var articles: [Article] = []
//    private let baseURL = "https://newsapi.org/v2/top-headlines"
//    private let apiKey = "c99e6024510847e3af5a2da405347a26"
//
//    func fetchNews(completion: @escaping (Bool) -> Void) {
//        guard !isFetching else { return }
//        isFetching = true
//        var components = URLComponents(string: baseURL)
//        components?.queryItems = [
//            URLQueryItem(name: "country", value: "us"),
//            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
//            URLQueryItem(name: "page", value: "\(currentPage)"),
//            URLQueryItem(name: "apiKey", value: apiKey)
//        ]
//        guard let url = components?.url else {
//            isFetching = false
//            completion(false)
//            return
//        }
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            defer { self.isFetching = false }
//
//            guard let data = data, error == nil else {
//                completion(false)
//                return
//            }
//            do {
//                let response = try JSONDecoder().decode(NewsResponse.self, from: data)
//                self.articles.append(contentsOf: response.articles ?? [])
//                self.currentPage += 1
//                completion(true)
//            } catch {
//                print("Error decoding:", error)
//                completion(false)
//            }
//        }.resume()
//    }
//    func reset() {
//        currentPage = 1
//        articles.removeAll()
//    }
//}
