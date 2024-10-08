//
//  MailComposer.swift
//  GitBoost
//
//  Created by 강치우 on 9/23/24.
//

import SwiftUI
import MessageUI

struct MailComposer: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var result: Result<MFMailComposeResult, Error>?

    var recipientEmail: String
    var subject: LocalizedStringKey
    var body: LocalizedStringKey

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailComposer

        init(_ parent: MailComposer) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
            parent.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients([recipientEmail])
        vc.setSubject(translateLocalizedStringKey(subject))
        vc.setMessageBody(translateLocalizedStringKey(body), isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    private func translateLocalizedStringKey(_ key: LocalizedStringKey) -> String {
        let mirror = Mirror(reflecting: key)
        let children = mirror.children
        if let firstChild = children.first, let keyString = firstChild.value as? String {
            return NSLocalizedString(keyString, comment: "")
        } else {
            return ""
        }
    }
}
