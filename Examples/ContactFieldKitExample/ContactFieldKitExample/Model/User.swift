//
//  User.swift
//  ContactFieldKitExample
//
//  Created by baptiste sansierra on 17/2/26.
//

import Foundation
import ContactFieldKit

struct User: Hashable, Identifiable {
    var id: String
    var name: String
    var phones: [ContactItem]
    var emails: [ContactItem]
    var urls: [ContactItem]
    
    init(name: String, phones: [ContactItem], emails: [ContactItem], urls: [ContactItem]) {
        self.id = UUID().uuidString
        self.name = name
        self.phones = phones
        self.emails = emails
        self.urls = urls
    }
    
    func equal(_ other: User) -> Bool {
        guard id == other.id else { return false }
        guard name == other.name else { return false }
        guard phones.count == other.phones.count else { return false }
        guard emails.count == other.emails.count else { return false }
        guard urls.count == other.urls.count else { return false }
        for i in 0..<phones.count {
            if phones[i] != other.phones[i] { return false }
        }
        for i in 0..<emails.count {
            if emails[i] != other.emails[i] { return false }
        }
        for i in 0..<urls.count {
            if urls[i] != other.urls[i] { return false }
        }
        return true
    }
    
    func initials() -> String {
        name
            .split(whereSeparator: \.isWhitespace)
            .compactMap { $0.first }
            .prefix(2)
            .map { String($0).uppercased() }
            .joined()
    }
}

extension User: CustomStringConvertible {

    var description: String {
        var desc = "--- \(name)"
        desc += "\n\t-- Phones"
        for p in phones {
            desc += "\n\t \(p.type.rawValue) : \(p.value)"
        }
        desc += "\n\t-- Emails"
        for p in emails {
            desc += "\n\t \(p.type.rawValue) : \(p.value)"
        }
        desc += "\n\t-- Urls"
        for p in urls {
            desc += "\n\t \(p.type.rawValue) : \(p.value)"
        }
        desc += "\n-------"
        return desc
    }
}
