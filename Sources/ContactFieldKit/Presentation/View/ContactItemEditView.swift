//
//  ContactItemEditView.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 16/2/26.
//

import SwiftUI
import NoFlyZone

public struct ContactItemEditView: View {
    
    // MARK: - States & Bindings
    @State private var kind: ContactLabel.Kind
    @State private var editedLabelIndex: Int!
    @State private var editedLabel: ContactLabel!
    // Layout
    @State private var labelMaxWidth: CGFloat = 0
    @State private var isRemovingRow = false
    @State private var highlightAddRow = false
    @State private var showLabelPicker = false
    @State private var computeLabelWidthsNeeded = 0 // change value when width mays have changed
    // Data
    @Binding private var values: [ContactItemUI]
    // NoFlyZone
    @Binding private var noFlyZoneCompletionStatus: NoFlyZoneCompletionStatus
    @Binding private var noFlyZoneEnabled: Bool
    @Binding private var noFlyAuthorizedZones: [NoFlyZoneData]
    
    // MARK: - properties
    private var viewIdentifier: Int
    private let roundedButtonsSize: CGFloat = 20
    private let rowHeight: CGFloat = 45
    private let swipeDeleteButtonW: CGFloat = 65
    private let rowLabelLeadPaddingW: CGFloat = 10
    private let rowDeleteButtonW: CGFloat = 50
    private let rowChevronW: CGFloat = 20
    private let rowSeparatorW: CGFloat = 0.5
    
    // MARK: - init
    public init(viewIdentifier: Int,
                kind: ContactLabel.Kind,
                values: Binding<[ContactItemUI]>,
                noFlyZoneEnabled: Binding<Bool>,
                noFlyZoneCompletionStatus: Binding<NoFlyZoneCompletionStatus>,
                noFlyAuthorizedZones: Binding<[NoFlyZoneData]>
    ) {
        self.viewIdentifier = viewIdentifier
        self.kind = kind
        self._values = values
        self._noFlyZoneEnabled = noFlyZoneEnabled
        self._noFlyZoneCompletionStatus = noFlyZoneCompletionStatus
        self._noFlyAuthorizedZones = noFlyAuthorizedZones
    }
    
    // MARK: - body
    public var body: some View {
        contentView
            .onChange(of: values.map { $0.toBeDeleted }, { oldValue, newValue in
                // Skip if we're in removal
                guard !isRemovingRow else { return }
                // If any item is marked as 'toBeDeleted', delete it
                guard let toBeRemovedIdx = values.firstIndex(where: { $0.toBeDeleted == true }) else { return }
                removeRow(toBeRemovedIdx)
            })
            .onChange(of: noFlyZoneEnabled) { oldValue, newValue in
                guard newValue == false else { return }
                guard oldValue != newValue else { return }
                // Reset the zones once NoFlyZone is hidden
                noFlyAuthorizedZones = []
            }
            .onChange(of: noFlyZoneCompletionStatus) { oldValue, newValue in
                guard oldValue != newValue else { return }
                switch newValue {
                    case .blocked:
                        // Reset row offsets if NoFlyZone was tapped on blocking zone
                        resetOffsets()
                    default:
                        ()
                }
            }
            .sheet(isPresented: $showLabelPicker,
                   onDismiss: onLabelPickerDismiss,
                   content: {
                LabelPickerView(kind: kind,
                                selectedContactLabel: $editedLabel)
            })
            .presentationDetents([.large])
    }
    
    // MARK: - subviews
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Divider()
                .overlay(Color(uiColor: UIColor.separator))
            
