//
//  NewsFetchOperation.swift
//  NewsProfile
//
//  Created by Apple on 17/05/25.
//

import Foundation
class NewsFetchOperation: Operation {
    override func main() {
        if self.isCancelled { return }

        let viewModel = NewsViewModel()
        let semaphore = DispatchSemaphore(value: 0)

        viewModel.fetchNews { success in
            print("Background fetch: \(success ? "Success" : "Failed")")
            semaphore.signal()
        }

        semaphore.wait()
    }
}
