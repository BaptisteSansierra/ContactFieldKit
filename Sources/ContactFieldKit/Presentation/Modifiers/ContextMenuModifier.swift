//
//  ContextMenuModifier.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 19/2/26.
//

import SwiftUI

struct ContextMenuModifier: ViewModifier {
    let contactItem: ContactItem
    let actions: [UIAction]
    let willEnd: (() -> Void)?
    let willDisplay: (() -> Void)?
    let isHighlighted: Bool

    func body(content: Content) -> some View {
        ContextMenuInteractionView(view: { content },
                                   actions: actions,
                                   willEnd: willEnd,
                                   willDisplay: willDisplay,
                                   isHighlighted: isHighlighted
        )
    }
}
