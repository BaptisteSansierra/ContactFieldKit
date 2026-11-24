//
//  ServicesTests.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 24/11/26.
//

import Foundation
import Testing
@testable import ContactFieldKit

// Uses UserDefaults.standard: serialized and cleaned before/after each test
@Suite("CustomLabelStorage", .serialized)
struct CustomLabelStorageTests {

    private static let kinds: [ContactItemKind] = [.phone, .email, .url]

    init() { Self.clean() }

    private static func clean() {
        for kind in kinds {
            UserDefaults.standard.removeObject(forKey: "ContactFieldKit.custom.\(kind.rawValue)")
        }
    }

    @Test("Empty by default")
    func empty() {
        for kind in Self.kinds {
            #expect(CustomLabelStorage.labels(kind: kind).isEmpty)
        }
        Self.clean()
    }

    @Test("Stores in insertion order, without duplicates")
    func storeDedup() {
        CustomLabelStorage.store(kind: .phone, value: "club")
        CustomLabelStorage.store(kind: .phone, value: "work")
        CustomLabelStorage.store(kind: .phone, value: "club")
        #expect(CustomLabelStorage.labels(kind: .phone) == ["club", "work"])
        Self.clean()
    }

    @Test("Each kind has its own list")
    func perKind() {
        CustomLabelStorage.store(kind: .phone, value: "club")
        CustomLabelStorage.store(kind: .url, value: "blog")
        #expect(CustomLabelStorage.labels(kind: .phone) == ["club"])
        #expect(CustomLabelStorage.labels(kind: .email).isEmpty)
        #expect(CustomLabelStorage.labels(kind: .url) == ["blog"])
        Self.clean()
    }
}

@Suite("URLOpener alerts")
struct URLOpenerAlertTests {

    @Test("Every error has a localized title and body",
          arguments: [URLOpenerError.invalidURL, .cannotOpenPhoneURL, .cannotOpenEmailURL, .cannotOpenWebURL])
    func alertContent(_ error: URLOpenerError) {
        let alert = URLOpener.alertContent(error)
        #expect(!alert.title.isEmpty)
        #expect(!alert.body.isEmpty)
        // An unresolved key comes back as the key itself
        #expect(!alert.title.hasPrefix("error."))
        #expect(!alert.body.hasPrefix("error."))
    }
}

@Suite("Extensions")
struct ExtensionsTests {

    @Test("removeEmptyFields drops blank values only")
    func removeEmptyFields() {
        var items = [ContactItem.phone("1"),
                     ContactItem.phone(""),
                     ContactItem.phone("   "),
                     ContactItem.phone(" 2 ")]
        items.removeEmptyFields()
        #expect(items.map(\.value) == ["1", " 2 "])
    }

    @Test("capitalizeFirst", arguments: [("home", "Home"), ("Home", "Home"), ("", ""), ("éte", "Éte"), ("work phone", "Work phone")])
    func capitalizeFirst(_ input: String, expected: String) {
        #expect(input.capitalizeFirst == expected)
    }
}
