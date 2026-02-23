//
//  View+ContactFieldKit.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 17/2/26.
//

import SwiftUI

internal extension View {
    
    func `if`<Content: View>(_ condition: Bool, action: @escaping (Self)->Content ) -> some View {
        modifier(IfModifier(condition: condition, action: action))
    }
    
    func contextMenu(contactItem: ContactItem,
                     actions: [UIAction],
                     isHighlighted: Bool = false,  // ← Add parameter
                     willEnd: (() -> Void)? = nil,
                     willDisplay: (() -> Void)? = nil) -> some View {
        modifier(ContextMenuModifier(contactItem: contactItem,
                                         actions: actions,
                                         willEnd: willEnd,
                                         willDisplay: willDisplay,
                                        isHighlighted: isHighlighted
                                    ))
    }
}
