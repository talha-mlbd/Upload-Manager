//
//  ViewController.swift
//  Upload Manager
//
//  Created by Bd Stock Air-M on 11/4/22.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    var images = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBlue
        pickPhoto()
    }
    
    func pickPhoto() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 10
        config.filter = PHPickerFilter.any(of: [.images])

        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }
    
    func uploadSingleImage(_ image: UIImage) {
        UploadManager.shared.uploadFile(fileURL: nil, targetURL: URL(string: "https://api.imgur.com/3/image")!, image: image) { progress in
            print("Progress: ", progress)
        } completionHandler: { result in
            print("Upload completed in handler")
            print(result)
        }
    }
    
    func uploadImages() {
        for i in 1...13 {
            let image = UIImage(named: "mlbd_image_\(i)")!
            UploadManager.shared.uploadFile(fileURL: nil, targetURL: URL(string: "https://api.imgur.com/3/image")!, image: image) { progress in
                print("Here is the progress: ", progress)
            } completionHandler: { result in
                print("Upload completed in handler")
                print(result)
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        let dispatchGroup = DispatchGroup()
        results.forEach { result in
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (readingObject, error) in
                defer {
                    dispatchGroup.leave()
                }
                if let error = error {
                    print("Unable to load Object", error.localizedDescription)
                    return
                }
                guard let image = readingObject as? UIImage else { return }
                self?.images.append(image)
                print(image)
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Image cont: \(self.images.count)")
            self.images.forEach { image in
                self.uploadSingleImage(image)
            }
        }
    }
}
