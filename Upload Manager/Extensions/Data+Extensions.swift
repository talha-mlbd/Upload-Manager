//
//  Data+Extensions.swift
//  Upload Manager
//
//  Created by Bd Stock Air-M on 7/6/22.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
