//
//  ViewController.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageArray: [Image] = []
    var context: NSManagedObjectContext!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destNC = segue.destination as? UINavigationController else {return}
        guard let destVC = destNC.viewControllers.first as? ImagesViewController else {return}
        destVC.delegate = self
        destVC.context = context
        destVC.chosenImages = imageArray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstStart()
        view.backgroundColor = .black
        settingOfCollectionView()
        getImagesFromCoreData()
    }
    
    private func getImagesFromCoreData(){
        let fetchRequest = Image.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "wasChosen == %@", argumentArray: [true])
        do{
            let request = try context.fetch(fetchRequest)
            guard request.count > 0 else{return}
            print(request.count)
            imageArray = [Image](repeating: request[0], count: request.count)
            for i in 0..<request.count{
                imageArray[Int(request[i].indexPathRow)] = request[i]
            }
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    private func settingOfCollectionView(){
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        flowLayout.minimumLineSpacing = collectionView.frame.width / 4
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: collectionView)
            if collectionView.indexPathForItem(at: point) != nil {
                performSegue(withIdentifier: "identer", sender: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: collectionView.frame.width / 4, bottom: 0, right: collectionView.frame.width / 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count == 0 ? 1 : imageArray.count
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

extension ViewController: ImagesViewControllerDelegate{
    
    func saveImage(_ image: Image) {
        imageArray.append(image)
        collectionView.reloadData()
    }
    
    func deleteImage(_ image: Image) {
        guard let imageIndex = imageArray.firstIndex(of: image) else {return}
        imageArray.remove(at: imageIndex)
        collectionView.reloadData()
    }
}

extension ViewController{
    
    private func firstStart(){
        let fetchRequest = Image.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "picture != nil")
        do{
            guard try context.fetch(fetchRequest).count == 0 else {return}
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        
        let systemImages: [String] = ["heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle"]
        //, "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "trash", "cloud.sun.bolt.circle"]
        
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
