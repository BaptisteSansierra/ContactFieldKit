//
//  ContactItem.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 16/2/26.
//

import Foundation

/// ContactItem is used to store labeled phone/url/email like in Apple Contact :<label: value>
///     mobile: +1345678
///     home: +1987543
public struct ContactItem: Identifiable, Hashable, Sendable {
    
    // MARK: Static
    // v0: legacy format, before versioning (no "version" key)
    static private let lastSupportedVersion: Int = 0
    static private let version: Int = 1

    // MARK: Static creators
    public static func phone(_ value: String, label: PhoneLabel = .phone) -> ContactItem {
        ContactItem(value: value, label: ContactLabel.phone(label))
    }
    public static func email(_ value: String, label: EmailLabel = .email) -> ContactItem {
        ContactItem(value: value, label: ContactLabel.email(label))
    }
    public static func url(_ value: String, label: URLLabel = .url) -> ContactItem {
        ContactItem(value: value, label: ContactLabel.url(label))
    }

    // MARK: properties
    public let id: String
    public var label: ContactLabel
    public var value: String
    public var kind: ContactItemKind { label.kind }

    // MARK: inits
    internal init(value: String, label: ContactLabel) {
        self.id = UUID().uuidString
        self.label = label
        self.value = value
    }

#if false
    public init(value: String, phoneLabel: PhoneLabel = .phone) {
        self.id = UUID().uuidString
        self.label = ContactLabel.phone(phoneLabel)
        self.value = value
    }
    public init(value: String, emailLabel: EmailLabel = .email) {
        self.id = UUID().uuidString
        self.label = ContactLabel.email(emailLabel)
        self.value = value
    }
    public init(value: String, urlLabel: URLLabel = .url) {
        self.id = UUID().uuidString
        self.label = ContactLabel.url(urlLabel)
        self.value = value
    }
#endif
    
    // Used to create an empty new field
    public init(kind: ContactItemKind) {
        self.id = UUID().uuidString
        switch kind {
            case .phone: self.label = ContactLabel.defaultPhone
            case .email: self.label = ContactLabel.defaultEmail
            case .url: self.label = ContactLabel.defaultUrl
        }
        self.value = ""
    }

    // MARK: Codable
    public var rawValue: String {
        let data = try! JSONEncoder().encode(self)
        return String(decoding: data, as: UTF8.self)
    }

    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(ContactItem.self, from: data) else {
            return nil
        }
        self = decoded
    }
}

extension ContactItem: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        case version
        case id
        case value
        case kind
        case label
    }
    
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // No version: legacy format (v0)
        let version = try c.decodeIfPresent(Int.self, forKey: .version) ?? 0
        guard version >= Self.lastSupportedVersion else {
            throw ContactItemError.droppedVersion
        }
        guard version <= Self.version else {
            throw ContactItemError.unknownVersion
        }
        self.id = try c.decode(String.self, forKey: .id)
        self.value = try c.decode(String.self, forKey: .value)
        if version == 0 {
            self.label = try Self.decodeLegacyLabel(c)
            return
        }
        let kindRaw = try c.decode(String.self, forKey: .kind)
        let labelRaw = try c.decode(String.self, forKey: .label)
        guard let kind = ContactItemKind(rawValue: kindRaw) else {
            throw ContactItemError.unknownKind
        }
        self.label = ContactLabel(rawValue: labelRaw, kind: kind)
    }
    
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(Self.version, forKey: .version)
        try c.encode(id, forKey: .id)
        try c.encode(value, forKey: .value)
        try c.encode(kind, forKey: .kind)
        try c.encode(label.rawValue, forKey: .label)
    }
}

// MARK: - Legacy decoding (v0)
/// v0 label, synthesized Codable of the former single `Label` enum:
///     {"kind": "phone", "value": {"mobile": {}}}
///     {"kind": "phone", "value": {"custom": {"_0": "Papa"}}}
extension ContactItem {

    private struct LegacyLabel: Decodable {
        let kind: String
        let value: [String: LegacyLabelPayload]
    }

    private struct LegacyLabelPayload: Decodable {
        let custom: String?

        enum CodingKeys: String, CodingKey {
            case custom = "_0"
        }
    }

    private static func decodeLegacyLabel(_ c: KeyedDecodingContainer<CodingKeys>) throws -> ContactLabel {
        let legacy = try c.decode(LegacyLabel.self, forKey: .label)
        guard let kind = ContactItemKind(rawValue: legacy.kind) else {
            throw ContactItemError.unknownKind
        }
        guard legacy.value.count == 1, let (name, payload) = legacy.value.first else {
            throw DecodingError.dataCorruptedError(forKey: .label, in: c,
                                                   debugDescription: "Legacy label must have exactly one case")
        }
        guard name == "custom" else {
            // The former enum didn't check the kind: a label of another kind becomes a custom one
            return ContactLabel(rawValue: name, kind: kind)
        }
        guard let text = payload.custom else {
            throw DecodingError.dataCorruptedError(forKey: .label, in: c,
                                                   debugDescription: "Legacy custom label without text")
        }
        // Stored as custom: stays custom, even if named as a built-in label
        return ContactLabel(kind: kind, custom: text)
    }
}
