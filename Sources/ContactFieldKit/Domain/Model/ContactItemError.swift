//
//  ContactItemError.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 24/11/26.
//

import Foundation

public enum ContactItemError: Error {
    case droppedVersion       // Not supported anymore
    case unknownVersion       // Future version
    case unknownKind          // kind raw value unknown
}
