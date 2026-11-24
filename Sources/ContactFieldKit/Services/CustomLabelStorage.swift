//
//  CustomLabelStorage.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 20/2/26.
//

import Foundation

internal struct CustomLabelStorage {
    
    static private let keyBase: String = "ContactFieldKit.custom."
    
    static func store(kind: ContactItemKind,
                      value: String) {
        let ud = UserDefaults.standard
        if let values = ud.value(forKey: key(kind)) as? [String] {
            var newValues = values
            guard !newValues.contains(value) else {
                return
            }
            newValues.append(value)
            ud.set(newValues, forKey: key(kind))
        } else {
            ud.set([value], forKey: key(kind))
        }
    }
    
    static func labels(kind: ContactItemKind) -> [String] {
        let ud = UserDefaults.standard
        guard let values = ud.value(forKey: key(kind)) as? [String] else {
            return []
        }
        return values
    }
     
    static private func key(_ kind: ContactItemKind) -> String {
        keyBase + kind.rawValue
    }
}
