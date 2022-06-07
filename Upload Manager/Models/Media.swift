//
//  Media.swift
//  Upload Manager
//
//  Created by Bd Stock Air-M on 7/6/22.
//

import Foundation
import UIKit

protocol MediaProtocol {
    var key: String { get set }
    var fileName: String { get set }
    var data: Data { get set }
    var mimeType: String {get set }
}

struct Media: Decodable & MediaProtocol {
    var key: String
    var fileName: String
    var data: Data
    var mimeType: String

    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.fileName = "\(arc4random()).jpeg"

        guard let data = image.jpegData(compressionQuality: 0.5) else { return nil }
        self.data = data
    }
}
