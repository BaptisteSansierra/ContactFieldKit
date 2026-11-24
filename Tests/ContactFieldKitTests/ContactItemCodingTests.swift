//
//  ContactItemCodingTests.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 24/11/26.
//

import Foundation
import Testing
@testable import ContactFieldKit

@Suite("ContactItem coding")
struct ContactItemCodingTests {

    // MARK: - Helpers
    private func decode(_ json: String) throws -> ContactItem {
        try JSONDecoder().decode(ContactItem.self, from: Data(json.utf8))
    }

    private func jsonObject(_ item: ContactItem) throws -> [String: Any] {
        let data = try JSONEncoder().encode(item)
        return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    // MARK: - Round trip
    @Test("Round trip keeps id, value and label",
          arguments: [
            ContactItem.phone("+12125557483"),
            ContactItem.phone("+16465552917", label: .mobile),
            ContactItem.phone("+13125556042", label: .work),
            ContactItem.email("john.doe@home.com"),
            ContactItem.email("john.doe@home.com", label: .personal),
            ContactItem.email("john.doe@home.com", label: .school),
            ContactItem.url("google.com"),
            ContactItem.url("google.com", label: .homepage),
            ContactItem.url("google.com", label: .other),
          ])
    func roundTrip(_ item: ContactItem) throws {
        let decoded = try #require(ContactItem(rawValue: item.rawValue))
        #expect(decoded == item)
        #expect(decoded.kind == item.kind)
    }

    @Test("Custom label keeps its text", arguments: ["olala", "club", "Home", "custom"])
    func customLabelRoundTrip(_ text: String) throws {
        let items = [ContactItem.phone("1", label: .custom(text)),
                     ContactItem.email("a@b.c", label: .custom(text)),
                     ContactItem.url("a.com", label: .custom(text))]
        for item in items {
            let decoded = try #require(ContactItem(rawValue: item.rawValue))
            #expect(decoded.label == item.label)
            #expect(decoded.label.l10n == text)
        }
    }

    @Test("Custom label named as a built-in one decodes as the built-in (intended)")
    func customNamedAsBuiltIn() throws {
        let home = try #require(ContactItem(rawValue: ContactItem.phone("1", label: .custom("home")).rawValue))
        #expect(home.label == .phone(.home))
        let mobile = try #require(ContactItem(rawValue: ContactItem.phone("1", label: .custom("mobile")).rawValue))
        #expect(mobile.label == .phone(.mobile))
        // A built-in name of another kind stays custom
        let email = try #require(ContactItem(rawValue: ContactItem.email("a@b.c", label: .custom("mobile")).rawValue))
        #expect(email.label == .email(.custom("mobile")))
    }

    // MARK: - Encoded format
    @Test("Encoded format is flat and versioned")
    func encodedFormat() throws {
        let item = ContactItem.phone("+12125557483", label: .mobile)
        let object = try jsonObject(item)
        #expect(object["version"] as? Int == 1)
        #expect(object["id"] as? String == item.id)
        #expect(object["value"] as? String == "+12125557483")
        #expect(object["kind"] as? String == "phone")
        #expect(object["label"] as? String == "mobile")
        #expect(object.count == 5)
    }

    @Test("Encoded label strings",
          arguments: [
            (ContactItem.phone("1"), "phone", "phone"),
            (ContactItem.phone("1", label: .home), "phone", "home"),
            (ContactItem.email("a@b.c"), "email", "email"),
            (ContactItem.email("a@b.c", label: .personal), "email", "personal"),
            (ContactItem.url("a.com"), "url", "url"),
            (ContactItem.url("a.com", label: .homepage), "url", "homepage"),
            (ContactItem.url("a.com", label: .custom("olala")), "url", "olala"),
          ])
    func encodedLabel(_ item: ContactItem, kind: String, label: String) throws {
        let object = try jsonObject(item)
        #expect(object["kind"] as? String == kind)
        #expect(object["label"] as? String == label)
    }

    // MARK: - Decoding
    @Test("Decodes a valid v1 payload")
    func decodeV1() throws {
        let item = try decode(#"{"version":1,"id":"abc","value":"+33600000000","kind":"phone","label":"work"}"#)
        #expect(item.id == "abc")
        #expect(item.value == "+33600000000")
        #expect(item.kind == .phone)
        #expect(item.label == .phone(.work))
    }

    @Test("Unknown label name decodes as custom")
    func decodeUnknownLabel() throws {
        let item = try decode(#"{"version":1,"id":"abc","value":"1","kind":"phone","label":"fax"}"#)
        #expect(item.label == .phone(.custom("fax")))
    }

    @Test("Missing version with the v1 shape is rejected (read as legacy)")
    func decodeMissingVersion() {
        #expect(throws: DecodingError.self) {
            try decode(#"{"id":"abc","value":"1","kind":"phone","label":"phone"}"#)
        }
    }

    @Test("Version below the supported one is a dropped version")
    func decodeOldVersion() {
        #expect(throws: ContactItemError.droppedVersion) {
            try decode(#"{"version":-1,"id":"abc","value":"1","kind":"phone","label":"phone"}"#)
        }
    }

    @Test("Future version is an unknown version")
    func decodeFutureVersion() {
        #expect(throws: ContactItemError.unknownVersion) {
            try decode(#"{"version":2,"id":"abc","value":"1","kind":"phone","label":"phone"}"#)
        }
    }

    @Test("Unknown kind is rejected")
    func decodeUnknownKind() {
        #expect(throws: ContactItemError.unknownKind) {
            try decode(#"{"version":1,"id":"abc","value":"1","kind":"fax","label":"phone"}"#)
        }
    }

    @Test("Missing field is rejected", arguments: ["id", "value", "kind", "label"])
    func decodeMissingField(_ field: String) throws {
        var object: [String: Any] = ["version": 1, "id": "abc", "value": "1", "kind": "phone", "label": "phone"]
        object[field] = nil
        let data = try JSONSerialization.data(withJSONObject: object)
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(ContactItem.self, from: data)
        }
    }

    @Test("rawValue init returns nil on invalid input",
          arguments: ["", "not json", "{}", #"{"kind":"phone","value":{"label":"mobile"}}"#])
    func rawValueInvalid(_ raw: String) {
        #expect(ContactItem(rawValue: raw) == nil)
    }
}
