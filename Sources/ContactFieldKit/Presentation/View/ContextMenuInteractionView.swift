//
//  ContextMenuInteractionView.swift
//  ContactFieldKit
//
//  Created by baptiste sansierra on 19/2/26.
//

import SwiftUI

struct ContextMenuInteractionView<Content: View>: UIViewRepresentable {

    @ViewBuilder var view: Content
    let actions: [UIAction]
    let willEnd: (() -> Void)?
    let willDisplay: (() -> Void)?
    let isHighlighted: Bool

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> some UIView {

#if true
        let v = UIHostingController(rootView: view).view!

        context.coordinator.contextMenu = UIContextMenuInteraction(delegate: context.coordinator)
        v.addInteraction(context.coordinator.contextMenu!)
#else
        
        let hostingController = UIHostingController(rootView: view)
        let v = hostingController.view!
        v.backgroundColor = .clear

        context.coordinator.hostingController = hostingController
        context.coordinator.contextMenu = UIContextMenuInteraction(delegate: context.coordinator)
        v.addInteraction(context.coordinator.contextMenu!)
#endif

        return v
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Update highlight
        UIView.animate(withDuration: 0.2) {
            uiView.backgroundColor = isHighlighted ? UIColor.gray.withAlphaComponent(0.5) : .clear
        }
        
        // Update content
        //context.coordinator.hostingController?.rootView = view
    }
    
    class Coordinator: NSObject,  UIContextMenuInteractionDelegate{
        
        var contextMenu: UIContextMenuInteraction!
        //var hostingController: UIHostingController<Content>?
        let parent: ContextMenuInteractionView
        
        init(parent: ContextMenuInteractionView) {
            self.parent = parent
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                    configurationForMenuAtLocation location: CGPoint)
        -> UIContextMenuConfiguration? {
            UIContextMenuConfiguration(identifier: nil,
                                       previewProvider: nil,
                                       actionProvider: { [self]
                suggestedActions in
                return UIMenu(title: "", children: parent.actions)
            })
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                    willDisplayMenuFor configuration: UIContextMenuConfiguration,
                                    animator: UIContextMenuInteractionAnimating?) {
            parent.willDisplay?()
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                    willEndFor configuration: UIContextMenuConfiguration,
                                    animator: UIContextMenuInteractionAnimating?) {
            parent.willEnd?()
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                    previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration)
        -> UITargetedPreview? {
            guard let view = interaction.view else { return nil }
            
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            // Keep the full view visible, just remove shadow
            parameters.shadowPath = UIBezierPath()  // No shadow
            
            let target = UIPreviewTarget(container: view.superview!, center: view.center)
            return UITargetedPreview(view: view, parameters: parameters, target: target)
        }

        func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                    previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration)
        -> UITargetedPreview? {
            guard let view = interaction.view else { return nil }
            
            let parameters = UIPreviewParameters()
            parameters.backgroundColor = .clear
            parameters.shadowPath = UIBezierPath()
            
            let target = UIPreviewTarget(container: view.superview!, center: view.center)
            return UITargetedPreview(view: view, parameters: parameters, target: target)
        }
    }
}
