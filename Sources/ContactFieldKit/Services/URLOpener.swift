//
//  URLOpener.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 19/2/26.
//

import Foundation
import UIKit

internal enum URLOpenerError: Error {
    case invalidURL
    case cannotOpenPhoneURL
    case cannotOpenEmailURL
    case cannotOpenWebURL
}

internal struct URLOpener {

    static func openURL(contactItem: ContactItem) throws {
        switch contactItem.label.kind {
            case .phone:
                try openPhoneURL(contactItem.value)
            case .email:
                try openEmailURL(contactItem.value)
            case .url:
                try openWebURL(contactItem.value)
        }
    }
    
    static private func openPhoneURL(_ value: String) throws {
        guard let url = URL(string: "tel://\(value)") else {
            throw URLOpenerError.invalidURL
        }
        if !UIApplication.shared.canOpenURL(url) {
            throw URLOpenerError.cannotOpenPhoneURL
        }
        UIApplication.shared.open(url)
    }

    static private func openEmailURL(_ value: String) throws {
        guard let url = URL(string: "mailto://\(value)") else {
            throw URLOpenerError.invalidURL
        }
        if !UIApplication.shared.canOpenURL(url) {
            throw URLOpenerError.cannotOpenEmailURL
        }
        UIApplication.shared.open(url)
    }
    
    static private func openWebURL(_ value: String) throws {
        var string = value
        if !string.lowercased().hasPrefix("http://") &&
           !string.lowercased().hasPrefix("https://") {
            if !string.contains("://") {
                string = "https://" + string
            }
        }
        guard let url = URL(string: "\(string)"),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme.lowercased()) else {
            throw URLOpenerError.invalidURL
        }
        if !UIApplication.shared.canOpenURL(url) {
            throw URLOpenerError.cannotOpenWebURL
        }
        UIApplication.shared.open(url)
    }
}
