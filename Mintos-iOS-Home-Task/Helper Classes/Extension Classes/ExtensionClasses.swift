//
//  ExtensionClasses.swift
//  Mintos-iOS-Home-Task
//
//  Created by Sachin on 21/08/2023.
//

import Foundation
import UIKit
// MARK: - String
extension String {
    var localized: String {
            return NSLocalizedString(self, comment: "")
        }
}
extension UIViewController {
    func showalertview(messagestring: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: messagestring, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
