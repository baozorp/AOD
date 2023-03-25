//
//  ViewController.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController{
    
    private var numberOfImages = 0
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
                imagesVC.AODCollectionViewHeight = collectionView.frame.height
                present(imagesNC, animated: true)
            }
        }
    }
    
    // Mark - Data loading
    
    private func loadImagesFromCoreData() {
        let fetchRequest = Image.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "wasChosen == %@", argumentArray: [true])
        do {
            numberOfImages = try context.count(for: fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        
        if numberOfImages == 0{
            cell.pictureView.tintColor = .darkGray
            cell.pictureView.image = UIImage(systemName: "nosign")
        }
        else{
            // Подгружаем данные из СoreData
            let operationQueue = OperationQueue()
            operationQueue.addOperation {
                let fetchRequest = Image.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "indexPathRow == %@", argumentArray: [Int16(indexPath.row)])
                var fetchedImages: Image?
                do {
                    fetchedImages = try self.context.fetch(fetchRequest).first!
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                OperationQueue.main.addOperation {
                    cell.pictureView.layer.cornerRadius = 50
                    cell.pictureView.image = UIImage(data: (fetchedImages!.picture)!)
                }
                            
            }
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
    
    func didSavedContext() {
        loadImagesFromCoreData()
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
        
//        let systemImages: [String] = ["mountain.2.circle", "hourglass", "play.rectangle", "circle", "cloud.sun.bolt.circle", "eraser", "tropicalstorm", "airplane", "trash", "bicycle", "ferry", "tram", "box.truck", "figure.walk", "bag", "tornado", "compass.drawing", "globe.central.south.asia", "infinity", "snowflake", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "drop", "clock", "creditcard", "globe.central.south.asia", "carrot", "goforward", "heart.square.fill", "wind", "lamp.desk", "theatermasks.circle", "hammer.circle", "heart.square.fill", "tree", "fan.floor", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "leaf", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "tortoise", "bolt.circle", "gyroscope", "tree", "globe.central.south.asia", "lizard", "flame.circle", "mountain.2.circle", "hourglass", "play.rectangle", "circle", "cloud.sun.bolt.circle", "eraser", "tropicalstorm", "airplane", "trash", "bicycle", "ferry", "tram", "box.truck", "figure.walk", "bag", "tornado", "compass.drawing", "globe.central.south.asia", "infinity", "snowflake", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "drop", "clock", "creditcard", "globe.central.south.asia", "carrot", "goforward", "heart.square.fill", "wind", "lamp.desk", "theatermasks.circle", "hammer.circle", "heart.square.fill", "tree", "fan.floor", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "leaf", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "tortoise", "bolt.circle", "gyroscope", "tree", "globe.central.south.asia", "lizard", "flame.circle"]
//        for i in 0..<systemImages.count{
//            let image = Image(context: context)
//            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: collectionView.frame.height)
//            let systemImage = UIImage(systemName: systemImages[i], withConfiguration: symbolConfiguration)?.withTintColor(.white)
//            image.picture = systemImage?.pngData()
//            image.wasChosen = true
//            image.indexPathRow = Int16(i)
//        }
        
        let image = UIImage(named: "cosmo")

        // Новые размеры
        let newSize = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)

        // Начать контекст графики с новыми размерами
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
         
        // Нарисовать новое изображение с измененным разрешением
        image?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))

        // Получить изображение из контекста графики
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {return}


        // Закрыть контекст графики
        UIGraphicsEndImageContext()
        
        for i in 0...100{
            let image = Image(context: context)
            image.picture = newImage.pngData()
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
