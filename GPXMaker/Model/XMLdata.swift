
//
//  XMLdata.swift
//  GPXMaker
//
//  Created by Nikolay Kulikov on 04.06.17.
//  Copyright © 2017 Николай Куликов. All rights reserved.
//

import Foundation

class XMLData: NSObject {
    
    private var parser: XMLParser!
    private var content = [[String : String]]()
    private var elements = [String : String]()
    private var element: NSString = ""
    private var lat: String = ""
    private var lon: String = ""
    private var color: String = ""
    private var name: String = ""
    private var file: URL!
    
    init(_ url: URL) {
        super.init()
        
        self.file = url
        
        self.parser = XMLParser(contentsOf: file)
        if self.parser == nil {
            fatalError("Couldn't init XMLParser")
        }
        self.parser.delegate = self
        self.parser.parse()
    }

//    private override init() {}

    func addItem(item: [String:String], at index: Int) throws {
        content.insert(item, at: index)
        try saveData(input: content)
    }

    func getItem(index: Int) -> [String : String] {
        guard content.isEmpty == false, content.count > index else { return [:] }
        
        return content[index]
    }
    
    func getCount() -> Int {
        return content.count
    }
    
    func removeItem(at index: Int) throws {
        content.remove(at: index)
        try saveData(input: content)
    }
    
    func saveData(input: [[String : String]]) throws {
        var convertStr = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>\n<gpx>\n"
    
        input.forEach { dict in
            guard let lat = dict["lat"],
                let lon = dict["lon"],
                let name = dict["name"],
                let color = dict["color"] else { return }
            
            convertStr += "\t<wpt lat=\"\(lat)\" lon=\"\(lon)\">\n\t\t<name>\(name)</name>\n\t\t<sym>\(color)</sym>\n\t</wpt>\n"
        }
        convertStr += "</gpx>"
        
        try convertStr.write(to: file, atomically: false, encoding: .utf8)
    }
    
    func getPointDict(point: String) -> [String : String] {
        var pointDict = [String : String]()
        
        var deg = Double(point) ?? 0
        deg -= deg.truncatingRemainder(dividingBy: 1)
        var min = ((Double(point) ?? 0) * 60 - deg * 60)
        min -= min.truncatingRemainder(dividingBy: 1)
        let sec = (Double(point) ?? 0) * 3600 - (deg * 3600 + min * 60)
    
        pointDict["deg"] = String(format:"%.0f", deg)
        pointDict["min"] = String(format:"%.0f", min)
        pointDict["sec"] = String(format:"%.5f", sec)
        
        return pointDict
    }
    
    func getPointStr(point: String) -> String {
        var pointStr: String
        
        var deg = Double(point) ?? 0
        deg -= deg.truncatingRemainder(dividingBy: 1)
        var min = ((Double(point) ?? 0) * 60 - deg * 60)
        min -= min.truncatingRemainder(dividingBy: 1)
        let sec = (Double(point) ?? 0) * 3600 - (deg * 3600 + min * 60)
        
        pointStr = String(format:"%.0f", deg)
        pointStr.append("°")
        pointStr.append(String(format:"%.0f", min))
        pointStr.append("'")
        pointStr.append(String(format:"%.5f", sec))
        
        return pointStr
    }
}

extension XMLData: XMLParserDelegate {
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String]) {
        
        element = elementName as NSString
        if element.isEqual(to: "wpt") {
            elements.removeAll()
            color = ""
            name = ""
            lat = attributeDict["lat"] ?? ""
            lon = attributeDict["lon"] ?? ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if element.isEqual(to: "sym") {
            color.append(string.trimmingCharacters(in: .whitespacesAndNewlines))
        } else if element.isEqual(to: "name") {
            name.append(string.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName as NSString).isEqual(to: "wpt") {

            elements["lat"] = lat
            elements["lon"] = lon
            elements["color"] = color
            elements["name"] = name
            
            content.append(elements)
        }
    }
}
//    <?xml version="1.0" encoding="utf-8" standalone="no"?>
//    <wpt lat="11" lon="12">
//    <name>10</name>
//    <sym>Flag, Green</sym>
//    </wpt>
//    func getXMLData() -> String?
//    {
//        let data = try? Data(contentsOf: file)
//        do {
//            let xmlDoc = try AEXMLDocument(xml: data!, options: AEXMLOptions())
//            return xmlDoc.xml
//        }
//        catch {
//            print("\(error)")
//            return nil
//        }
//    }
