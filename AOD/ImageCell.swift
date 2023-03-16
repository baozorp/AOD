//
//  ImageCell.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    let checkStatus = UIImageView()

    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupViews()
        checkStatus.isHidden = true
        
        checkStatus.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [UIColor(red: 66.0/255.0, green: 233/255.0, blue: 171/255.0, alpha: 1.0)]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Add the image view to the cell's content view and set its constraints
        contentView.addSubview(imageView)
        contentView.addSubview(checkStatus)

        
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        checkStatus.translatesAutoresizingMaskIntoConstraints = false
        checkStatus.frame.size = CGSize(width: self.frame.width/7, height: self.frame.height/7)
        NSLayoutConstraint.activate([
            checkStatus.topAnchor.constraint(equalTo: self.topAnchor),
            checkStatus.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
    }
}
