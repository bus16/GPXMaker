//
//  EditViewController.swift
//  GPXMaker
//
//  Created by Nikolay Kulikov on 02.06.17.
//  Copyright © 2017 Николай Куликов. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var lat: UITextField!
    @IBOutlet weak var lon: UITextField!
    @IBOutlet weak var color: UISegmentedControl!
    
    @IBOutlet weak var esec: UITextField!
    @IBOutlet weak var nsec: UITextField!
    @IBOutlet weak var emin: UITextField!
    @IBOutlet weak var nmin: UITextField!
    

    
    @IBAction func tappedSegmentController(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            sender.tintColor = UIColor(red: 0, green: 0.557, blue: 0.165, alpha: 1);
        }
        else if sender.selectedSegmentIndex == 1 {
            sender.tintColor = UIColor.red
        }
    }
    
    var viewModel: EditViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.name.text = self.viewModel?.getItem("name")
        
        if self.viewModel?.isEdited == true {
            if let latitude = self.viewModel?.getItem("lat") {
                var point = self.viewModel?.getPointDict(point: latitude)
                
                self.lat.text = point?["deg"]
                self.nmin.text = point?["min"]
                self.nsec.text = point?["sec"]
            }
            
            if let longitude = self.viewModel?.getItem("lon") {
                var point = self.viewModel?.getPointDict(point: longitude)
            
                self.lon.text = point?["deg"]
                self.emin.text = point?["min"]
                self.esec.text = point?["sec"]
            }
        }
        
        let colorStr = self.viewModel?.getItem("color")
        if colorStr == "Flag, Green" {
            self.color.tintColor = UIColor(red: 0, green: 0.557, blue: 0.165, alpha: 1);
            self.color.selectedSegmentIndex = 0
        }
        else if colorStr == "Flag, Red" {
            self.color.tintColor = UIColor.red
            self.color.selectedSegmentIndex = 1
        }
        
        self.lat.delegate = self
        self.lon.delegate = self
        self.esec.delegate = self
        self.nsec.delegate = self
        self.emin.delegate = self
        self.nmin.delegate = self
        
        self.name.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.esec || textField == self.nsec {
            let dotsCount = textField.text!.components(separatedBy: ".").count - 1
            if dotsCount > 0 && (string == "." || string == ",") {
                return false
            }
        
            if string == "," {
                textField.text! += "."
                return false
            }
        }
        else {
            if string == "," || string == "." {
                return false
            }
            
            if string != "" && textField.text!.count > 1 {
                return false
            }
        }
        
        return true
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "save" {

            self.viewModel?.insert("name", name.text ?? "")
            
            let latDeg = self.lat.text?.doubleValue ?? 0
            let latMin = self.nmin.text?.doubleValue ?? 0
            let latSec = self.nsec.text?.doubleValue ?? 0
            self.viewModel?.insert("lat", String(format:"%f", latDeg + latMin/60 + latSec/3600))
            
            let lonDeg = self.lon.text?.doubleValue ?? 0
            let lonMin = self.emin.text?.doubleValue ?? 0
            let lonSec = self.esec.text?.doubleValue ?? 0
            self.viewModel?.insert("lon", String(format:"%f", lonDeg + lonMin/60 + lonSec/3600))

                
            if self.color.selectedSegmentIndex == 0 {
                self.viewModel?.insert("color", "Flag, Green")
            } else {
                self.viewModel?.insert("color", "Flag, Red")
            }
            
            if self.viewModel?.isEdited == true {
                do {
                    try self.viewModel?.removeItem()
                } catch {
                    self.showMessage(with: error.localizedDescription)
                }
            }
            do {
                try self.viewModel?.addItem()
            } catch {
                self.showMessage(with: error.localizedDescription)
            }
        }
    }
}
