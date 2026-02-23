//
//  ContactLabel.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 16/2/26.
//

import Foundation

public struct ContactLabel: Hashable {
    
    public enum Kind: String, Codable {
        case phone, url, email
    }
    
    public enum Label: Hashable, Codable, Sendable {
        // Phone specific
        case phone, mobile
        // Url specific
        case url, homepage
        // Email specific
        case email, personal
        // Shared
        case work, home, school, other
        case custom(String)

        public var l10n: String {
            String(localized: String.LocalizationValue(key), bundle: .module)
        }
        
        /*
        public func isPhone() -> Bool {
            switch self {
                case .url, .homepage, .email, .personal:
                    return false
                default:
                    return true
            }
        }
        public func isUrl() -> Bool {
            switch self {
                case .phone, .mobile, .email, .personal:
                    return false
                default:
                    return true
            }
        }
        public func isEmail() -> Bool {
            switch self {
                case .url, .homepage, .phone, .mobile:
                    return false
                default:
                    return true
            }
        }
         */

        public var key: String {
            switch self {
                // phone
                case .phone:
                    return "label.phone"
                case .mobile:
                    return "label.mobile"
                // url
                case .url:
                    return "label.url"
                case .homepage:
                    return "label.homepage"
                // email
                case .email:
                    return "label.email"
                case .personal:
                    return "label.personal"
                // shared
                case .home:
                    return "label.home"
                case .work:
                    return "label.work"
                case .school:
                    return "label.school"
                case .other:
                    return "label.other"
                case .custom(let value):
                    return value
            }
        }
        
        static let phoneLabels: [Label] = [.phone, .mobile, .home, .work, .school, .other]
        static let urlLabels: [Label] = [.url, .homepage, .home, .work, .school, .other]
        static let emailLabels: [Label] = [.email, .personal, .home, .work, .school, .other]
    }
    
    public private(set) var kind: Kind
    public var value: Label

    internal static func allLabels(kind: Kind) -> [Label] {
        switch kind {
            case .phone:
                Label.phoneLabels
            case .url:
                Label.urlLabels
            case .email:
                Label.emailLabels
        }
    }
    
    internal func allLabels() -> [Label] {
        ContactLabel.allLabels(kind: kind)
    }
    
    public init(kind: Kind, label: Label) {
        self.kind = kind
        self.value = label
    }
    
    public init(kind: Kind) {
        self.kind = kind
        switch kind {
            case .phone:
                self.value = .phone
            case .url:
                self.value = .url
            case .email:
                self.value = .email
        }
    }
}


extension ContactLabel: Codable {

    internal enum CodingKeys: String, CodingKey {
        case kind
        case value
    }
    
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(kind, forKey: .kind)
        try c.encode(value, forKey: .value)
    }
    
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        kind = try c.decode(Kind.self, forKey: .kind)
        value = try c.decode(Label.self, forKey: .value)
    }
    
    public var rawValue: String {
        let data = try! JSONEncoder().encode(self)
        return String(decoding: data, as: UTF8.self)
    }

    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(ContactLabel.self, from: data)
        else { return nil }
        self = decoded
    }
}


