//
//  MainImageCell.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit

class MainImageCell: UICollectionViewCell {
    
    let pictureView = UIImageView()
    var image: Item?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Views settings
        pictureView.layer.masksToBounds = true
        pictureView.contentMode = .scaleAspectFill
        pictureView.layer.cornerRadius = 50
        pictureView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        // Add the image view to the cell's content view and set its constraints
        contentView.addSubview(pictureView)
    }
}
