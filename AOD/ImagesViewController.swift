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
    var isDeleting = false
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        getImagesFromCoreData()
    }
    
    deinit{
        print("was deinited")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dismiss(animated: false)
    }
    
    // MARK: - Private Functions
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .darkGray
        navigationController?.navigationBar.barTintColor = .darkGray
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: "Отмена", style: .done, target: self, action: #selector(cancelButtonTapped))
        let okButton: UIBarButtonItem = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(okButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = okButton
        navigationItem.leftBarButtonItem?.isHidden = true
        navigationItem.rightBarButtonItem?.isHidden = true
        
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .darkGray
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.allowsMultipleSelection = true
    }
    
    private func getImagesFromCoreData() {
        let fetchRequestAll = Image.fetchRequest()
        fetchRequestAll.predicate = NSPredicate(format: "picture != nil")
        do{
            guard try context.fetch(fetchRequestAll).count > 0 else {return}
        }catch let error as NSError{
            print(error.localizedDescription)
        }
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
        cell.image = AODImage
        cell.isDeleting = self.isDeleting
        if let picture = AODImage.picture{
            cell.pictureView.image = UIImage(data: picture)
        }
        cell.pictureView.layer.cornerRadius = 20

        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isDeleting{
            choseElementToDisplay(indexPath: indexPath)
        }
        else{
            choseElementToDelete(indexPath: indexPath)
        }

    }
    
    private func choseElementToDelete(indexPath: IndexPath){
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCell else {return}
        cell.isSelected = true
    }
    
    
    private func choseElementToDisplay(indexPath: IndexPath){
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCell else{return}
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
            delegate.deleteImage(image)
        }
        saveContext()
        cell.checkStatus.isHidden = !cell.checkStatus.isHidden
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: collectionView)
            if collectionView.indexPathForItem(at: point) != nil {
                navigationItem.leftBarButtonItem?.isHidden = false
                navigationItem.rightBarButtonItem?.isHidden = false
                isDeleting = true
                collectionView.reloadData()
            }
        }
    }
    
    @objc func cancelButtonTapped() {
        guard let selectedItemsIndexes = collectionView.indexPathsForSelectedItems else {return}
        let animation = UIViewPropertyAnimator(duration: 0.1, curve: .linear)
        for i in selectedItemsIndexes{
            guard let cell = collectionView.cellForItem(at: i) as? ImageCell else{return}
            cell.deleteStatus.alpha = 1.0
            animation.addAnimations {
                cell.deleteStatus.alpha = 0.0
            }

        }
        animation.addCompletion({_ in
            self.isDeleting = false
            self.collectionView.reloadData()
        })
        animation.startAnimation()
        navigationItem.leftBarButtonItem?.isHidden = true
        navigationItem.rightBarButtonItem?.isHidden = true
    }
    
    @objc func okButtonTapped(){
        guard let selectedItemsIndexes = collectionView.indexPathsForSelectedItems else {return}
        collectionView.performBatchUpdates({
            for i in selectedItemsIndexes.reversed(){
                guard let cell = collectionView.cellForItem(at: i) as? ImageCell else{return}
                guard let image = cell.image else {return}
                allImages.remove(at: allImages.firstIndex(of: image)!)
                if let chosenIndex = chosenImages.firstIndex(of: image){
                    chosenImages.remove(at: chosenIndex)
                }
                delegate.deleteImage(image)
                context.delete(image)}
            collectionView.deleteItems(at: selectedItemsIndexes)
        }, completion: { _ in
            for i in 0..<self.allImages.count{
                self.allImages[i].indexPathRow = Int16(i)
            }
            self.isDeleting = false
            self.collectionView.reloadData()
            self.saveContext()
        })
        navigationItem.leftBarButtonItem?.isHidden = true
        navigationItem.rightBarButtonItem?.isHidden = true

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
