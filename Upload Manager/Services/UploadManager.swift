//
//  UploadManager.swift
//  Upload Manager
//
//  Created by Bd Stock Air-M on 14/4/22.
//

import Foundation
import UIKit

class UploadManager: NSObject {
    
    typealias ProgressHandler = (Double) -> Void
    typealias CompletionHandler = (Result<Void, Error>) -> Void
    
    static let shared = UploadManager()
    
    var urlSession: URLSession!
    private var progressHandlersByTaskID = [Int : ProgressHandler]()
    
    override private init() {
        super.init()
        
        let config = URLSessionConfiguration.default
        
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        //        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    func uploadFile(fileURL: URL?, targetURL: URL, image: UIImage, progressHandler: @escaping ProgressHandler,
                    completionHandler: @escaping CompletionHandler) {
        print(#function)
        let boundary = generateBoundary()
        var request = URLRequest(url: targetURL, cachePolicy: .reloadIgnoringLocalCacheData)
        
        guard let mediaImage = Media(withImage: image, forKey: "file") else { return }
        
        request.httpMethod = "POST"
        
        request.allHTTPHeaderFields = [
            //            "X-User-Agent": "ios",
            //            "Accept-Language": "en",
            //            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
            "Authorization": "Client-ID 88e612876a120d2"
            //            "ApiKey": KeychainService.getString(by: KeychainKey.apiKey) ?? ""
        ]
        
        let dataBody = createDataBody(withParameters: nil, media: [mediaImage], boundary: boundary)
        request.httpBody = dataBody
        
        let task = urlSession.uploadTask(with: request, from: dataBody)
        progressHandlersByTaskID[task.taskIdentifier] = progressHandler
        task.resume()
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    func createDataBody<T: Decodable & MediaProtocol>(withParameters params: [String: String]?, media: [T]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
}

extension UploadManager: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("Upload file in progress delegate method")
        
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        print("Progress: ", progress)
        
        let handler = progressHandlersByTaskID[task.taskIdentifier]
        handler?(progress)
    }
    
    // Error received: Handler for server-side error
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Upload Failed ", error.localizedDescription)
        } else {
            print("Upload Failed NOT")
        }
    }
    
    // Response received: Provides a reference to the response object which can be used for example for checking the http status code.
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("didReceive response")
        
        print("Url: \(String(describing: response.url)) MimeType: \(String(describing: response.mimeType)) Suggested File Name: \(String(describing: response.suggestedFilename)) Expected Content Length: \(response.expectedContentLength)")
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    
    // Data received: Provides the data returned from the server.
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("didReceive data: ", data.base64EncodedString())
        print("Data Received")
        
        if let dataString = String(data: data, encoding: .utf8) {
            print("imgur upload results: \(dataString)")
            
            let parsedResult: [String: AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                if let dataJson = parsedResult["data"] as? [String: Any] {
                    print("Link is : \(dataJson["link"] as? String ?? "Link not found")")
                }
            } catch {
                // Display an error
                print("Can't parse data")
            }
        }
    }
}
