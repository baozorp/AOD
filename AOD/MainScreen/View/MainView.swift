//
//  MainView.swift
//  AOD
//
//  Created by Михаил Шекунов on 09.04.2023.
//
// MainView.swift

import UIKit

protocol MainViewDelegate: AnyObject {
    func didSelectItemAtLongPress()
}

class MainView: UIView {
    // Все UI-компоненты должны быть здесь
    var collectionView: UICollectionView!
    
    let clock = UILabel()
    let date = UILabel()
    
    weak var delegate: MainViewDelegate!
    
    init(frame: CGRect, delegate: MainViewDelegate){
        super.init(frame: frame)
        self.delegate = delegate
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        UIApplication.shared.isIdleTimerDisabled = true
        backgroundColor = .black
        setupCollectionView()
        setupClock()
        setupLongPressGesture()
    }
    
    private func setupClock(){
        let clockFormatter = DateFormatter()
        clockFormatter.dateFormat = "HH:mm"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        let clockHeight = self.frame.height / 10
        
        clock.frame = CGRect(x: 0, y: collectionView.frame.midY - collectionView.frame.height * 1.2, width: self.frame.width, height: clockHeight)
        clock.text = clockFormatter.string(from: Date())
        clock.textColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        clock.font = UIFont.systemFont(ofSize: clockHeight)
        clock.textAlignment = NSTextAlignment.center
        //        previousMinute = clock.text ?? ""
        self.addSubview(clock)
        
        date.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: clockHeight/3)
        date.text = dateFormatter.string(from: Date())
        date.center = CGPoint(x: clock.center.x + 1, y: clock.frame.maxY + date.frame.height/2)
        date.textColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        date.font = UIFont.systemFont(ofSize: clockHeight/3)
        date.textAlignment = .center
        self.addSubview(date)
    }
    
    private func setupCollectionView(){
        let collectionViewY = CGFloat.random(in: (self.frame.minY + self.frame.width/2)...(self.frame.maxY - self.safeAreaInsets.bottom - self.frame.width))
        let collectionViewFrame = CGRect(x: 0, y: collectionViewY, width: self.frame.width, height: self.frame.width/2)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: UICollectionViewFlowLayout())
        self.addSubview(collectionView)
        collectionView.backgroundColor = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MainImageCell.self, forCellWithReuseIdentifier: "mainImageCell")
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        flowLayout.minimumLineSpacing = collectionView.frame.width / 4
        flowLayout.scrollDirection = .horizontal
    }
    
    
    private func setupLongPressGesture(){
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: collectionView)
            if collectionView.indexPathForItem(at: point) != nil {
                delegate?.didSelectItemAtLongPress()
            }
        }
    }
    
}
