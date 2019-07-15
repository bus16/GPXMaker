//
//  TableViewController.swift
//  GPXMaker
//
//  Created by Nikolay Kulikov on 28.05.17.
//  Copyright © 2017 Николай Куликов. All rights reserved.
//

import UIKit

class MyCustomTableViewCell: UITableViewCell {
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var lonLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
}

class ContentTableViewController: UITableViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var viewModel: ContentListViewModel?
    
    @IBAction func shareDoc(_ sender: Any) {
        guard let url = self.viewModel?.getPath() else { return }
        
        UIDocumentInteractionController(url: url).presentOptionsMenu(from: sender as! UIBarButtonItem, animated: true)
    }
    
    @IBAction func saveToMainViewController(segue: UIStoryboardSegue) {
        self.tableView.reloadData()
    }
    
    @IBAction func editTapped(_ sender: UIBarButtonItem) {
        if self.isEditing == true {
            self.editButton.title = "Edit"
            self.isEditing = false
        }
        else {
            self.editButton.title = "Done"
            self.isEditing = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.viewModel?.getCount() ?? 0 > 0 {
            self.editButton.isEnabled = true
        }
        
        self.navigationItem.prompt = self.viewModel?.getPath().lastPathComponent
        self.tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.getCount() ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyCustomTableViewCell

        let points = self.viewModel?.getItem(indexPath.row)
        
        guard let lat = points?["lat"], let lon = points?["lon"], let name = points?["name"] else { return article }
        guard let latStr = self.viewModel?.getPointStr(point: lat), let lonStr = self.viewModel?.getPointStr(point: lon) else { return article }
        
        article.latLabel.text? = "N " + latStr
        article.lonLabel.text? = "E " + lonStr
        article.nameLabel.text? = name
    
        if points?["color"] == "Flag, Green" {
            article.pinImage.image = #imageLiteral(resourceName: "GreenPin")
        } else if points?["color"] == "Flag, Red" {
            article.pinImage.image = #imageLiteral(resourceName: "RedPin")
        }
        
        return article
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try self.viewModel?.removeItem(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                self.showMessage(with: error.localizedDescription)
            }
            
            if self.viewModel?.getCount() == 0 && self.editButton.isEnabled == true {
                self.editButton.isEnabled = false
                self.editButton.title = "Edit"
            }
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        guard let dict = self.viewModel?.getItem(fromIndexPath.row) else { return }
        
        do {
            try self.viewModel?.removeItem(at: fromIndexPath.row)
            do {
                try self.viewModel?.addItem(dict, at: to.row)
            } catch {
                self.showMessage(with: error.localizedDescription)
            }
        } catch {
            self.showMessage(with: error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let editViewController = segue.destination as! EditViewController
        
        if segue.identifier == "edit" {
            if let path = tableView.indexPathForSelectedRow {
                editViewController.viewModel = self.viewModel?.createEditViewModel(path.row, edited: true)
            }
        }
        else if segue.identifier == "create" {
            editViewController.viewModel = self.viewModel?.createEditViewModel(self.viewModel?.getCount() ?? 0, edited: false)
        }
    }
}

extension ContentTableViewController: ContentListOutput {
    func showError(_ text: String) {
        self.showMessage(with: text)
    }
}
