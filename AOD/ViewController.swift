//
//  ViewController.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController{
    
    private var numberOfImages = 0
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var collectionView: UICollectionView!
    private var longPressGesture: UILongPressGestureRecognizer!
    
    private let clock = UILabel()
    private let date = UILabel()
    private var previousMinute: String = ""
    private var moveToTop = true
    
    private var clocktimer: Timer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        firstStartChecker()
        loadImagesFromCoreData()
    }
    
    // Timer stop
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clocktimer?.invalidate()
        clocktimer = nil
    }
    
    private func setupUI() {
        view.backgroundColor = .black
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
        
        let clockHeight = view.frame.height / 10
        
        clock.frame = CGRect(x: 0, y: collectionView.frame.midY - collectionView.frame.height * 1.2, width: view.frame.width, height: clockHeight)
        clock.text = clockFormatter.string(from: Date())
        clock.textColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        clock.font = UIFont.systemFont(ofSize: clockHeight)
        clock.textAlignment = .center
        previousMinute = clock.text ?? ""
        self.view.addSubview(clock)
        
        date.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: clockHeight/3)
        date.text = dateFormatter.string(from: Date())
        date.center = CGPoint(x: clock.center.x + 1, y: clock.frame.maxY + date.frame.height/2)
        date.textColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        date.font = UIFont.systemFont(ofSize: clockHeight/3)
        date.textAlignment = .center

        self.view.addSubview(date)

        clocktimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {[unowned self] _ in
            clock.text = clockFormatter.string(from: Date())
            date.text = dateFormatter.string(from: Date())
            guard clock.text! != previousMinute else {return}
            previousMinute = clock.text ?? ""
            if moveToTop, clock.frame.minY > (self.view.frame.minY + self.view.safeAreaInsets.top){
                clock.center.y -= 10
                date.center.y -= 10
                collectionView.center.y -= 10
            }
            else if !moveToTop, collectionView.frame.maxY < (self.view.frame.maxY - self.view.safeAreaInsets.bottom - self.view.frame.height / 8){
                clock.center.y += 10
                date.center.y += 10
                collectionView.center.y += 10
            }
            else{
                moveToTop = !moveToTop
            }

        })
    }
    
    private func setupCollectionView(){
        let collectionViewY = CGFloat.random(in: (self.view.frame.minY + self.view.frame.width/2)...(self.view.frame.maxY - self.view.safeAreaInsets.bottom - self.view.frame.width))
        let collectionViewFrame = CGRect(x: 0, y: collectionViewY, width: self.view.frame.width, height: self.view.frame.width/2)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: UICollectionViewFlowLayout())
        self.view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        flowLayout.minimumLineSpacing = collectionView.frame.width / 4
        flowLayout.scrollDirection = .horizontal
    }
    
    private func setupLongPressGesture(){
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - Long Press Gesture Handling
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: collectionView)
            if collectionView.indexPathForItem(at: point) != nil {
                let imagesNC = UINavigationController()
                let layout = UICollectionViewFlowLayout()
                let imagesVC = ImagesViewController(collectionViewLayout: layout)
                imagesNC.pushViewController(imagesVC, animated: true)
                imagesVC.delegate = self
                imagesVC.context = context
                imagesVC.AODCollectionViewHeight = collectionView.frame.height
                present(imagesNC, animated: true)
            }
        }
    }
    
    // Mark - Data loading
    
    private func loadImagesFromCoreData() {
        let fetchRequest = Image.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "wasChosen == %@", argumentArray: [true])
        do {
            numberOfImages = try context.count(for: fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages == 0 ? 1: numberOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        
        if numberOfImages == 0{
            cell.pictureView.tintColor = .darkGray
            cell.pictureView.image = UIImage(systemName: "nosign")
        }
        else{
            // Подгружаем данные из СoreData
            let operationQueue = OperationQueue()
            operationQueue.addOperation {
                let fetchRequest = Image.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "indexPathRow == %@", argumentArray: [Int16(indexPath.row)])
                var fetchedImages: Image?
                do {
                    fetchedImages = try self.context.fetch(fetchRequest).first!
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                OperationQueue.main.addOperation {
                    cell.pictureView.layer.cornerRadius = 50
                    cell.pictureView.image = UIImage(data: (fetchedImages!.picture)!)
                }
                            
            }
        }

        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: collectionView.frame.width / 4, bottom: 0, right: collectionView.frame.width / 4)
    }

    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
              let firstVisibleCell = collectionView.visibleCells.first else {
            return
        }
        
        let cellWidth = firstVisibleCell.frame.width
        let spacing = flowLayout.minimumLineSpacing
        let sectionInset = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        
        let currentPage = targetContentOffset.pointee.x / (cellWidth + spacing + sectionInset)
        let nextPage = round(currentPage)
        targetContentOffset.pointee.x = nextPage * (cellWidth + spacing + sectionInset)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
}

// Mark - Delegate for ImagesViewController which reload Data

extension ViewController: ImagesViewControllerDelegate{
    
    func didSavedContext() {
        loadImagesFromCoreData()
        collectionView.reloadData()
    }
}

extension ViewController{
    
    private func firstStartChecker(){

        let firstStartRequest = FirstStart.fetchRequest()

        do{
            guard try context.count(for: firstStartRequest) == 0 else {return}

        }catch let error as NSError{
            print(error.localizedDescription)
        }
        _ = FirstStart(context: context)
        let image = UIImage(named: "cosmo")
        let newSize = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {return}
        UIGraphicsEndImageContext()
        
        let item = Image(context: context)
        item.picture = newImage.pngData()
        item.wasChosen = true
        item.indexPathRow = Int16(0)
        
        let systemImages: [String] = ["mountain.2.circle", "hourglass", "play.rectangle", "circle", "cloud.sun.bolt.circle", "eraser", "tropicalstorm", "airplane", "bicycle", "ferry", "tram", "box.truck", "figure.walk", "bag", "tornado", "compass.drawing", "infinity", "snowflake", "drop", "clock", "creditcard", "carrot", "goforward", "wind", "lamp.desk", "theatermasks.circle", "hammer.circle", "fan.floor", "cloud.sun.bolt.circle", "heart.square.fill", "tree", "globe.central.south.asia", "leaf", "tortoise", "bolt.circle", "gyroscope", "lizard", "flame.circle"]
        
        for i in 1..<systemImages.count{
            let image = Image(context: context)
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: collectionView.frame.height)
            let systemImage = UIImage(systemName: systemImages[i], withConfiguration: symbolConfiguration)?.withTintColor(.white)
            image.picture = systemImage?.pngData()
            image.wasChosen = false
            image.indexPathRow = Int16(i)
        }
    
        do{
            try context.save()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
}
