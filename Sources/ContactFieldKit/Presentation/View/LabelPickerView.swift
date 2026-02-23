//
//  LabelPickerView.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 19/2/26.
//

import SwiftUI

// TODO: add an Edit mode so custom labels can be removed

struct LabelPickerView: View {
    
    @State private var customLabel: String = ""
    @State private var customLabels: [String] = []
    @Binding private var selectedContactLabel: ContactLabel?
    @Environment(\.dismiss) var dismiss
    
    private let kind: ContactLabel.Kind
    private var labels: [ContactLabel.Label]
    private let rowHeight: CGFloat = 50

    init(kind: ContactLabel.Kind, selectedContactLabel: Binding<ContactLabel? >) {
        self.kind = kind
        self._selectedContactLabel = selectedContactLabel
        labels = ContactLabel.allLabels(kind: kind)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ContactFieldUIConfig.backgroundSecondary
                    .ignoresSafeArea()
                ScrollView {
                    listView
                        .padding(.top)
                    customView
                }
            }
            .navigationTitle(String(localized: String.LocalizationValue("label_picker.title"),
                                    bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "multiply")
                    }

                }
            }
            .onAppear {
                updateCustomLabels()
            }
        }
    }
        
    @ViewBuilder
    private var listView: some View {
        VStack(spacing: 0) {
            Divider()
            ForEach(labels.indices, id: \.self) { idx in
                labelRow(index: idx)
            }
            Divider()
        }
        .background(ContactFieldUIConfig.backgroundPrimary)
    }

    private var customView: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 0) {
                TextField(String(localized: String.LocalizationValue("label_picker.add_custom"),
                                 bundle: .module),
                          text: $customLabel)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.leading)
                    .frame(height: rowHeight)
                    .onSubmit(onCustomLabelSubmit)
                if customLabels.indices.count > 0 {
                    Divider()
                        .padding(.leading)
                }

                ForEach(customLabels.indices, id: \.self) { idx in
                    customRow(index: idx)
                }
            }
            Divider()
        }
        .background(ContactFieldUIConfig.backgroundPrimary)
        .padding(.top, 30)
    }

    private func labelRow(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(labels[index].l10n)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.leading)
                .contentShape(Rectangle())
                .overlay {
                    if let selectedContactLabel = selectedContactLabel,
                       selectedContactLabel.value.key == labels[index].key {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .foregroundStyle(.blue)
                                .padding(.trailing)
                        }
                    }
                }
                //.border(.red)
            if index != labels.count - 1 {
                Divider()
            }
        }
        .frame(height: rowHeight)
        .onTapGesture {
            selectedContactLabel = ContactLabel(kind: kind,
                                                label: labels[index])
            dismiss()
        }
    }

    private func customRow(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(customLabels[index])
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .overlay {
                    if let selectedContactLabel = selectedContactLabel,
                       selectedContactLabel.value.key == customLabels[index] {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark")
                                .font(.headline)
                                .foregroundStyle(.blue)
                                .padding(.trailing)
                        }
                    }
                }
                //.border(.red)
            if index != customLabels.count - 1 {
                Divider()
            }
        }
        .padding(.leading)
        .frame(height: rowHeight)
        .onTapGesture {
            selectedContactLabel = ContactLabel(kind: kind,
                                                label: .custom(customLabels[index]))
            dismiss()
        }
    }

    private func updateCustomLabels() {
        customLabels = CustomLabelStorage.labels(kind: kind)
    }
    
    private func onCustomLabelSubmit() {
       guard !customLabel.isEmpty else {
           dismiss()
           return
       }
       // Store new custom label if do not exists
       CustomLabelStorage.store(kind: kind,
                                value: customLabel)
       updateCustomLabels()
       // Set label
       selectedContactLabel = ContactLabel(kind: kind,
                                           label: .custom(customLabel))
       dismiss()
    }
}

#if DEBUG

public struct MockLabelPickerView: View {
    
    @State var contactLabel: ContactLabel? = ContactLabel(kind: .phone, label: .mobile)

    public init() {}
    public var body: some View {
        LabelPickerView(kind: .phone, selectedContactLabel: $contactLabel)
    }
}

#Preview {
    MockLabelPickerView()
}

#endif
