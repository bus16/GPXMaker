//
//  FileHelper.swift
//  GPXMaker
//
//  Created by Nikolay Kulikov on 03.06.17.
//  Copyright © 2017 Николай Куликов. All rights reserved.
//

import Foundation

enum FileHelperError: Error {
    case directory
    case path
    case write
    case duplicate
    
    var localizedDescription: String {
        switch self {
        case .directory: return "Couldn't get documents directory"
        case .path:      return "Couldn't get documents directory path"
        case .write:     return "Couldn't write to file"
        case .duplicate: return "Duplicate file names"
        }
    }
}

class FileHelper {
    
    var documentsDirectory: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    var documentsPath: NSString? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as NSString?
    }
    
    func checkDirectory() throws -> [URL] {
        guard let directory = self.documentsDirectory else { throw FileHelperError.directory }
        
        return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.contentModificationDateKey], options: [.skipsHiddenFiles])
                .filter{ $0.pathExtension == "gpx" }
                .map{ ($0, (try $0.resourceValues(forKeys: [.contentModificationDateKey])).contentModificationDate ?? Date.distantPast) }
                .sorted(by: { $0.1 > $1.1 })
                .map{ $0.0 }
    }
    
    func writeToFile(fileName: String, value: String) throws -> URL {
        guard let path = self.documentsPath else { throw FileHelperError.path }
        
        let fullPath = path.appendingPathComponent(fileName)
        try value.write(toFile: fullPath, atomically: true, encoding: String.Encoding.utf8)
        
        return URL(fileURLWithPath: fullPath)
    }
    
    func deleteFile(fileName: URL) throws {
        try FileManager.default.removeItem(at: fileName)
    }
}
