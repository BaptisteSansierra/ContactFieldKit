//
//  File.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 19/2/26.
//

import Foundation

public extension Array where Element == ContactItem {
    
    mutating func removeEmptyFields() {
        removeAll { item in
            let trimmedValue = item.value.trimmingCharacters(in: .whitespaces)
            return trimmedValue == ""
        }
    }
}
