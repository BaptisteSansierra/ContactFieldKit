//
//  IfModifier.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 17/2/26.
//

import SwiftUI

internal struct IfModifier<Base: View, Result: View>: ViewModifier {

    let condition: Bool
    let action: (Base) -> Result
    
    func body(content: Content) -> some View {
        if condition, let base = content as? Base {
            action(base)
        } else {
            content
        }
    }
}
