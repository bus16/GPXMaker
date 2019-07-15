//
//  ContentListViewModel.swift
//  GPXMaker
//
//  Created by Nikolay Kulikov on 15/07/2019.
//  Copyright © 2019 Nikolay Kulikov. All rights reserved.
//

import Foundation

protocol ContentListInput {
    func getCount() -> Int
    func getPath() -> URL
    func getItem(_ index: Int) -> [String : String]
    func getPointStr(point: String) -> String
    func removeItem(at index: Int) throws
    func addItem(_ item: [String : String], at index: Int) throws
    func createEditViewModel(_ index: Int, edited: Bool) -> EditViewModel
}

protocol ContentListOutput: class {
    func showError(_ text: String)
}

class ContentListViewModel: ContentListInput {
    var file: URL!
    private var points = [String : String]()
    private var model: XMLData?
    weak var view: ContentListOutput?
    
    init(_ file: URL) {
        self.file = file
        self.model = XMLData(file)
    }
    
    func createEditViewModel(_ index: Int, edited: Bool) -> EditViewModel {
        let points = self.model?.getItem(index: index) ?? [:]
        return EditViewModel(EditModel(points, index: index, edited: edited), dataModel: self.model)
    }
    
    func getPath() -> URL {
        return file
    }
    
    func getCount() -> Int {
        return self.model?.getCount() ?? 0
    }
    
    func getItem(_ index: Int) -> [String : String] {
        return self.model?.getItem(index: index) ?? [:]
    }
    
    func getPointStr(point: String) -> String {
        return self.model?.getPointStr(point: point) ?? ""
    }
    
    func removeItem(at index: Int) throws {
        try self.model?.removeItem(at: index)
    }
    
    func addItem(_ item: [String : String], at index: Int) throws {
        try self.model?.addItem(item: item, at: index)
    }
}
