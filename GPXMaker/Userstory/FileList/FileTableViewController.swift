//
//  FileTableViewController.swift
//  GPXMaker
//
//  Created by Nikolay Kulikov on 03.06.17.
//  Copyright © 2017 Николай Куликов. All rights reserved.
//

import UIKit

class FileTableViewController: UITableViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    let viewModel = FileListViewModel()
    
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
        
        self.viewModel.view = self
        self.viewModel.configure()
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.dataCount()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        guard self.viewModel.dataCount() >= indexPath.row else {
            self.showMessage(with: "Incorrect index!")
            return cell
        }
        
        cell.textLabel?.text = self.viewModel.getItem(indexPath.row).lastPathComponent

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard self.viewModel.dataCount() >= indexPath.row else {
            self.showMessage(with: "Incorrect index!")
            return
        }
        
        if editingStyle == .delete {
            self.viewModel.deleteItem(indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
 
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let contentTableViewController = segue.destination as? ContentTableViewController else {
            fatalError("Unexpected VC")
        }
        
        if segue.identifier == "modify" {
            guard let tablePath = tableView.indexPathForSelectedRow else { return }
            
            contentTableViewController.viewModel = ContentListViewModel(self.viewModel.getItem(tablePath.row))
        } else if segue.identifier == "new" {
            if let name = sender as? String {
                do {
                    contentTableViewController.viewModel = ContentListViewModel(try self.viewModel.createItem(name))

                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .top)
                    self.tableView.endUpdates()
                } catch {
                    self.showMessage(with: error.localizedDescription)
                }
            }
            else {
                self.showMessage(with: "Enter new file name", placeholder: "name", seque: "new")
            }
        }
    }
}

extension FileTableViewController: FileListOutput {
    func showError(_ text: String) {
        self.showMessage(with: text)
    }
    
    func configureEditButton(_ enable: Bool) {
        self.editButton.isEnabled = enable
        
        if self.viewModel.isEmpty() {
            self.editButton.title = "Edit"
        }
    }
}
