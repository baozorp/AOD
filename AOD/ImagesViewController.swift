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
    var wasDeleting = true
    var isDeleting = false{
        willSet{
            wasDeleting = isDeleting
        }
    }
    
    
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
        
        // Cancel and ready settings
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        let okButton = UIButton(type: .custom)
        okButton.setTitle("Готово", for: .normal)
        okButton.setTitleColor(.systemBlue, for: .normal)
        okButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: okButton)
        
        navigationItem.leftBarButtonItem?.customView?.alpha = 0.0
        navigationItem.rightBarButtonItem?.customView?.alpha = 0.0
        
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
            guard try context.count(for: fetchRequestAll) > 0 else {return}
        }catch let error as NSError{
            print(error.localizedDescription)
            return
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

        if let picture = AODImage.picture{
            cell.pictureView.image = UIImage(data: picture)
        }

        cell.isDeleting = isDeleting
        cell.animateChecker()
        


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
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
//        guard !isDeleting else {return}
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: collectionView)
            if collectionView.indexPathForItem(at: point) != nil {
                isDeleting = !isDeleting
                reverseVisibleNavButtons()
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
        
        if let count = collectionView.indexPathsForSelectedItems?.count{
            self.isDeleting = false
            count == 0 ? collectionView.reloadData() : nil
        }
        reverseVisibleNavButtons()
        
        
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
            self.saveContext()
            self.collectionView.reloadData()
        })
        reverseVisibleNavButtons()
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


extension ImagesViewController{
    
    private func choseElementToDelete(indexPath: IndexPath){
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCell else {return}
        cell.isSelected = true
    }
    
    
    private func choseElementToDisplay(indexPath: IndexPath){
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCell else { return }
        guard let image = cell.image else { return }
        cell.isSelected = false
        if image.wasChosen{
            image.wasChosen = !image.wasChosen
            self.saveContext()
            self.delegate.deleteImage(image)
            self.chosenImages.remove(at: chosenImages.firstIndex(of: image)!)
            
            self.allImages.remove(at: allImages.firstIndex(of: image)!)
            self.allImages.insert(image, at: self.chosenImages.count)
            
            for i in indexPath.row ..< self.allImages.count {
                self.allImages[i].indexPathRow = Int16(i)
            }
            collectionView.performBatchUpdates({
                self.collectionView.reloadData()
                self.collectionView.moveItem(at: indexPath, to: [indexPath.startIndex, self.chosenImages.count])
                self.saveContext()
                cell.animateChecker()
    
            })
        }
        
        else{
            image.wasChosen = !image.wasChosen
            self.delegate.saveImage(image)
            self.chosenImages.append(image)
            image.indexPathRow = Int16(self.chosenImages.count - 1)
            self.saveContext()
            self.allImages.remove(at: indexPath.row)
            self.allImages.insert(image, at: self.chosenImages.count - 1)
            for i in (self.chosenImages.count - 1) ..< self.allImages.count {
                self.allImages[i].indexPathRow = Int16(i)
            }
            collectionView.performBatchUpdates({
                self.collectionView.reloadData()
                self.collectionView.moveItem(at: indexPath, to: [indexPath.startIndex, self.chosenImages.count-1])
                self.saveContext()
                cell.animateChecker()
            })
        }
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
