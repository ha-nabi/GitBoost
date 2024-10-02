//
//  UIApplication+.swift
//  GitBoost
//
//  Created by 강치우 on 10/1/24.
//

import SwiftUI

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
