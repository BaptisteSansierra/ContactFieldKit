//
//  CustomLabelStorage.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 20/2/26.
//

import Foundation

internal struct CustomLabelStorage {
    
    static private let keyBase: String = "ContactFieldKit.custom."
    
    static func store(kind: ContactLabel.Kind,
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
    
    static func labels(kind: ContactLabel.Kind) -> [String] {
        let ud = UserDefaults.standard
        guard let values = ud.value(forKey: key(kind)) as? [String] else {
            return []
        }
        return values
    }
     
    static private func key(_ kind: ContactLabel.Kind) -> String {
        keyBase + kind.rawValue
    }
}
