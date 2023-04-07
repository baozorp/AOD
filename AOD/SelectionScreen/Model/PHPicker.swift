//
//  PHPicker.swift
//  AOD
//
//  Created by Михаил Шекунов on 07.04.2023.
//

import UIKit
import PhotosUI
import UniformTypeIdentifiers

protocol SelectionViewControllerDelegate{
    func imagesWasLoaded(_ imagesArray: [UIImage])
}

class PHPicker{
    
    let delegate: SelectionViewControllerDelegate
    
    init(_ selectionViewControllerDelegate: SelectionViewController){
        delegate = selectionViewControllerDelegate
    }
    
    func getImage(_ results: [PHPickerResult], _ AODCollectionViewHeight: CGFloat){
        let queue = DispatchQueue(label: "PHPickerQueue", attributes: .concurrent)
        let dispatchGroup = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 5)
        
        var newImages = [UIImage]()
        for result in results {
            dispatchGroup.enter()
            semaphore.wait()
            queue.async {
                if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.heic.identifier){
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.heic.identifier) {url, error in
                        defer {
                            dispatchGroup.leave()
                        }
                        guard let url = url else {
                            print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        do {
                            let data = try Data(contentsOf: url)
                            guard let image = UIImage(data: data) else {
                                print("Error creating image from data")
                                return
                            }
                            newImages.append(self.resizeImage(image: image, AODCollectionViewHeight))
                        } catch {
                            print("Error loading image: \(error.localizedDescription)")
                        }
                        
                    }
                }
                else if result.itemProvider.canLoadObject(ofClass: UIImage.self){
                    result.itemProvider.loadObject(ofClass: UIImage.self) {image, error in
                        defer {
                            dispatchGroup.leave()
                        }
                        guard let image = image as? UIImage else {
                            print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        newImages.append(self.resizeImage(image: image, AODCollectionViewHeight))
                    }
                } else {
                    print("Unsupported item provider")
                }
                semaphore.signal()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.delegate.imagesWasLoaded(newImages)
        }
    }
    
    private func resizeImage(image: UIImage, _ AODCollectionViewHeight: CGFloat) -> UIImage{
        
        // Crop a square in the middle of the image along the shortest side
        let imageSize = image.size
        let longerSide = min(imageSize.width, imageSize.height)
        let coefficient = AODCollectionViewHeight / longerSide
        let reduseSize = CGSize(width: imageSize.width * coefficient, height: imageSize.height * coefficient)
        
        UIGraphicsBeginImageContextWithOptions(reduseSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: reduseSize.width, height: reduseSize.height))
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage(systemName: "nosign")!
        }
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
