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
    func didSavedContext()
}

class ImagesViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    var allImages: [Image] = []
    var imagesForRemove: [Image] = []
    var lastElement: Int!
    var isDeleting = false
    

    var delegate: ImagesViewControllerDelegate!
    var context: NSManagedObjectContext!

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureCollectionView()
        getImagesFromCoreData()
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
        
        if let picture = AODImage.picture{
            cell.pictureView.image = UIImage(data: picture)
        }
        
        cell.isDeleting = isDeleting
        cell.animateChecker(isWasSelected: false)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !isDeleting{
            choseElementToDisplay(indexPath: indexPath)
        }
        else{
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCell else { return }
            guard let image = cell.image else {return}
            imagesForRemove.append(image)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if !isDeleting{
            choseElementToDisplay(indexPath: indexPath)
        }
        else{
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCell else { return }
            guard let image = cell.image else {return}
            guard let index = imagesForRemove.firstIndex(of: image) else{return}
            imagesForRemove.remove(at: index)
        }
    }
}

// Mark: - CoreData

extension ImagesViewController{
    
    private func getImagesFromCoreData() {
        
        let fetchRequestChosen = Image.fetchRequest()
        fetchRequestChosen.predicate = NSPredicate(format: "wasChosen == %@", argumentArray: [true])
        
        let fetchRequestAll = Image.fetchRequest()
        fetchRequestAll.predicate = NSPredicate(format: "picture != nil")
        
        do {
            lastElement = try context.count(for: fetchRequestChosen) - 1
            let requestAll = try context.fetch(fetchRequestAll)
            
            if !requestAll.isEmpty{
                allImages = requestAll.sorted { $0.indexPathRow < $1.indexPathRow }
            }
        }catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func saveContext(){
        do{
            try context.save()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
}

// Mark - Actions

extension ImagesViewController{
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        guard !isDeleting else {return}
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: collectionView)
            if collectionView.indexPathForItem(at: point) != nil {
                guard let visibleCells = collectionView?.visibleCells else {return}
                
                isDeleting = true
                collectionView.reloadData()
                collectionView.performBatchUpdates({
                    
                    for i in visibleCells{
                        guard let cell = i as? ImageCell else{continue}
                        cell.animateChecker(isWasSelected: true)
                    }
                })

                reverseVisibleNavButtons()
            }
        }
    }
    
    @objc func cancelButtonTapped() {
        
        guard let selectedItemsIndexes = collectionView.indexPathsForSelectedItems else {return}
        
        self.isDeleting = false
        
        for i in imagesForRemove{
            imagesForRemove.remove(at: imagesForRemove.firstIndex(of: i)!)
        }
        self.collectionView.reloadData()
        collectionView.performBatchUpdates({
            for i in selectedItemsIndexes{
                guard let cell = collectionView.cellForItem(at: i) as? ImageCell else{continue}
                cell.animateDeleter(isWasSelected: false)
            }
        })
        
        reverseVisibleNavButtons()
    }
    
    @objc func okButtonTapped(){
        guard let selectedItemsIndexes = collectionView.indexPathsForSelectedItems else {return}
        collectionView.performBatchUpdates({
            for i in imagesForRemove{
                allImages.remove(at: allImages.firstIndex(of: i)!)
                imagesForRemove.remove(at: imagesForRemove.firstIndex(of: i)!)
                lastElement -= lastElement == -1 ? 0 : 1
                context.delete(i)}
            collectionView.deleteItems(at: selectedItemsIndexes)
        }, completion: { _ in
            for i in 0..<self.allImages.count{
                self.allImages[i].indexPathRow = Int16(i)
            }
            self.isDeleting = false
            self.collectionView.reloadData()
        })
        for i in 0..<self.allImages.count{
            self.allImages[i].indexPathRow = Int16(i)
        }
        self.saveContext()
        delegate.didSavedContext()
        reverseVisibleNavButtons()
    }
    
    private func choseElementToDisplay(indexPath: IndexPath){
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCell else { return }
        guard let image = cell.image else { return }
        cell.isSelected = false
        var selectToRow: Int
        if image.wasChosen{
            selectToRow = lastElement
            lastElement -= 1
        }
        
        else{
            lastElement += self.allImages.count != lastElement ? 1 : 0
            selectToRow = lastElement
        }
        
        // Updating CoreData
        image.wasChosen = !image.wasChosen
        self.allImages.remove(at: allImages.firstIndex(of: image)!)
        self.allImages.insert(image, at: selectToRow)
        for i in 0 ..< self.allImages.count {
            self.allImages[i].indexPathRow = Int16(i)
        }
        self.saveContext()
        self.delegate.didSavedContext()
            
        self.collectionView.moveItem(at: indexPath, to: [indexPath.startIndex, selectToRow])
        self.collectionView.reloadData()
        cell.animateChecker(isWasSelected: true)
    }
    
    private func reverseVisibleNavButtons(){
        let navBarButtonsAnimtion = UIViewPropertyAnimator(duration: 0.15, curve: .linear){
            guard let alpha = self.navigationItem.leftBarButtonItem?.isHidden else {return}
            if alpha == true{
                self.navigationItem.leftBarButtonItem?.isHidden = false
                self.navigationItem.rightBarButtonItem?.isHidden = false
                self.navigationItem.leftBarButtonItem?.customView?.alpha = 1.0
                self.navigationItem.rightBarButtonItem?.customView?.alpha = 1.0
            }
            else{
                self.navigationItem.leftBarButtonItem?.customView?.alpha = 0.0
                self.navigationItem.rightBarButtonItem?.customView?.alpha = 0.0
            }
        }
        navBarButtonsAnimtion.addCompletion({_ in
            guard let alpha = self.navigationItem.leftBarButtonItem?.customView?.alpha else {return}
            if alpha == 0.0{
                self.navigationItem.leftBarButtonItem?.isHidden = true
                self.navigationItem.rightBarButtonItem?.isHidden = true
            }
        })
        navBarButtonsAnimtion.startAnimation()
    }
}

// Mark - Configuratiins

extension ImagesViewController{
    
    private func configureNavigationBar() {
        
        self.title = "Выберите изображения"
        
        navigationController?.navigationBar.backgroundColor = .darkGray
        navigationController?.navigationBar.barTintColor = .darkGray
        
        // Cancel and ready buttons settings
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.leftBarButtonItem?.customView?.alpha = 0.0
        navigationItem.leftBarButtonItem?.isHidden = true
        
        let okButton = UIButton(type: .custom)
        okButton.setTitle("Готово", for: .normal)
        okButton.setTitleColor(.systemBlue, for: .normal)
        okButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: okButton)
        navigationItem.rightBarButtonItem?.customView?.alpha = 0.0
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
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ImagesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 4, height: collectionView.frame.width / 4)
    }
}
