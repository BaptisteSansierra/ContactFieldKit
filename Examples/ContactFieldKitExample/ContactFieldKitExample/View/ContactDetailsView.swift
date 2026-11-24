//
//  ContactDetailsView.swift
//  ContactFieldKitExample
//
//  Created by baptiste sansierra on 18/2/26.
//

import SwiftUI
import ContactFieldKit

struct ContactDetailsView: View {
    
    @Binding private var user: User
    
    init(user: Binding<User>) {
        self._user = user
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: UIColor.secondarySystemBackground)
                .ignoresSafeArea()
            ScrollView {
                ZStack {
                    Circle()
                        .fill(Color(uiColor: UIColor.tertiaryLabel))
                        .frame(width: 80, height: 80)
                    Text(user.initials())
                        .foregroundStyle(Color(uiColor: UIColor.systemBackground))
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
                .padding(.top, 0)
                .padding(.bottom, 20)
                
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(uiColor: UIColor.systemBackground))
                        .frame(height: 45)
                        .padding(.horizontal)
                    Text(user.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 30)
                }
                .padding(.bottom, 20)

                ContactItemView(contactItems: $user.phones)
                    .padding(.bottom, 20)

                ContactItemView(contactItems: $user.emails)
                    .padding(.bottom, 20)

                ContactItemView(contactItems: $user.urls)
            }
        }
    }

}

#Preview {
    
    @Previewable @State var pipo: ContactLabel = ContactLabel.phone(.mobile)
    @Previewable @State var user: User = User(name: "John Doe",
                                 phones: [
                                    ContactItem.phone("123"),
                                    ContactItem.phone("456", label: .mobile)
                                 ],
                                 emails: [
                                    ContactItem.email("123", label: .email)
                                 ],
                                 urls: [
                                    ContactItem.url("123", label: .url)
                                 ])

    ContactDetailsView(user: $user)
}