            ForEach(values.indices, id: \.self) { idx in
                contactItemRow(idx)
                    .frame(height: values[idx].height)
                    .opacity(values[idx].opacity)
                    .padding(0)
                    .if(values[idx].clip) { view in
                        view.clipped()
                    }
                Divider()
                    .overlay(Color(uiColor: UIColor.separator))
                    .padding(.leading, 45)
                    .opacity(values[idx].separatorOpacity)
            }
            addView
                .frame(height: rowHeight)
            Divider()
                .overlay(Color(uiColor: UIColor.separator))
        }
        .background(ContactFieldUIConfig.backgroundPrimary)
    }

    private var addView: some View {
        ZStack(alignment: .leading) {
            Color.gray.opacity(0.5)
                .opacity(highlightAddRow ? 1 : 0)
            HStack {
                addButtonView
                    .padding(.leading)
                Text(String(localized: getAddViewContent(), bundle: .module).capitalized)
                    .foregroundStyle(ContactFieldUIConfig.textPrimaryColor)
                    .font(ContactFieldUIConfig.captionTextFont)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            addItem()
            // highlight when tapped
            highlightAddRow = true
            Task {
                // quickly unhighlight
                try await Task.sleep(for: .seconds(0.05))
                withAnimation(.easeOut) {
                    highlightAddRow = false
                }
            }
        }
    }
    
    private func removeButtonView(_ idx: Int) -> some View {
        Button {
            showRemoveButton(idx)
        } label: {
            ZStack {
                Circle()
                    .frame(width: roundedButtonsSize, height: roundedButtonsSize)
                    .foregroundStyle(.red)
                Image(systemName: "minus")
                    .foregroundStyle(ContactFieldUIConfig.backgroundPrimary)
                    .font(.caption)
            }
        }
    }
    
    private var addButtonView: some View {
        Button {
            addItem()
        } label: {
            ZStack {
                Circle()
                    .frame(width: roundedButtonsSize, height: roundedButtonsSize)
                    .foregroundStyle(ContactFieldUIConfig.success)
                Image(systemName: "plus")
                    .foregroundStyle(ContactFieldUIConfig.backgroundPrimary)
                    .font(.caption)
            }
        }
    }
    
    private func contactItemRow(_ idx: Int) -> some View {
        ZStack(alignment: .trailing) {
            
            // Delete button hidden below row
            GeometryReader { geo in
                HStack {
                    Spacer()
                    Button {
                        // No action here, the remove action will be triggered if the according zone is tapped over the NoFlyZone
                    } label: {
                        ZStack {
                            Rectangle()
                                .frame(width: swipeDeleteButtonW, height: rowHeight)
                                .foregroundStyle(ContactFieldUIConfig.destructive)
                            Image(systemName: "trash")
                                .foregroundStyle(ContactFieldUIConfig.backgroundPrimary)
                        }
                    }
                    .onChange(of: geo.frame(in: .global)) { oldFrame, newFrame in
                        updateDeleteButtonFrame(geo: geo, idx: idx)
                    }
                    .task(id: values.count, {
                        updateDeleteButtonFrame(geo: geo, idx: idx)
                    })
                    .opacity(values[idx].offset == 0 ? 0 : 1)
                }
            }
            
            // Row: delete button - label - value
            GeometryReader { geo in
                HStack(spacing: 0) {
                    removeButtonView(idx)
                        .padding(.leading, 15)
                    
                    labelContentView(idx, rowWidth: geo.size.width)
                    TextField(getKindL10nInputPlaceholder(),
                              text: getItemBindingValue(idx))
                        .lineLimit(1)
                        .frame(alignment: .leading)
                        .padding(.leading, 10)
                        .foregroundStyle(Color.accentColor)
                        .font(ContactFieldUIConfig.bodyTextFont)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(ContactFieldUIConfig.backgroundPrimary)
                }
                .offset(x: values[idx].offset, y: 0)
            }
        }
    }
    
    private func labelContentView(_ idx: Int, rowWidth: CGFloat) -> some View {
        ZStack {
            // Hidden stack : computes max label width
            ZStack(alignment: .trailing) {
                ForEach(values.indices, id: \.self) { idx2 in
                    Text(getLabelContent(idx2))
                        .lineLimit(1)
                        .foregroundStyle(Color.accentColor)
                        .font(ContactFieldUIConfig.captionTextFont)
                        .padding(.leading, 10)
                        .background(.clear)
                }
            }
            .background {
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            labelMaxWidth = geo.size.width
                        }
                        .task(id: computeLabelWidthsNeeded) {
                            labelMaxWidth = geo.size.width
                        }
                }
            }
            .hidden()
            
            HStack(alignment: .center, spacing: 0) {
                Text(getLabelContent(idx))
                    .lineLimit(1)
                    .foregroundStyle(Color.accentColor)
                    .font(ContactFieldUIConfig.captionTextFont)
                    .padding(.leading, rowLabelLeadPaddingW)
                    .background(.clear)
                    .frame(alignment: .trailing)
                    .frame(width: getLabelContentWidths(rowWidth: rowWidth).label,
                           alignment: .trailing)
                ZStack {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: rowChevronW)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(ContactFieldUIConfig.textSecondaryColor)
                        .font(.caption)
                        .background(.clear)
                }
                Rectangle()
                    .frame(width: rowSeparatorW)
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [ContactFieldUIConfig.backgroundPrimary,
                                                                   Color(uiColor: UIColor.separator)]),
                                       startPoint: .top, endPoint: .bottom))
                    .background(.clear)
            }
            .frame(width: getLabelContentWidths(rowWidth: rowWidth).content)
            .onTapGesture {
                pickLabel(idx)
            }
        }
    }
    
    // MARK: - private methods
    private func getLabelContentWidths(rowWidth: CGFloat) -> (content: CGFloat, label: CGFloat) {
        // A row is made of :
        // <delete button> - <label content> - <value>
        // Compute the <label content> width :
        //   use the maximum label width + other <label content>'s elements width
        //   ensure <value> has enough space remaining > max = 50% * ( <row width> - <delete button.width> )
        
        let labelContentMaxWidth = (rowWidth - rowDeleteButtonW) * 0.5
        let labelContentProposedWidth = rowLabelLeadPaddingW + labelMaxWidth + rowChevronW + rowSeparatorW
        guard labelContentProposedWidth < labelContentMaxWidth else {
            return (labelContentMaxWidth,
                    labelMaxWidth - labelContentProposedWidth + labelContentMaxWidth)
        }
        return (labelContentProposedWidth, labelMaxWidth)
    }
    
    // TODO: try to draw new row with full height, under previous row, and make it appear from top
    // as in contact , would make it easier (no separator delay, ...)
    private func addItem() {
        values.append(ContactItemUI(kind: kind,
                                        height: 0,
                                        opacity: 0,
                                        clip: true,
                                        separatorOpacity: 0))
        
        var addItemAnimationDuration = 0.3
        
        withAnimation(.easeOut(duration: addItemAnimationDuration)) {
            values[values.count - 1].height = ContactItemUI.rowHeight
            values[values.count - 1].opacity = 1
        } completion: {
            values[values.count - 1].clip = false
        }
        withAnimation(.easeInOut(duration: addItemAnimationDuration * 2 / 5).delay(addItemAnimationDuration * 4 / 5)) {
            values[values.count - 1].separatorOpacity = 1
        }
    }
    
    private func getItemBindingValue(_ idx: Int) -> Binding<String> {
        return $values[idx].contactItem.value
    }
    
    private func getLabelContent(_ idx: Int) -> String {
        values[idx].contactItem.label.value.l10n
    }
    
    private func getAddViewContent() -> String.LocalizationValue {
        switch kind {
            case .phone:
                "label.add_phone"
            case .url:
                "label.add_url"
            case .email:
                "label.add_email"
        }
    }
    
    private func removeRow(_ idx: Int) {
        isRemovingRow = true
        values[idx].clip = true
        withAnimation(.easeInOut(duration: 0.2)) {
            values[idx].separatorOpacity = 0
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
            values[idx].offset = -500
            values[idx].height = 0
            values[idx].opacity = 0
        } completion: {
            removeItem(idx)
            isRemovingRow = false
        }
    }
    
    private func removeItem(_ idx: Int) {
        values.remove(at: idx)
    }
    
    private func showRemoveButton(_ idx: Int) {
        withAnimation {
            values[idx].offset = -1 * swipeDeleteButtonW
        }
        // Enable NoFlyZone with current row delete button frame
        noFlyZoneCompletionStatus = .undefined
        noFlyAuthorizedZones = [NoFlyZoneData(viewId: viewIdentifier,
                                              itemId: idx,
                                              zone: values[idx].deleteFrame)]
        noFlyZoneEnabled = true
    }
    
    private func resetOffsets() {
        guard values.contains(where: {$0.offset != 0}) else {
            print("WARNING: no zero offsets found ?? weird thing")
            for idx in 0..<values.count {
                print(" reset anyway \(idx) : \(values[idx].contactItem.label.value.key) \(values[idx].contactItem.value)")
                // Do not reset offset for a row to be deleted
                if values[idx].toBeDeleted {
                    print("  SKIP Reset offset at line \(idx) ")
                    continue
                }
                print("  Reset offset at line \(idx) ")
                values[idx].offset = 0
            }
            return
        }
        withAnimation {
            for idx in 0..<values.count {
                // Do not reset offset for a row to be deleted
                if values[idx].toBeDeleted {
                    continue
                }
                values[idx].offset = 0
            }
        }
    }
    
    private func updateDeleteButtonFrame(geo: GeometryProxy, idx: Int) {
        // Store delete buttons frame, update each time the array size change
        let rowFrame = geo.frame(in: .global)
        let posX = rowFrame.origin.x + rowFrame.size.width - swipeDeleteButtonW
        let buttonFrame = CGRect(x: posX,
                                 y: rowFrame.origin.y,
                                 width: rowFrame.size.width - posX,
                                 height: rowHeight)
        values[idx].deleteFrame = buttonFrame
    }
    
    private func getKindL10nInputPlaceholder() -> String {
        var key: String
        switch kind {
            case .phone:
                key = "label.phone"
            case .url:
                key = "label.url"
            case .email:
                key = "label.email"
        }
        return String(localized: String.LocalizationValue(key), bundle: .module)
    }
    
    private func pickLabel(_ idx: Int) {
        editedLabelIndex = idx
        editedLabel = values[idx].contactItem.label
        showLabelPicker = true
    }
    
    private func onLabelPickerDismiss() {
        guard values[editedLabelIndex].contactItem.label != editedLabel else {
            return
        }
        values[editedLabelIndex].contactItem.label = editedLabel
        computeLabelWidthsNeeded += 1
    }
}

 
#if DEBUG

