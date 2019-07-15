//
//  FileListViewModel.swift
//  GPXMaker
//
//  Created by Nikolay Kulikov on 15/07/2019.
//  Copyright © 2019 Nikolay Kulikov. All rights reserved.
//

import Foundation

protocol FileListOutput: class {
    func showError(_ text: String)
    func configureEditButton(_ enable: Bool)
}

protocol FileListInput {
    func configure()
    func isEmpty() -> Bool
    func dataCount() -> Int
    func getItem(_ index: Int) -> URL
    func deleteItem(_ index: Int)
    func createItem(_ name: String) throws -> URL
}

class FileListViewModel: FileListInput {
    
    let fileHelper = FileHelper()
    weak var view: FileListOutput?
    
    private var list = [URL]() {
        didSet {
            self.view?.configureEditButton(list.count > 0)
        }
    }
    
    func isEmpty() -> Bool {
        return self.list.isEmpty
    }
    
    func dataCount() -> Int {
        return self.list.count
    }
    
    func getItem(_ index: Int) -> URL {
        return self.list[index]
    }
    
    func deleteItem(_ index: Int) {
        
        do {
            try fileHelper.deleteFile(fileName: list[index])
            
            self.list.remove(at: index)
        } catch {
            self.view?.showError(error.localizedDescription)
        }
    }
    
    func createItem(_ name: String) throws -> URL {
        
        let useNames = self.list.map{ $0.lastPathComponent }
        guard !useNames.contains(name + ".gpx") else {
            throw FileHelperError.duplicate
        }

        let newfile = try fileHelper.writeToFile(fileName: name + ".gpx", value: "")
        
        self.list.insert(newfile, at: 0)
        return newfile
    }
    
    func configure() {
        do {
            self.list = try fileHelper.checkDirectory()
        } catch {
            self.view?.showError(error.localizedDescription)
        }
    }
}
