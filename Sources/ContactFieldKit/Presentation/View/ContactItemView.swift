//
//  ContactItemView.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 18/2/26.
//

import SwiftUI

public struct ContactItemView: View {
    
    // MARK: - States & Bindings
    @State private var highlightedRow: Int? = nil
    @State private var openURLAlert: OpenURLAlert? = nil
    
    @GestureState private var isPressingRow = false
    // Data
    @Binding private var contactItems: [ContactItem]
    
    // MARK: - init
    public init(contactItems: Binding<[ContactItem]>) {
        self._contactItems = contactItems
    }
    
    // MARK: - body
    public var body: some View {
        listView
            .frame(maxWidth: .infinity)
            .background(ContactFieldUIConfig.backgroundPrimary)
            .cornerRadius(15)
            .padding(.horizontal)
            .opacity(contactItems.count > 0 ? 1 : 0)
            .alert(openURLAlert?.title ?? "",
                   isPresented: Binding(get: {
                openURLAlert != nil
            }, set: { v in
                openURLAlert = v ? openURLAlert : nil
            }), actions: {
            }) {
                Text(openURLAlert?.body ?? "")
            }
    }
    
    // MARK: - Subviews
    private var listView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(contactItems.indices, id: \.self) { idx in
                contactItemRowView(idx)
                    .frame(height: 70)
            }
        }
    }

    @ViewBuilder
    private func contactItemRowView(_ idx: Int) -> some View {
        ZStack {
            Rectangle()
                .fill(highlightedRow == idx ? .gray.opacity(0.5) : .clear)
                .animation(.easeInOut, value: highlightedRow)

            contactItemRowContentView(idx)
                .contentShape(Rectangle())  // Makes entire area tappable
                .simultaneousGesture(
                    TapGesture()
                        .onEnded({ _ in
                            highlightedRow = idx
                            Task {
                                // Unhighlight after some time
                                try await Task.sleep(for: .seconds(0.5))
                                highlightedRow = nil
                            }
                            openURL(idx)
                        })
                )
                .contextMenu(contactItem: contactItems[idx],
                             actions: [
                                UIAction(title: String(localized: String.LocalizationValue("common.copy"),
                                                       bundle: .module),
                                         image: UIImage(systemName: "doc.on.doc"),
                                         handler: { _ in
                                             UIPasteboard.general.string = contactItems[idx].value
                                         })
                             ],
                             isHighlighted: highlightedRow == idx,
                             willEnd: { highlightedRow = nil },
                             willDisplay: { highlightedRow = idx }
                )
            
            /*
                .contextMenu(menuItems: {
                    Button {
                        UIPasteboard.general.string = contactItems[idx].value
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                }/*, preview: {
                    contactItemRowContentView(idx)
                }*/)
             */

        }
        .clipped()
    }
    
    private func contactItemRowContentView(_ idx: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(contactItems[idx].label.value.l10n)
                .font(ContactFieldUIConfig.captionTextFont)
                .foregroundStyle(ContactFieldUIConfig.textPrimaryColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 15)
                .padding(.bottom, 5)
                .padding(.leading)
            Text(contactItems[idx].value)
                .font(ContactFieldUIConfig.bodyTextFont)
                .foregroundStyle(.blue)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            Spacer()
            if idx != contactItems.count - 1 {
                Divider()
                    .overlay(Color(uiColor: UIColor.separator))
                    .padding(.leading)
            }
        }
    }

    // MARK: - private methods
    private func openURL(_ idx: Int) {
        do {
            try URLOpener.openURL(contactItem: contactItems[idx])
        } catch {
            guard let error = error as? URLOpenerError else {
                return
            }
            openURLAlert = URLOpener.alertContent(error)
        }
    }
}

#if DEBUG

struct MockContactItemView: View {
   
    @State private var phones: [ContactItem]
    @State private var emails: [ContactItem]
    @State private var urls: [ContactItem]

   var body: some View {
       ZStack {
           Color(ContactFieldUIConfig.backgroundSecondary)
               .ignoresSafeArea()
           VStack(alignment: .leading, spacing: 0) {
               
               ContactItemView(contactItems: $phones)
                   .padding(.bottom)

               ContactItemView(contactItems: $emails)
                   .padding(.bottom)

               ContactItemView(contactItems: $urls)
                   .padding(.bottom)

               Spacer()
           }
       }
   }
   
   init() {
       self.phones = [ContactItem(value: "+12125557483",
                                  label: ContactLabel(kind: .phone, label: .phone))/*,
                      ContactItem(value: "+16465552917",
                                  label: ContactLabel(kind: .phone, label: .mobile)),
                      ContactItem(value: "+13125556042",
                                  label: ContactLabel(kind: .phone, label: .custom("work"))),
                      ContactItem(value: "+14155558831",
                                  label: ContactLabel(kind: .phone, label: .custom("club")))*/]
       self.emails = [ContactItem(value: "john.doe@home.com", label: ContactLabel(kind: .email, label: .email))]
       self.urls = [ContactItem(value: "google.com",
                                label: ContactLabel(kind: .url, label: .url))]
   }
}

#Preview {
    MockContactItemView()
}

#endif
