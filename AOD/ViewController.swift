//
//  ViewController.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{

    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageArray: [UIImage] = []
    var systemImages: [String] = ["trash", "tree", "globe.central.south.asia", "cloud.sun.bolt.circle"]
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destNC = segue.destination as? UINavigationController else {return}
        guard let destVC = destNC.viewControllers.first as? ImagesViewController else {return}
        destVC.delegate = self
        destVC.imageArray = imageArray
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageArray.append(UIImage(named: "tree")!)
        for i in systemImages{
            imageArray.append(UIImage(systemName: i)!)
        }
        view.backgroundColor = .black
        settingOfCollectionView()
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
        return imageArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        cell.imageView.contentMode = .scaleAspectFit
        cell.imageView.image = imageArray[indexPath.row]
        cell.imageView.layer.cornerRadius = 20

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
    
    func saveImage(_ image: UIImage) {
        imageArray.append(image)
        collectionView.reloadData()
    }
    func deleteImage(_ image: UIImage) {
        imageArray.remove(at: imageArray.firstIndex(of: image)!)
        collectionView.reloadData()
    }
}
