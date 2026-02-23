//
//  ContactFieldUIConfig.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 17/2/26.
//

import SwiftUI

/// UI Configuration: override values for custom configuration
@MainActor
public enum ContactFieldUIConfig {
    
    // Fonts
    public static var bodyTextFont: Font = Font.system(size: 17, weight: .regular)
    public static var captionTextFont: Font = Font.system(size: 12, weight: .regular)

    // Colors
    public static var backgroundPrimary: Color = Color(uiColor: UIColor.systemBackground)
    public static var backgroundSecondary: Color = Color(uiColor: UIColor.secondarySystemBackground)
    public static var backgroundTertiary: Color = Color(uiColor: UIColor.tertiarySystemBackground)

    public static var textPrimaryColor: Color = Color(uiColor: UIColor.label)
    public static var textSecondaryColor: Color = Color(uiColor: UIColor.secondaryLabel)
    
    public static var success: Color = Color(light: Color(rgba: "#2E7D32"), dark: Color(rgba: "#81C784"))
    public static var destructive: Color = .red
}
