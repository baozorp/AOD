//
//  ImageCell.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let checkImage = UIImageView()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Add the image view to the cell's content view and set its constraints
        contentView.addSubview(imageView)
        contentView.addSubview(checkImage)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        checkImage.translatesAutoresizingMaskIntoConstraints = false
        checkImage.frame.size = CGSize(width: self.frame.width/7, height: self.frame.height/7)
        NSLayoutConstraint.activate([
            checkImage.topAnchor.constraint(equalTo: self.topAnchor),
            checkImage.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
    }
}
