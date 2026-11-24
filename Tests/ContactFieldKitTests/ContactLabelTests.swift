//
//  ContactLabelTests.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 24/11/26.
//

import Foundation
import Testing
@testable import ContactFieldKit

@Suite("ContactLabel")
struct ContactLabelTests {

    // MARK: - Creation
    @Test("Static creators set the kind and the default label")
    func defaultLabels() {
        #expect(ContactItem.phone("1").label == .phone(.phone))
        #expect(ContactItem.email("a@b.c").label == .email(.email))
        #expect(ContactItem.url("a.com").label == .url(.url))
        #expect(ContactItem.phone("1").kind == .phone)
        #expect(ContactItem.email("a@b.c").kind == .email)
        #expect(ContactItem.url("a.com").kind == .url)
    }

    @Test("init(kind:) creates an empty item with the default label",
          arguments: [(ContactItemKind.phone, ContactLabel.defaultPhone),
                      (.email, .defaultEmail),
                      (.url, .defaultUrl)])
    func initKind(_ kind: ContactItemKind, label: ContactLabel) {
        let item = ContactItem(kind: kind)
        #expect(item.kind == kind)
        #expect(item.label == label)
        #expect(item.value == "")
    }

    @Test("Each item gets its own id")
    func uniqueIds() {
        #expect(ContactItem.phone("1").id != ContactItem.phone("1").id)
    }

    @Test("Shared shortcuts are the shared cases")
    func sharedShortcuts() {
        #expect(PhoneLabel.home == .shared(.home))
        #expect(EmailLabel.work == .shared(.work))
        #expect(URLLabel.school == .shared(.school))
        #expect(PhoneLabel.other == .shared(.other))
        #expect(EmailLabel.custom("olala") == .shared(.custom("olala")))
    }

    @Test("init(kind:custom:) wraps the text in the right kind")
    func initCustom() {
        #expect(ContactLabel(kind: .phone, custom: "club") == .phone(.custom("club")))
        #expect(ContactLabel(kind: .email, custom: "club") == .email(.custom("club")))
        #expect(ContactLabel(kind: .url, custom: "club") == .url(.custom("club")))
    }

    // MARK: - Picker lists
    @Test("allLabels lists the specific labels first, then the shared ones")
    func allLabels() {
        #expect(ContactLabel.allLabels(kind: .phone) == [.phone(.phone), .phone(.mobile),
                                                         .phone(.home), .phone(.work), .phone(.school), .phone(.other)])
        #expect(ContactLabel.allLabels(kind: .email) == [.email(.email), .email(.personal),
                                                         .email(.home), .email(.work), .email(.school), .email(.other)])
        #expect(ContactLabel.allLabels(kind: .url) == [.url(.url), .url(.homepage),
                                                       .url(.home), .url(.work), .url(.school), .url(.other)])
    }

    @Test("allLabels never contains a custom label nor another kind",
          arguments: [ContactItemKind.phone, .email, .url])
    func allLabelsKind(_ kind: ContactItemKind) {
        let labels = ContactLabel.allLabels(kind: kind)
        #expect(labels.allSatisfy { $0.kind == kind })
        #expect(labels.allSatisfy { label in
            if case .custom? = label.sharedLabel { return false }
            return true
        })
        #expect(ContactLabel.defaultPhone.allLabels() == ContactLabel.allLabels(kind: .phone))
    }

    // MARK: - Keys & l10n
    @Test("Keys", arguments: [
        (ContactLabel.phone(.phone), "phone"), (.phone(.mobile), "mobile"),
        (.email(.email), "email"), (.email(.personal), "personal"),
        (.url(.url), "url"), (.url(.homepage), "homepage"),
        (.phone(.home), "home"), (.email(.work), "work"), (.url(.school), "school"), (.phone(.other), "other"),
        (.url(.custom("olala")), "olala"),
    ])
    func keys(_ label: ContactLabel, key: String) {
        #expect(label.key == key)
        #expect(label.rawValue == key)
    }

    @Test("Every built-in label is localized", arguments: [ContactItemKind.phone, .email, .url])
    func builtInLocalized(_ kind: ContactItemKind) {
        for label in ContactLabel.allLabels(kind: kind) {
            // An unresolved key comes back as the key itself
            #expect(label.l10n != "label.\(label.key)", "\(label) is not localized")
            #expect(!label.l10n.isEmpty)
        }
    }

    @Test("Custom label l10n is its text")
    func customL10n() {
        #expect(ContactLabel.phone(.custom("Champignon")).l10n == "Champignon")
    }

    // MARK: - rawValue init
    @Test("rawValue init maps built-in names to their case")
    func rawValueInit() {
        #expect(ContactLabel(rawValue: "mobile", kind: .phone) == .phone(.mobile))
        #expect(ContactLabel(rawValue: "personal", kind: .email) == .email(.personal))
        #expect(ContactLabel(rawValue: "homepage", kind: .url) == .url(.homepage))
        #expect(ContactLabel(rawValue: "school", kind: .url) == .url(.school))
        // Specific name of another kind is a custom label
        #expect(ContactLabel(rawValue: "homepage", kind: .phone) == .phone(.custom("homepage")))
        // Case sensitive
        #expect(ContactLabel(rawValue: "Mobile", kind: .phone) == .phone(.custom("Mobile")))
    }
}

// MARK: - Helpers
private extension ContactLabel {
    var sharedLabel: SharedLabel? {
        switch self {
            case .phone(.shared(let shared)): shared
            case .email(.shared(let shared)): shared
            case .url(.shared(let shared)): shared
            default: nil
        }
    }
}
