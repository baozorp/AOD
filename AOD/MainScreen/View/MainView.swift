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
    
    let stack = UIStackView()
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
        setupClockAndDate()
        setupLongPressGesture()
    }
    
    private func setupClockAndDate(){
        
        let clockFormatter = DateFormatter()
        clockFormatter.dateFormat = "HH:mm"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        let clockHeight = self.frame.height / 10
        
        clock.text = clockFormatter.string(from: Date())
        clock.textColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        clock.font = UIFont.systemFont(ofSize: clockHeight)
        clock.textAlignment = NSTextAlignment.center

        
        date.text = dateFormatter.string(from: Date())
        date.center = CGPoint(x: clock.center.x + 1, y: clock.frame.maxY + date.frame.height/2)
        date.textColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        date.font = UIFont.systemFont(ofSize: clockHeight/3)
        date.textAlignment = .center
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.bottomAnchor.constraint(equalTo: collectionView.topAnchor)
        ])
            
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = -date.font.pointSize/2
        
        stack.addArrangedSubview(clock)
        stack.addArrangedSubview(date)
        
        let collectionViewMinY = CGFloat.random(in: (self.frame.minY + self.collectionView.frame.height + stack.frame.height)...(self.frame.maxY - self.collectionView.frame.height - self.frame.height / 6 ))
        
        collectionView.center.y = collectionViewMinY + collectionView.frame.height/2
    }
    
    private func setupCollectionView(){
        let collectionViewFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.width/2)
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
