//
//  File.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 25/3/26.
//

import Foundation

internal extension String {

    var capitalizeFirst: String {
        guard let first = self.first else { return self }
        return String(first).capitalized + self.dropFirst()
    }
}
