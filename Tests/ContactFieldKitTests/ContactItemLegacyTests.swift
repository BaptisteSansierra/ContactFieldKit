//
//  ContactItemLegacyTests.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 24/11/26.
//

import Foundation
import Testing
@testable import ContactFieldKit

/// Legacy format (v0, no "version"), as stored before the label rework
@Suite("ContactItem legacy decoding")
struct ContactItemLegacyTests {

    // MARK: - Helpers
    private func decode(_ json: String) throws -> ContactItem {
        try JSONDecoder().decode(ContactItem.self, from: Data(json.utf8))
    }

    private func legacy(kind: String, label: String, value: String = "1") -> String {
        #"{"id":"abc","label":{"kind":"\#(kind)","value":\#(label)},"value":"\#(value)"}"#
    }

    // MARK: - Stored samples
    @Test("Custom phone labels")
    func customPhone() throws {
        let papa = try decode(#"{"label":{"kind":"phone","value":{"custom":{"_0":"Papa"}}},"id":"D252CBB8-B8F1-47E1-BFE9-C2F6B558825F","value":"0033 600 000 000"}"#)
        #expect(papa.id == "D252CBB8-B8F1-47E1-BFE9-C2F6B558825F")
        #expect(papa.value == "0033 600 000 000")
        #expect(papa.label == .phone(.custom("Papa")))

        // Keys in another order, value kept as is (leading space)
        let maman = try decode(#"{"label":{"value":{"custom":{"_0":"Maman"}},"kind":"phone"},"id":"788ABB52-0C07-44BD-B36C-D5899EDFB4C6","value":" +33600000001"}"#)
        #expect(maman.value == " +33600000001")
        #expect(maman.label == .phone(.custom("Maman")))
    }

    @Test("Built-in url label, escaped slashes")
    func url() throws {
        let item = try decode(#"{"value":"http:\/\/example.com\/path\/","label":{"kind":"url","value":{"url":{}}},"id":"DCCEAB42-94C8-4EC0-A152-FAC621A3FD79"}"#)
        #expect(item.value == "http://example.com/path/")
        #expect(item.label == .url(.url))
    }

    @Test("Built-in email label")
    func email() throws {
        let item = try decode(#"{"id":"030F3885-8D5D-41D0-A0F1-6BDE424B0F32","label":{"kind":"email","value":{"email":{}}},"value":"john.doe@example.com"}"#)
        #expect(item.value == "john.doe@example.com")
        #expect(item.label == .email(.email))
    }

    // MARK: - Every former label
    @Test("Every former built-in label", arguments: [
        ("phone", "phone", ContactLabel.phone(.phone)), ("phone", "mobile", .phone(.mobile)),
        ("phone", "home", .phone(.home)), ("phone", "work", .phone(.work)),
        ("phone", "school", .phone(.school)), ("phone", "other", .phone(.other)),
        ("email", "email", .email(.email)), ("email", "personal", .email(.personal)),
        ("email", "home", .email(.home)), ("email", "work", .email(.work)),
        ("url", "url", .url(.url)), ("url", "homepage", .url(.homepage)),
        ("url", "school", .url(.school)), ("url", "other", .url(.other)),
    ])
    func builtIn(kind: String, name: String, expected: ContactLabel) throws {
        let item = try decode(legacy(kind: kind, label: #"{"\#(name)":{}}"#))
        #expect(item.label == expected)
    }

    @Test("A label of another kind becomes a custom label")
    func mismatchedKind() throws {
        let item = try decode(legacy(kind: "phone", label: #"{"homepage":{}}"#))
        #expect(item.label == .phone(.custom("homepage")))
    }

    @Test("A custom label named as a built-in one stays custom")
    func customNamedAsBuiltIn() throws {
        let item = try decode(legacy(kind: "phone", label: #"{"custom":{"_0":"home"}}"#))
        #expect(item.label == .phone(.custom("home")))
    }

    // MARK: - Migration
    @Test("Re-encodes as v1")
    func migratesToV1() throws {
        let item = try decode(legacy(kind: "phone", label: #"{"custom":{"_0":"Papa"}}"#, value: "0600000000"))
        let reloaded = try #require(ContactItem(rawValue: item.rawValue))
        #expect(reloaded == item)
        let object = try #require(JSONSerialization.jsonObject(with: Data(item.rawValue.utf8)) as? [String: Any])
        #expect(object["version"] as? Int == 1)
        #expect(object["label"] as? String == "Papa")
    }

    // MARK: - Errors
    @Test("Unknown kind is rejected")
    func unknownKind() {
        #expect(throws: ContactItemError.unknownKind) {
            try decode(legacy(kind: "fax", label: #"{"phone":{}}"#))
        }
    }

    @Test("Malformed legacy labels are rejected", arguments: [
        #"{}"#,                                   // no case
        #"{"home":{},"work":{}}"#,                // two cases
        #"{"custom":{}}"#,                        // custom without text
        #""home""#,                               // not an object
    ])
    func malformed(_ label: String) {
        #expect(throws: DecodingError.self) {
            try decode(legacy(kind: "phone", label: label))
        }
    }
}
