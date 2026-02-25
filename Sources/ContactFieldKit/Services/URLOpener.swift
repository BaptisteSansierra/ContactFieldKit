//
//  URLOpener.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 19/2/26.
//

import Foundation
import UIKit

public enum URLOpenerError: Error {
    case invalidURL
    case cannotOpenPhoneURL
    case cannotOpenEmailURL
    case cannotOpenWebURL
}

public struct OpenURLAlert: Identifiable {
    public let id = UUID()
    let title: String
    let body: String
}

public struct URLOpener {

    // MARK: public methods
    static public func openURL(contactItem: ContactItem) throws {
        switch contactItem.label.kind {
            case .phone:
                try openPhoneURL(contactItem.value)
            case .email:
                try openEmailURL(contactItem.value)
            case .url:
                try openWebURL(contactItem.value)
        }
    }
    
    static public func alertContent(_ error: URLOpenerError) -> OpenURLAlert {
        return OpenURLAlert(title: errorTitle(error), body: errorBody(error))
    }

    // MARK: private methods
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
        
    static private func errorTitle(_ error: URLOpenerError) -> String {
        var key: String
        switch error {
            case .invalidURL:
                key = "error.invalid_link.title"
            case .cannotOpenPhoneURL:
                key = "error.cannot_open_phone_url.title"
            case .cannotOpenEmailURL:
                key = "error.cannot_open_email_url.title"
            case .cannotOpenWebURL:
                key = "error.cannot_open_web_url.title"
        }
        return String(localized: String.LocalizationValue(key), bundle: .module)
    }
    
    static private func errorBody(_ error: URLOpenerError) -> String {
        var key: String
        switch error {
            case .invalidURL:
                key = "error.invalid_link.body"
            case .cannotOpenPhoneURL:
                key = "error.cannot_open_phone_url.body"
            case .cannotOpenEmailURL:
                key = "error.cannot_open_email_url.body"
            case .cannotOpenWebURL:
                key = "error.cannot_open_web_url.body"
        }
        return String(localized: String.LocalizationValue(key), bundle: .module)
    }
}
