//
//  NewsDataModel.swift
//  NewsProfile
//
//  Created by Apple on 17/05/25.
//

import Foundation
import UIKit
import CoreData

class NewsDataModel: NSObject {
    var index: Int
    var img: Data
    var author: String
    var content: String
    var title: String
    var des: String
    var name : String
    var id : String
    override init() {
        img = Data()
        author = ""
        content = ""
        title = ""
        des = ""
        name = ""
        id = ""
        index = 0
    }
    func initWithData(galleryList: NSManagedObject) ->NewsDataModel {
        index = galleryList.value(forKey: "index") as? Int ?? 0
        img = galleryList.value(forKey: "img") as? Data ?? Data()
        author = galleryList.value(forKey: "author") as? String ?? ""
        content = galleryList.value(forKey: "content") as? String ?? ""
        title = galleryList.value(forKey: "title") as? String ?? ""
        des = galleryList.value(forKey: "des") as? String ?? ""
        name = galleryList.value(forKey: "name") as? String ?? ""
        id = galleryList.value(forKey: "id") as? String ?? ""
                return self
    }
    
}
