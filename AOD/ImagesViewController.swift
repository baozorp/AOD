//
//  ImagesViewController.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit

private let reuseIdentifier = "Cell"

protocol ImagesViewControllerDelegate{
    func saveImage(_ images: UIImage)
    func deleteImage(_ image: UIImage)
}

class ImagesViewController: UICollectionViewController {
    
    let color = UIColor(red: 66.0/255.0, green: 233/255.0, blue: 171/255.0, alpha: 1.0)
    var imageArray: [UIImage] = []
    var delegate: ImagesViewControllerDelegate!

    
    override func viewDidLoad() {
        //color setting
        navigationController?.navigationBar.backgroundColor = .darkGray
        collectionView.backgroundColor = .darkGray
        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")

    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        cell.backgroundColor = .darkGray
        cell.contentMode = .scaleAspectFit
        
        let image = imageArray[indexPath.row]
        cell.imageView.contentMode = .scaleToFill
        cell.imageView.image = image
        cell.imageView.layer.cornerRadius = 20
        cell.checkStatus.image?.withTintColor(.darkGray)
        if imageArray.contains(image){
            cell.checkStatus.isHidden = false
        }
        else{
            cell.checkStatus.isHidden = true
        }
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
        if cell.checkStatus.isHidden{
            cell.checkStatus.isHidden = false
            delegate.saveImage(cell.imageView.image!)
        }
        else{
            cell.checkStatus.isHidden = true
            delegate.deleteImage(cell.imageView.image!)
            imageArray.remove(at: imageArray.firstIndex(of: cell.imageView.image!) ?? 0)
        }
        
        collectionView.reloadData()
    }

}
extension ImagesViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 4, height: collectionView.frame.width / 4)
    }
}
