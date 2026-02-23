//
//  HomeView.swift
//  ContactFieldKitExample
//
//  Created by baptiste sansierra on 18/2/26.
//

import SwiftUI

struct HomeView: View {

    @Binding private var users: [User]
    
    init(users: Binding<[User]>) {
        self._users = users
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(users, id: \.id) { user in
                    NavigationLink(value: user) {
                        Text(user.name)
                    }
                }
            }
            .navigationTitle("Contacts")
            .navigationDestination(for: User.self) { user in
                ContactView(user: $users[getUserIndex(user)])
            }
        }
    }
    
    private func getUserIndex(_ user: User) -> Int {
        guard let idx = users.firstIndex(where: { $0.id == user.id }) else {
            fatalError("User \(user.id) not found")
        }
        return idx
    }
}
