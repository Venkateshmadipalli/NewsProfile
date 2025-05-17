//
//  File.swift
//  NewsProfile
//
//  Created by Apple on 16/05/25.
//

import Foundation
import UIKit
class SFileManager: NSObject {
    static let shared = SFileManager()
    let folderPath: URL =  {
        let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0])
        let dirPath = DocumentDirectory.appendingPathComponent("SGallery")
        do {
            try FileManager.default.createDirectory(atPath: dirPath!.path, withIntermediateDirectories: true, attributes: nil)
            return dirPath!
        } catch {
            return "".toURL!
        }
    }()
    let editedFolderPath: URL =  {
        let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0])
        let dirPath = DocumentDirectory.appendingPathComponent("Temp")
        do {
            try FileManager.default.createDirectory(atPath: dirPath!.path, withIntermediateDirectories: true, attributes: nil)
            return dirPath!
        } catch {
            return "".toURL!
        }
    }()
    
}
extension String {
    var toURL: URL? {
        return URL(string: self)
    }
    var toInt: Int {
        return Int(self) ?? 0
    }
    func isValidEmail() -> Bool {
        let emailString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let email = NSPredicate(format:"SELF MATCHES %@", emailString)
        return email.evaluate(with: self)
    }
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    func isValidPassword() -> Bool {
        let regularExpression = "^(?=.?[a-z])(?=.?[0-9])(?=.?[#?!@$%^&-]).{8,}$"
        let passwordValidation = NSPredicate.init(format: "SELF MATCHES %@", regularExpression)
        return passwordValidation.evaluate(with: self)
    }
    
    
    func withReplacedCharacters(_ oldChar: String, by newChar: String) -> String {
        let newStr = self.replacingOccurrences(of: oldChar, with: newChar, options: .literal, range: nil)
        return newStr
    }
    
}
