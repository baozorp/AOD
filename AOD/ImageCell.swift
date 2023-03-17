//
//  ImageCell.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    let pictureView = UIImageView()
    let checkStatus = UIImageView()
    var image: Image?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupViews()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Add the image view to the cell's content view and set its constraints
        contentView.addSubview(pictureView)
        contentView.addSubview(checkStatus)
        
        pictureView.contentMode = .scaleAspectFit
        pictureView.layer.cornerRadius = 20
        
        checkStatus.isHidden = true
        checkStatus.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(paletteColors: [UIColor(red: 66.0/255.0, green: 233/255.0, blue: 171/255.0, alpha: 1.0)]))

        
        pictureView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pictureView.topAnchor.constraint(equalTo: self.topAnchor),
            pictureView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            pictureView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            pictureView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        checkStatus.translatesAutoresizingMaskIntoConstraints = false
        checkStatus.frame.size = CGSize(width: self.frame.width/7, height: self.frame.height/7)
        NSLayoutConstraint.activate([
            checkStatus.topAnchor.constraint(equalTo: self.topAnchor),
            checkStatus.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
    }
}
