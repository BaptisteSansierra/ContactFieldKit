//
//  ContactLabel.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 16/2/26.
//

import Foundation

public enum SharedLabel: Hashable, Sendable {
    case work, home, school, other
    case custom(String)
    
    // MARK: internal properties
    internal var l10nKey: String { "label.\(key)" }
    internal var key: String {
        switch self {
            case .home: "home"
            case .work: "work"
            case .school: "school"
            case .other: "other"
            case .custom(let value): value
        }
    }
    internal var l10n: String {
        switch self {
            case .custom(let value): value
            default:
                String(localized: String.LocalizationValue(l10nKey), bundle: .module)
        }
    }
    internal var rawValue: String {
        switch self {
            case .custom(let value): value
            default: key
        }
    }

    // MARK: internal init
    internal init(rawValue: String) {
        switch rawValue {
            case "home": self = .home
            case "work": self = .work
            case "school": self = .school
            case "other": self = .other
            default : self = .custom(rawValue)
        }
    }
    
    // MARK: internal methods
    internal static func allLabels() -> [SharedLabel] {
        [Self.home, Self.work, Self.school, Self.other]
    }
}

public protocol ContactLabelValue: Hashable, Sendable {
    static func shared(_ label: SharedLabel) -> Self
}

public extension ContactLabelValue {
    static var work: Self { .shared(.work) }
    static var home: Self { .shared(.home) }
    static var school: Self { .shared(.school) }
    static var other: Self { .shared(.other) }
    static func custom(_ value: String) -> Self { .shared(.custom(value)) }
}

internal protocol ContactLabelValueItn {
    var key: String { get }
    var l10nKey: String { get }
    var l10n: String { get }
    var rawValue: String { get }
    init(rawValue: String)
}

internal extension ContactLabelValueItn {
    internal var l10nKey: String { "label.\(key)" }
    internal var rawValue: String { key }
}

public enum PhoneLabel: ContactLabelValue, ContactLabelValueItn{
    case phone, mobile
    case shared(SharedLabel)

    // MARK: static stuff
    static let `default`: PhoneLabel = .phone

    internal static func allLabels() -> [PhoneLabel] {
        var all = [Self.phone, Self.mobile]
        all += SharedLabel.allLabels()
            .map { PhoneLabel.shared($0) }
        return all
    }

    // MARK: internal properties
    internal var key: String {
        switch self {
            case .phone: "phone"
            case .mobile: "mobile"
            case .shared(let shared): shared.key
        }
    }
    internal var l10n: String {
        switch self {
            case .shared(let shared): shared.l10n
            default:
                String(localized: String.LocalizationValue(l10nKey), bundle: .module)
        }
    }

    // MARK: internal init
    internal init(rawValue: String) {
        switch rawValue {
            case "phone": self = .phone
            case "mobile": self = .mobile
            default : self = .shared(SharedLabel(rawValue: rawValue))
        }
    }
}

public enum EmailLabel: ContactLabelValue, ContactLabelValueItn {
    case email, personal
    case shared(SharedLabel)
    
    // MARK: static stuff
    static let `default`: EmailLabel = .email

    internal static func allLabels() -> [EmailLabel] {
        var all = [Self.email, Self.personal]
        all += SharedLabel.allLabels()
            .map { EmailLabel.shared($0) }
        return all
    }

    // MARK: internal properties
    internal var key: String {
        switch self {
            case .email: "email"
            case .personal: "personal"
            case .shared(let shared): shared.key
        }
    }
    internal var l10n: String {
        switch self {
            case .shared(let shared): shared.l10n
            default:
                String(localized: String.LocalizationValue(l10nKey), bundle: .module)
        }
    }
    
    // MARK: internal init
    internal init(rawValue: String) {
        switch rawValue {
            case "email": self = .email
            case "personal": self = .personal
            default : self = .shared(SharedLabel(rawValue: rawValue))
        }
    }
}

public enum URLLabel: ContactLabelValue, ContactLabelValueItn {
    case url, homepage
    case shared(SharedLabel)
    
    // MARK: static stuff
    static let `default`: URLLabel = .url

    internal static func allLabels() -> [URLLabel] {
        var all = [Self.url, Self.homepage]
        all += SharedLabel.allLabels()
            .map { URLLabel.shared($0) }
        return all
    }

    // MARK: internal properties
    internal var key: String {
        switch self {
            case .url: "url"
            case .homepage: "homepage"
            case .shared(let shared): shared.key
        }
    }
    internal var l10n: String {
        switch self {
            case .shared(let shared): shared.l10n
            default:
                String(localized: String.LocalizationValue(l10nKey), bundle: .module)
        }
    }
    
    // MARK: internal init
    internal init(rawValue: String) {
        switch rawValue {
            case "url": self = .url
            case "homepage": self = .homepage
            default : self = .shared(SharedLabel(rawValue: rawValue))
        }
    }
}

public enum ContactLabel: Hashable, Sendable {
    
    case phone(PhoneLabel)
    case email(EmailLabel)
    case url(URLLabel)

    // MARK: - static public properties
    static public let defaultPhone: Self = .phone(PhoneLabel.default)
    static public let defaultEmail: Self = .email(EmailLabel.default)
    static public let defaultUrl: Self = .url(URLLabel.default)

    // MARK: - internal init
    internal init(kind: ContactItemKind, custom: String) {
        switch kind {
            case .phone:
                self = .phone(.custom(custom))
            case .email:
                self = .email(.custom(custom))
            case .url:
                self = .url(.custom(custom))
        }
    }
    
    // MARK: - internal properties
    internal var l10n: String {
        switch self {
            case .phone(let item): item.l10n
            case .email(let item): item.l10n
            case .url(let item): item.l10n
        }
    }
    internal var key: String {
        switch self {
            case .phone(let item): item.key
            case .email(let item): item.key
            case .url(let item): item.key
        }
    }

    internal var kind: ContactItemKind {
        switch self {
            case .phone: .phone
            case .email: .email
            case .url: .url
        }
    }

    // MARK: - internal methods
    internal static func allLabels(kind: ContactItemKind) -> [ContactLabel] {
        switch kind {
            case .phone:
                PhoneLabel.allLabels()
                    .map { ContactLabel.phone($0) }
            case .email:
                EmailLabel.allLabels()
                    .map { ContactLabel.email($0) }
            case .url:
                URLLabel.allLabels()
                    .map { ContactLabel.url($0) }
        }
    }
    
    internal func allLabels() -> [ContactLabel] {
        ContactLabel.allLabels(kind: kind)
    }
    
    // MARK: - coding utils
    internal var rawValue: String {
        switch self {
            case .phone(let label): label.rawValue
            case .email(let label): label.rawValue
            case .url(let label): label.rawValue
        }
    }
    
    internal init(rawValue: String, kind: ContactItemKind) {
        switch kind {
            case .phone: self = .phone(PhoneLabel(rawValue: rawValue))
            case .email: self = .email(EmailLabel(rawValue: rawValue))
            case .url: self = .url(URLLabel(rawValue: rawValue))
        }
    }
}
