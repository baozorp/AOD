//
//  ImagesViewController.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

protocol ImagesViewControllerDelegate {
    func saveImage(_ image: Image)
    func deleteImage(_ image: Image)
}

class ImagesViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    var chosenImages: [Image] = []
    var allImages: [Image] = []
    var delegate: ImagesViewControllerDelegate!
    var context: NSManagedObjectContext!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        getImagesFromCoreData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dismiss(animated: false)
    }
    
    // MARK: - Private Functions
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .darkGray
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .darkGray
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")
    }
    
    private func getImagesFromCoreData() {
        let fetchRequestAll = Image.fetchRequest()
        fetchRequestAll.predicate = NSPredicate(format: "picture != nil")
        do {
            let requestAll = try context.fetch(fetchRequestAll)
            allImages = [Image](repeating: requestAll[0], count: requestAll.count)
            for i in 0 ..< requestAll.count {
                allImages[Int(requestAll[i].indexPathRow)] = requestAll[i]
            }
        }catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        cell.backgroundColor = .darkGray
        cell.contentMode = .scaleAspectFit
        let AODImage = allImages[indexPath.row]
        
        cell.checkStatus.isHidden = chosenImages.contains(AODImage) ? false : true
        
        cell.image = AODImage
        cell.pictureView.image = UIImage(data: AODImage.picture!)
        cell.pictureView.layer.cornerRadius = 20
        cell.checkStatus.image?.withTintColor(.darkGray)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
        guard let image = cell.image else {return}
        
        if cell.checkStatus.isHidden {
            chosenImages.append(image)
            collectionView.moveItem(at: indexPath, to: [indexPath.startIndex, chosenImages.count - 1])
            allImages.remove(at: indexPath.row)
            allImages.insert(image, at: chosenImages.count - 1)
            image.wasChosen = true
            image.indexPathRow = Int16(chosenImages.count - 1)
            for i in (chosenImages.count - 1) ..< allImages.count{
                allImages[i].indexPathRow = Int16(i)
            }
            saveContext()
            delegate.saveImage(image)
        }
        else{
            chosenImages.remove(at: indexPath.row)
            collectionView.moveItem(at: indexPath, to: [indexPath.startIndex, chosenImages.count])
            allImages.remove(at: indexPath.row)
            allImages.insert(image, at: chosenImages.count)
            image.wasChosen = false
            image.indexPathRow = Int16(chosenImages.count)
            for i in indexPath.row..<allImages.count{
                allImages[i].indexPathRow = Int16(i)
            }
            saveContext()
            delegate.deleteImage(image)
        }
        cell.checkStatus.isHidden = !cell.checkStatus.isHidden
    }
    
    // Mark: - CoreData saver
    
    private func saveContext(){
        do{
            try context.save()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ImagesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 4, height: collectionView.frame.width / 4)
    }
}
