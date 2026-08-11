//
//  PaywallAlertsModifier.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI

/// The paywall's alerts: failed restore, purchase pending approval, and failed purchase.
struct PaywallAlertsModifier: ViewModifier {

    @Binding var showRestoreFailedAlert: Bool
    @Binding var showPendingApprovalAlert: Bool
    @Binding var purchaseError: String?

    func body(content: Content) -> some View {
        content
            .alert(
                Text("Couldn't restore", bundle: .module),
                isPresented: $showRestoreFailedAlert,
                actions: { Button(action: {}) { Text("OK", bundle: .module) } },
                message: { Text("We couldn't find an active subscription on this account.", bundle: .module) }
            )
            .alert(
                Text("Waiting for approval", bundle: .module),
                isPresented: $showPendingApprovalAlert,
                actions: { Button(action: {}) { Text("OK", bundle: .module) } },
                message: { Text("Your purchase needs to be approved. The app will unlock automatically once that happens.", bundle: .module) }
            )
            .alert(
                Text("Purchase failed", bundle: .module),
                isPresented: purchaseFailedPresented,
                actions: { Button(action: {}) { Text("OK", bundle: .module) } },
                message: { Text(purchaseError ?? "") }
            )
    }

    private var purchaseFailedPresented: Binding<Bool> {
        Binding(
            get: { purchaseError != nil },
            set: { if !$0 { purchaseError = nil } }
        )
    }
}

extension View {
    func paywallAlerts(
        showRestoreFailedAlert: Binding<Bool>,
        showPendingApprovalAlert: Binding<Bool>,
        purchaseError: Binding<String?>
    ) -> some View {
        modifier(PaywallAlertsModifier(
            showRestoreFailedAlert: showRestoreFailedAlert,
            showPendingApprovalAlert: showPendingApprovalAlert,
            purchaseError: purchaseError
        ))
    }
}
