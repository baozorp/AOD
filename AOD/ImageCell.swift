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
    var deleteAppearenceAnimation = UIViewPropertyAnimator()
    var isDeleting = false
    
    override var isSelected: Bool{
        didSet{
            if isDeleting{
                if isSelected{
                    deleteStatus.alpha = 0.0
                    deleteAppearenceAnimation = UIViewPropertyAnimator(duration: 0.15, curve: .linear){
                        self.deleteStatus.alpha = 1.0
                    }
                    deleteAppearenceAnimation.startAnimation()
                }
                else{
                    deleteStatus.alpha = 1.0
                    deleteAppearenceAnimation = UIViewPropertyAnimator(duration: 0.15, curve: .linear){
                        self.deleteStatus.alpha = 0.0
                    }
                    deleteAppearenceAnimation.startAnimation()
                }
            }
        }
    }
    
    func animateDeleter(_ completion: (()->Void)? = nil){
        guard isDeleting, isSelected else {return}
        let animation = UIViewPropertyAnimator(duration: 0.1, curve: .linear)
        self.deleteStatus.alpha = 1.0
        animation.addAnimations {
            self.deleteStatus.alpha = 0.0
        }
        animation.addCompletion({_ in
            completion?()
        })
        animation.startAnimation()

    }
    
    
    func animateChecker(){
        guard let image = image else {return}
        let checkAppearenceAnimation = UIViewPropertyAnimator(duration: 0.1, curve: .linear)
        if self.isDeleting && image.wasChosen{
            self.checkStatus.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            checkAppearenceAnimation.addAnimations {
                self.checkStatus.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }
        }
        else if self.isDeleting && !image.wasChosen{
            self.checkStatus.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }
        else if image.wasChosen{
            guard self.checkStatus.transform != CGAffineTransform(scaleX: 1.0, y: 1.0) else {return}
            self.checkStatus.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            checkAppearenceAnimation.addAnimations {
                self.checkStatus.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
        else if !image.wasChosen{
            guard self.checkStatus.transform != CGAffineTransform(scaleX: 0.01, y: 0.01) else {return}
            self.checkStatus.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            checkAppearenceAnimation.addAnimations {
                self.checkStatus.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }
        }
        checkAppearenceAnimation.startAnimation()
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
        checkStatus.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        // DeleteStatus settings
        let deleteColor = UIColor(red: 255/255.0, green: 40/255.0, blue: 38/255.0, alpha: 1.0)
        let deleteConfiguration = UIImage.SymbolConfiguration(paletteColors: [deleteColor])
        deleteStatus.image = UIImage(systemName: "trash.fill", withConfiguration: deleteConfiguration)
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
