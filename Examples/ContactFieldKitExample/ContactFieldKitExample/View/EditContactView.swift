//
//  EditContactView.swift
//  ContactFieldKitExample
//
//  Created by baptiste sansierra on 17/2/26.
//

import SwiftUI
import ContactFieldKit
import NoFlyZone

struct EditContactView: View {

    // MARK: - States & Bindings
    @Binding private var user: User
    // We use UI models for presentation
    @State private var phones: [ContactItemUI] = []
    @State private var emails: [ContactItemUI] = []
    @State private var urls: [ContactItemUI] = []
    // NoFlyZone states
    @State private var noFlyZoneEnabled: Bool = false
    @State private var noFlyAuthorizedZones: [NoFlyZoneData] = []
    @State private var noFlyZoneCompletionStatus: NoFlyZoneCompletionStatus = .undefined
    
    // MARK: - init
    init(user: Binding<User>) {
        self._user = user
        
        // Create UI models from Domain models
        let phones = self.user.phones.map { ContactItemUI(contactItem: $0) }
        self._phones = State(initialValue: phones)
        
        let emails = self.user.emails.map { ContactItemUI(contactItem: $0) }
        self._emails = State(initialValue: emails)

        let urls = self.user.urls.map { ContactItemUI(contactItem: $0) }
        self._urls = State(initialValue: urls)
    }
    
    // MARK: - body
    var body: some View {
        ZStack {
            Color(ContactFieldUIConfig.backgroundSecondary)
                .ignoresSafeArea()
            
            ScrollView {
                ZStack {
                    Circle()
                        .fill(Color(uiColor: UIColor.tertiaryLabel))
                        .frame(width: 150, height: 150)
                    Text(user.initials())
                        .foregroundStyle(Color(uiColor: UIColor.systemBackground))
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
                .padding(.top, 20)
                .padding(.bottom, 20)

                ContactItemEditView(viewIdentifier: 1,
                                kind: .phone,
                                values: $phones,
                                noFlyZoneEnabled: $noFlyZoneEnabled,
                                noFlyZoneCompletionStatus: $noFlyZoneCompletionStatus,
                                noFlyAuthorizedZones: $noFlyAuthorizedZones)
                .padding(.bottom, 20)
                .padding(.top, 40)
                
                ContactItemEditView(viewIdentifier: 2,
                                kind: .email,
                                values: $emails,
                                noFlyZoneEnabled: $noFlyZoneEnabled,
                                noFlyZoneCompletionStatus: $noFlyZoneCompletionStatus,
                                noFlyAuthorizedZones: $noFlyAuthorizedZones)
                .padding(.bottom, 20)
                
                ContactItemEditView(viewIdentifier: 3,
                                kind: .url,
                                values: $urls,
                                noFlyZoneEnabled: $noFlyZoneEnabled,
                                noFlyZoneCompletionStatus: $noFlyZoneCompletionStatus,
                                noFlyAuthorizedZones: $noFlyAuthorizedZones)
                .padding(.bottom, 20)
            }
        }
        .noFlyZone(enabled: noFlyZoneEnabled,
                   authorizedZones: noFlyAuthorizedZones,
                   onAllowed: noFlyZoneOnAllowed,
                   onBlocked: noFlyZoneOnBlocked,
                   coloredDebugOverlay: true)
        .onChange(of: phones) { oldValue, newValue in
            applyUpdate()
        }
        .onChange(of: emails) { oldValue, newValue in
            applyUpdate()
        }
        .onChange(of: urls) { oldValue, newValue in
            applyUpdate()
        }
    }
    
    // MARK: - private methods
    private func noFlyZoneOnBlocked() {
        noFlyZoneEnabled = false
        noFlyZoneCompletionStatus = .blocked
    }
    
    private func noFlyZoneOnAllowed(tappedZones: [NoFlyZoneData]) {
        noFlyZoneEnabled = false
        noFlyZoneCompletionStatus = .allowed
        
        for z in tappedZones {
            if z.viewId == 1 {
                phones[z.itemId].toBeDeleted = true
            }
            else if z.viewId == 2 {
                emails[z.itemId].toBeDeleted = true
            }
            else if z.viewId == 3 {
                urls[z.itemId].toBeDeleted = true
            }
        }
    }
    
    private func applyUpdate() {
        // Apply UI models modifications to binded user
        let phoneItems = phones.map { $0.contactItem }
        let emailItems = emails.map { $0.contactItem }
        let urlItems = urls.map { $0.contactItem }
        user.phones = phoneItems
        user.emails = emailItems
        user.urls = urlItems
    }
}

#Preview {
    @Previewable @State var user: User = User(name: "John Doe",
                                 phones: [
                                    ContactItem(value: "123",
                                                label: ContactLabel(kind: .phone))
                                 ],
                                 emails: [],
                                 urls: [])

    EditContactView(user: $user)
}
