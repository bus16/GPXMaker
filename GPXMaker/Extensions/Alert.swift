//
//  Alert.swift
//  GPXMaker
//
//  Created by Nikolay Kulikov on 12/07/2019.
//  Copyright © 2019 Nikolay Kulikov. All rights reserved.
//

import UIKit

extension UIViewController {
    func showMessage(with text: String) {
        let alert = UIAlertController(title: text, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            alert.dismiss(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showMessage(with text: String, placeholder: String, seque: String) {
        let alert = UIAlertController(title: "Enter new file name", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        let okAction = (UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.performSegue(withIdentifier: seque, sender: alert.textFields?.first?.text)
        }))
        okAction.isEnabled = false
        alert.addAction(okAction)
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = placeholder
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using: { _ in
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0
                    
                    okAction.isEnabled = textIsNotEmpty
            })
        })
        self.present(alert, animated: true)
    }
}