/*
public enum ContactLabel: Hashable {
    
    case phone(PhoneLabel)
    case url(URLLabel)
    case email(EmailLabel)

    public protocol ContactLabelValue: Codable, Hashable, Sendable {
        static var regularCases: [some ContactLabelValue] { get }
        var labelKey: String { get }
        init(custom: String)
    }

    public enum PhoneLabel: ContactLabelValue {
        public static let regularCases: [PhoneLabel] = {
            [PhoneLabel.phone,
             PhoneLabel.mobile,
             PhoneLabel.home,
             PhoneLabel.work,
             PhoneLabel.school,
             PhoneLabel.other]
        }()
        case phone, mobile, home, work, school, other
        case custom(String)
        
        public var labelKey: String {
            switch self {
                case .phone:
                    return "label.phone"
                case .mobile:
                    return "label.mobile"
                case .home:
                    return "label.home"
                case .work:
                    return "label.work"
                case .school:
                    return "label.school"
                case .other:
                    return "label.other"
                case .custom(let value):
                    return value
            }
        }
        
        public init(custom: String) {
            self = .custom(custom)
        }
    }
    
    public enum URLLabel: ContactLabelValue {
        public static let regularCases: [URLLabel] = {
            [URLLabel.url,
             URLLabel.homepage,
             URLLabel.home,
             URLLabel.work,
             URLLabel.school,
             URLLabel.other]
        }()

        case url, homepage, home, work, school, other
        case custom(String)
        
        public var labelKey: String {
            switch self {
                case .url:
                    return "label.url"
                case .homepage:
                    return "label.homepage"
                case .home:
                    return "label.home"
                case .work:
                    return "label.work"
                case .school:
                    return "label.school"
                case .other:
                    return "label.other"
                case .custom(let value):
                    return value
            }
        }

        public init(custom: String) {
            self = .custom(custom)
        }
    }
    
    public enum EmailLabel: ContactLabelValue {
        public static let regularCases: [EmailLabel] = {
            [EmailLabel.email,
             EmailLabel.personal,
             EmailLabel.work,
             EmailLabel.home,
             EmailLabel.school,
             EmailLabel.other]
        }()

        case email, personal, work, home, school, other
        case custom(String)
        
        public var labelKey: String {
            switch self {
                case .email:
                    return "label.email"
                case .personal:
                    return "label.personal"
                case .work:
                    return "label.work"
                case .home:
                    return "label.home"
                case .school:
                    return "label.school"
                case .other:
                    return "label.other"
                case .custom(let value):
                    return value
            }
        }
        
        public init(custom: String) {
            self = .custom(custom)
        }
    }

    public var label: ContactLabelValue {
        switch self {
            case .phone(let label):
                return label
            case .url(let label):
                return label
            case .email(let label):
                return label
        }
    }

    internal init(labelValue: PhoneLabel) {
        self = .phone(labelValue)
    }
    internal init(labelValue: URLLabel) {
        self = .url(labelValue)
    }
    internal init(labelValue: EmailLabel) {
        self = .email(labelValue)
    }

    /*
    internal init(labelValue: ContactLabelValue) {
        if type(of: labelValue) == PhoneLabel.self {
            self = .phone(labelValue as PhoneLabel)
        } else if let urlLabel = labelValue as? URLLabel {
            self = .url(urlLabel)
        } else if let emailLabel = labelValue as? EmailLabel {
            self = .email(emailLabel)
        }
        fatalError("Undefined label value: \(labelValue) = \(type(of: labelValue))")
    }
     */
}

extension ContactLabel: Codable {

    internal enum CodingKeys: String, CodingKey {
        case kind
        case label
    }

    public enum Kind: String, Codable {
        case phone, url, email
    }
    
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .phone(let label):
                try c.encode(Kind.phone, forKey: .kind)
                try c.encode(label, forKey: .label)
            case .url(let label):
                try c.encode(Kind.url, forKey: .kind)
                try c.encode(label, forKey: .label)
            case .email(let label):
                try c.encode(Kind.email, forKey: .kind)
                try c.encode(label, forKey: .label)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)
        switch kind {
            case .phone:
                self = .phone(try c.decode(PhoneLabel.self, forKey: .label))
            case .url:
                self = .url(try c.decode(URLLabel.self, forKey: .label))
            case .email:
                self = .email(try c.decode(EmailLabel.self, forKey: .label))
        }
    }
    
    public var rawValue: String {
        let data = try! JSONEncoder().encode(self)
        return String(decoding: data, as: UTF8.self)
    }

    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(ContactLabel.self, from: data)
        else { return nil }
        self = decoded
    }
}

*/
