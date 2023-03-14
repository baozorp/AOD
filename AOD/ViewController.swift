//
//  ViewController.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        settingOfCollectionView()


    }
    
    private func settingOfCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        
        cell.imageView.backgroundColor = .black
        cell.imageView.image = UIImage(named: "tree")

        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellWidth = collectionView.visibleCells.first?.frame.width ?? 0
        let currentPage = targetContentOffset.pointee.x / cellWidth
        let nextPage = currentPage.rounded()
        targetContentOffset.pointee.x = nextPage * cellWidth
    }

    func collectionView(_ collectionView: UICollectionView, didLongPressItemAt indexPath: IndexPath) {
        
    }

}

