//
//  EditViewModel.swift
//  GPXMaker
//
//  Created by Nikolay Kulikov on 15/07/2019.
//  Copyright © 2019 Nikolay Kulikov. All rights reserved.
//

import Foundation

struct EditModel {
    var point: [String:String]
    var index: Int
    var edited: Bool
    
    init(_ replaced: [String : String] = [:], index: Int, edited: Bool) {
        self.point = replaced
        self.index = index
        self.edited = edited
    }
}

protocol EditInput {
    func getItem(_ key: String) -> String
    func getPointDict(point: String) -> [String : String]
    func insert(_ key: String, _ value: String)
    func removeItem() throws
    func addItem() throws
}

class EditViewModel: EditInput {
    private var editModel: EditModel!
    var model: XMLData?

    var isEdited: Bool {
        return self.editModel.edited
    }
    
    init(_ editModel: EditModel, dataModel: XMLData?) {
        self.editModel = editModel
        self.model = dataModel
    }
    
    func getItem(_ key: String) -> String {
        return self.editModel?.point[key] ?? ""
    }
    
    func getPointDict(point: String) -> [String : String] {
        return self.model?.getPointDict(point: point) ?? [:]
    }
    
    func insert(_ key: String, _ value: String) {
        self.editModel.point[key] = value
    }
    
    func removeItem() throws {
        try self.model?.removeItem(at: self.editModel.index)
    }
    
    func addItem() throws {
        try self.model?.addItem(item: self.editModel.point, at: self.editModel.index)
    }
}
