//
//  PaywallTabSplit.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import Foundation

/// Sorts one placement's plans onto tabs by a host rule, or decides that the
/// placement sells for one tab only. Generic over the item so the rule can
/// be tested on ids alone.
public enum PaywallTabSplit {

    /// The items by tab, each tab's in the placement's order, when they fall
    /// on two or more tabs. Nil when they all fall on one tab (the paywall
    /// then has no tabs) or any item is placed nowhere (`tab` returned nil):
    /// a plan whose kind is unknown must not end up on the wrong tab.
    public static func split<Item>(_ items: [Item], tab: (Item) -> String?) -> [String: [Item]]? {
        var byTab: [String: [Item]] = [:]
        for item in items {
            guard let id = tab(item) else { return nil }
            byTab[id, default: []].append(item)
        }
        return byTab.count >= 2 ? byTab : nil
    }

    /// The one tab an unsplit placement sells for: the tab every item is
    /// placed on when each is placed and they agree, else `fallback` (no
    /// items, an item placed nowhere, or items on several tabs, which
    /// `split` would have taken). A placement of one kind of plan alone must
    /// not pass for the fallback kind: its plans would be sold under the
    /// wrong copy.
    public static func soleTab<Item>(_ items: [Item], tab: (Item) -> String?, fallback: String) -> String {
        let ids = items.map(tab)
        guard let first = ids.first, let id = first, ids.allSatisfy({ $0 == id }) else { return fallback }
        return id
    }
}
