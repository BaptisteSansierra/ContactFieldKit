//
//  ContactItemUI.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 16/2/26.
//

import Foundation
import SwiftUI

public struct ContactItemUI: Equatable {
    static let rowHeight: CGFloat = 45

    var height: CGFloat
    var opacity: CGFloat
    var clip: Bool
    var separatorOpacity: CGFloat
    var offset: CGFloat
    var deleteFrame: CGRect

    public var toBeDeleted: Bool = false

    public var contactItem: ContactItem
    
    public init(contactItem: ContactItem) {
        self.contactItem = contactItem
        // Default
        self.height = ContactItemUI.rowHeight
        self.opacity = 1
        self.clip = false
        self.separatorOpacity = 1
        self.offset = 0
        self.deleteFrame = .zero
    }
    
    internal init(kind: ContactLabel.Kind,
                  height: CGFloat,
                  opacity: CGFloat,
                  clip: Bool,
                  separatorOpacity: CGFloat) {
        self.contactItem = ContactItem(kind: kind)
        
        self.height = height
        self.opacity = opacity
        self.clip = clip
        self.separatorOpacity = separatorOpacity
        self.offset = 0
        self.deleteFrame = .zero
    }
}
