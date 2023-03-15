//
//  ImagesViewController.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit

private let reuseIdentifier = "Cell"

class ImagesViewController: UICollectionViewController {
    
    let color = UIColor(red: 66.0/255.0, green: 233/255.0, blue: 171/255.0, alpha: 1.0)
    var systemImages: [String] = ["trash", "tree", "globe.central.south.asia", "cloud.sun.bolt.circle"]
    
    override func viewDidLoad() {

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")

    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return systemImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        cell.imageView.contentMode = .scaleAspectFit
//        cell.imageView.image = UIImage(named: "tree")
        cell.imageView.image = UIImage(systemName: systemImages[indexPath.row], withConfiguration: UIImage.SymbolConfiguration(paletteColors: [.white]))
        cell.imageView.layer.cornerRadius = 20
        cell.imageView.backgroundColor = .darkGray
        cell.layer.cornerRadius = 20
        cell.contentMode = .scaleAspectFit
        // Configure the cell
        cell.checkImage.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [color]))
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
        if cell.checkImage.isHidden{
            cell.checkImage.isHidden = false
        }
        else{
            cell.checkImage.isHidden = true
        }
    }

}
extension ImagesViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
