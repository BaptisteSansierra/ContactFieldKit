//
//  Untitled.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 16/2/26.
//

import Foundation

/// ContactItem is used to store labeled phone/url/email like in Apple Contact :<label: value>
///     mobile: +1345678
///     home: +1987543
public struct ContactItem: Identifiable, Hashable {

    // MARK: properties
    enum ContactItemError: Error {
        case invalidLabel
    }
//    public var labelKey: String {
//        switch type {
//            case .phone(let label):
//                return label.labelKey
//            case .email(let label):
//                return label.labelKey
//            case .url(let label):
//                return label.labelKey
//        }
//    }
    public var rawValue: String {
        let data = try! JSONEncoder().encode(self)
        return String(decoding: data, as: UTF8.self)
    }
    public let id: String
    public var label: ContactLabel
    public var value: String

    @available(*, deprecated, renamed: "label")
    public var type: ContactLabel { return label }

    // MARK: inits
    /*
    public init(phone: String, label: ContactLabel.Label) throws {
        guard label.isPhone() else {
            throw ContactItemError.invalidLabel
        }
        self.id = UUID().uuidString
        self.label = ContactLabel(kind: .phone, label: label)
        self.value = phone
    }

    public init(url: String, label: ContactLabel.Label) throws {
        guard label.isUrl() else {
            throw ContactItemError.invalidLabel
        }
        self.id = UUID().uuidString
        self.label = ContactLabel(kind: .phone, label: label)
        self.value = url
    }

    public init(email: String, label: ContactLabel.Label) throws {
        guard label.isEmail() else {
            throw ContactItemError.invalidLabel
        }
        self.id = UUID().uuidString
        self.label = ContactLabel(kind: .phone, label: label)
        self.value = email
    }
     */

    public init(value: String, label: ContactLabel) {
        self.id = UUID().uuidString
        // TODO: should we check label isPhone() isUrl() isEmail()
        self.label = label
        self.value = value
    }
    
    
//    public init(url: String, label: ContactLabel.URLLabel) {
//        self.id = UUID().uuidString
//        self.type = .url(label)
//        self.value = url
//    }
//    public init(email: String, label: ContactLabel.EmailLabel) {
//        self.id = UUID().uuidString
//        self.type = .email(label)
//        self.value = email
//    }
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(ContactItem.self, from: data) else {
            return nil
        }
        self = decoded
    }
    public init(kind: ContactLabel.Kind) {
        self.id = UUID().uuidString
        self.label = ContactLabel(kind: kind)
        self.value = ""
    }
}

extension ContactItem: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        case id
        case label
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(String.self, forKey: .id)
        self.value = try c.decode(String.self, forKey: .value)
        self.label = try c.decode(ContactLabel.self, forKey: .label)
    }
    
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(label, forKey: .label)
        try c.encode(value, forKey: .value)
    }
}