struct MockContactItemEditView: View {
    
    @State private var phones: [ContactItemUI]
    @State private var emails: [ContactItemUI]
    @State private var urls: [ContactItemUI]
    
    @State private var noFlyZoneEnabled: Bool = false
    @State private var noFlyAuthorizedZones: [NoFlyZoneData] = []
    @State private var noFlyZoneCompletionStatus: NoFlyZoneCompletionStatus = .undefined
    
    var body: some View {
        ZStack {
            Color(ContactFieldUIConfig.backgroundSecondary)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                
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
                Spacer()
            }
        }
        .noFlyZone(enabled: noFlyZoneEnabled,
                   authorizedZones: noFlyAuthorizedZones,
                   onAllowed: noFlyZoneOnAllowed,
                   onBlocked: noFlyZoneOnBlocked,
                   coloredDebugOverlay: false)
    }
    
    init() {
        self.phones = [ContactItem(value: "+12125557483",
                                   label: ContactLabel(kind: .phone, label: .home)),
                       ContactItem(value: "+16465552917",
                                   label: ContactLabel(kind: .phone, label: .mobile)),
                       ContactItem(value: "+13125556042",
                                   label: ContactLabel(kind: .phone, label: .custom("work"))),
                       ContactItem(value: "+14155558831",
                                   label: ContactLabel(kind: .phone, label: .custom("club")))/*,
                       ContactItem(value: "+14155558831",
                                   label: ContactLabel(kind: .phone, label: .custom("Champignon")))*/
        ]
            .map { ContactItemUI(contactItem: $0) }
        self.emails = [ContactItem(value: "john.doe@home.com",
                                   label: ContactLabel(kind: .email, label: .email))
        ]
            .map { ContactItemUI(contactItem: $0) }
        self.urls = [ContactItem(value: "john.doe.home.com",
                                 label: ContactLabel(kind: .url, label: .url))
        ]
            .map { ContactItemUI(contactItem: $0) }
    }
    
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
}

#Preview {
    MockContactItemEditView()
}

#endif
