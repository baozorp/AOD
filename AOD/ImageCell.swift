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
    let deleteStatus = UIImageView()
    var image: Image?
    private var firstAnimation = CABasicAnimation(keyPath: "position")
    private var secondAnimation = CABasicAnimation(keyPath: "transform.rotation")
//    private var deleteAnimation = CABasicAnimation(keyPath: "opacity")
    var deleteAppearenceAnimation = UIViewPropertyAnimator()
    var isDeleting = false{
        didSet{
            if isDeleting{
                checkStatus.isHidden = true
            }
            else{
                guard let image = image else {return}
                checkStatus.isHidden = image.wasChosen ? false : true
            }
        }
    }
    
    override var isSelected: Bool{
        didSet{
            if isDeleting{
                if isSelected{
                    deleteStatus.alpha = 0.0
                    deleteAppearenceAnimation = UIViewPropertyAnimator(duration: 0.1, curve: .linear){
                        self.deleteStatus.alpha = 1.0
                    }
                    deleteAppearenceAnimation.startAnimation()
                }
                else{
                    deleteStatus.alpha = 1.0
                    deleteAppearenceAnimation = UIViewPropertyAnimator(duration: 0.1, curve: .linear){
                        self.deleteStatus.alpha = 0.0
                    }
                    
                    deleteAppearenceAnimation.startAnimation()
                }
                
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAnimations()
        setupViews()
        setupImages()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        shakeCell()
    }

    private func shakeCell() {
        if isDeleting{
            self.contentView.layer.add(firstAnimation, forKey: "firstAnimation")
            self.contentView.layer.add(secondAnimation, forKey: "secondAnimation")
        }
        else{
            self.contentView.layer.removeAllAnimations()
        }
    }
    
    private func setupAnimations(){
        
        // Position animation
        firstAnimation.duration = 0.2
        firstAnimation.repeatCount = .infinity
        firstAnimation.autoreverses = true
        firstAnimation.fromValue = NSValue(cgPoint: CGPoint(x: self.contentView.center.x + 1, y: self.contentView.center.y + 1))
        firstAnimation.toValue = NSValue(cgPoint: CGPoint(x: self.contentView.center.x - 1, y: self.contentView.center.y - 1))
        
        // Rotation animation
        secondAnimation.duration = 0.1
        secondAnimation.repeatCount = .infinity
        secondAnimation.autoreverses = true
        secondAnimation.fromValue = -CGFloat.pi / 150
        secondAnimation.toValue = CGFloat.pi / 150
        

    }
    
    private func setupImages(){
        
        // CheckStatus settings
        let checkColor = UIColor(red: 66/255.0, green: 233/255.0, blue: 171/255.0, alpha: 1.0)
        let checkConfiguration = UIImage.SymbolConfiguration(paletteColors: [checkColor])
        checkStatus.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: checkConfiguration)
        checkStatus.isHidden = true
        
        // DeleteStatus settings
        let deleteColor = UIColor(red: 255/255.0, green: 40/255.0, blue: 38/255.0, alpha: 1.0)
        let deleteConfiguration = UIImage.SymbolConfiguration(paletteColors: [deleteColor])
        deleteStatus.image = UIImage(systemName: "trash.fill", withConfiguration: deleteConfiguration)
        deleteStatus.isHidden = false
        deleteStatus.alpha = 0.0
    }
    
    private func setupViews() {
        
        // Views settings
        pictureView.contentMode = .scaleAspectFit
        pictureView.layer.cornerRadius = 20
        pictureView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        let coefficient = CGFloat(5)
        
        checkStatus.frame = CGRect(x: self.frame.width - self.frame.width/5, y: 0, width: self.frame.width/coefficient, height: self.frame.height/coefficient)
        
        deleteStatus.frame = CGRect(x: 0, y: 0, width: self.frame.width/coefficient, height: self.frame.height/coefficient)
        
        // Add the image view to the cell's content view and set its constraints
        contentView.addSubview(pictureView)
        contentView.addSubview(checkStatus)
        contentView.addSubview(deleteStatus)
    }
}
