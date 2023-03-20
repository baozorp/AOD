//
//  ViewController.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController{
        
    private var imageArray: [Image] = []
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var collectionView: UICollectionView!
    private var longPressGesture: UILongPressGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        firstStartChecker()
        loadImagesFromCoreData()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        setupCollectionView()
        setupLongPressGesture()
    }
    
    private func setupCollectionView(){
        let collectionViewFrame = CGRect(x: 0, y: self.view.frame.midY - self.view.frame.width/4, width: self.view.frame.width, height: self.view.frame.width/2)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: UICollectionViewFlowLayout())
        self.view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        flowLayout.minimumLineSpacing = collectionView.frame.width / 4
        flowLayout.scrollDirection = .horizontal
    }
    
    private func setupLongPressGesture(){
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - Long Press Gesture Handling
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: collectionView)
            if collectionView.indexPathForItem(at: point) != nil {
                let imagesNC = UINavigationController()
                let layout = UICollectionViewFlowLayout()
                let imagesVC = ImagesViewController(collectionViewLayout: layout)
                imagesNC.pushViewController(imagesVC, animated: true)
                imagesVC.delegate = self
                imagesVC.context = context
                imagesVC.chosenImages = imageArray
                present(imagesNC, animated: true)
            }
        }
    }
    
    // Mark - Data loading
    
    private func loadImagesFromCoreData() {
        let fetchRequest = Image.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "wasChosen == %@", argumentArray: [true])
        do {
            let fetchedImages = try context.fetch(fetchRequest)
            if !fetchedImages.isEmpty {
                imageArray = fetchedImages.sorted { $0.indexPathRow < $1.indexPathRow }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.isEmpty ? 1 : imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        
        if imageArray.count == 0{
            cell.pictureView.tintColor = .darkGray
            cell.pictureView.image = UIImage(systemName: "nosign")
        }
        else{
            cell.pictureView.image = UIImage(data: imageArray[indexPath.row].picture!)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: collectionView.frame.width / 4, bottom: 0, right: collectionView.frame.width / 4)
    }

    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
              let firstVisibleCell = collectionView.visibleCells.first else {
            return
        }
        
        let cellWidth = firstVisibleCell.frame.width
        let spacing = flowLayout.minimumLineSpacing
        let sectionInset = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        
        let currentPage = targetContentOffset.pointee.x / (cellWidth + spacing + sectionInset)
        let nextPage = round(currentPage)
        targetContentOffset.pointee.x = nextPage * (cellWidth + spacing + sectionInset)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
}

// Mark - Delegate for ImagesViewController which reload Data

extension ViewController: ImagesViewControllerDelegate{
    
    func wasChosenImage(_ image: Image) {
        imageArray.append(image)
        collectionView.reloadData()
    }
    
    func wasNotChosenImage(_ image: Image) {
        guard let imageIndex = imageArray.firstIndex(of: image) else {return}
        imageArray.remove(at: imageIndex)
        collectionView.reloadData()
    }
}

extension ViewController{
    
    private func firstStartChecker(){
        let fetchRequest = Image.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "picture != nil")
        do{
            guard try context.fetch(fetchRequest).count == 0 else {return}
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        
        let systemImages: [String] = ["heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle"]
        
        for i in 0..<systemImages.count{
            let image = Image(context: context)
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: collectionView.frame.height)
            let systemImage = UIImage(systemName: systemImages[i], withConfiguration: symbolConfiguration)?.withTintColor(.white)
            image.picture = systemImage?.pngData()
            image.wasChosen = true
            image.indexPathRow = Int16(i)
        }
        
        do{
            try context.save()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
}
