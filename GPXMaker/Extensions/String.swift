//
//  String.swift
//  GPXMaker
//
//  Created by Nikolay Kulikov on 12/07/2019.
//  Copyright © 2019 Nikolay Kulikov. All rights reserved.
//

import Foundation

extension String {
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
}
