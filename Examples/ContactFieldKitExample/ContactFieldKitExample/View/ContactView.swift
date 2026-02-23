//
//  ContactView.swift
//  ContactFieldKitExample
//
//  Created by baptiste sansierra on 18/2/26.
//

import SwiftUI
import ContactFieldKit

struct ContactView: View {
    
    // MARK: - States & Bindings
    @State private var editMode: Bool = false
    @State private var editEnabled: Bool = false
    @State private var editedUser: User
    @State private var confirmCancel: Bool = false
    @Binding private var user: User

    // MARK: - Init
    init(user: Binding<User>) {
        self._user = user
        self.editedUser = user.wrappedValue
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            ContactDetailsView(user: $user)
                .opacity(editMode ? 0 : 1)
                .animation(.easeInOut, value: editMode)
            EditContactView(user: $editedUser)
                .opacity(editMode ? 1 : 0)
                .animation(.easeInOut, value: editMode)
        }
        .navigationBarBackButtonHidden(editMode)
        .confirmationDialog("Are you sure you want to discard your changes ?",
                            isPresented: $confirmCancel,
                            titleVisibility: .visible,
                            actions: {
            Button("Discard Changes", role: .destructive) {
                editedUser = user
                editMode.toggle()
            }
            Button("Keep Editing") {
            }
        })
        .toolbar { toolbar }
        .onChange(of: editedUser) { oldValue, newValue in
            editEnabled = !editedUser.equal(user)
        }
    }
    
    // MARK: - Subviews
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if editMode {
            editToolbar
        } else {
            detailsToolbar
        }
    }

    private var detailsToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Edit") {
                editMode.toggle()
            }
        }
    }
    
    @ToolbarContentBuilder
    private var editToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel", action: cancelEdits)
                .tint(.blue)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button("Done", action: applyEdits)
                .disabled(!editEnabled)
                .tint(.blue)
        }
    }
    
    // MARK: - private methods
    private func applyEdits() {
        // Remove empty fields
        editedUser.phones.removeEmptyFields()
        editedUser.emails.removeEmptyFields()
        editedUser.urls.removeEmptyFields()
        // Apply edits
        user = editedUser
        editMode.toggle()
    }

    private func cancelEdits() {
        guard editEnabled else {
            editMode.toggle()
            return
        }
        // Ask confirmation if there's some edits
        confirmCancel = true
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
    NavigationStack {
        ContactView(user: $user)
    }
}
