//
//  AODViewController.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit
import CoreData

class AODViewController: UIViewController{
    
    private var numberOfImages = 0
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var collectionView: UICollectionView!
    private var longPressGesture: UILongPressGestureRecognizer!
    
    var fetchedResultsController: NSFetchedResultsController<Image>!
    
    private let clock = UILabel()
    private let date = UILabel()
    private var previousMinute: String = ""
    private var moveToTop = true
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    private var clocktimer: Timer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        firstStartChecker()
        loadImagesFromCoreData()
        createNSFetchRequestResultsController()
    }

    
    // Timer stop
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clocktimer?.invalidate()
        clocktimer = nil
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupUI() {
        
        UIApplication.shared.isIdleTimerDisabled = true
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
        clock.textAlignment = NSTextAlignment.center
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
                clock.center.y -= 5
                date.center.y -= 5
                collectionView.center.y -= 5
            }
            else if !moveToTop, collectionView.frame.maxY < (self.view.frame.maxY - self.view.safeAreaInsets.bottom - self.view.frame.height / 8){
                clock.center.y += 5
                date.center.y += 5
                collectionView.center.y += 5
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
    
    func createNSFetchRequestResultsController(){

        let request: NSFetchRequest<Image> = Image.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "wasChosen", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
          try fetchedResultsController.performFetch()
        } catch {
          print("Error fetching data: \(error)")
        }
    }
    
    // MARK: - Long Press Gesture Handling
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: collectionView)
            if collectionView.indexPathForItem(at: point) != nil {
                
                let feedback = UIImpactFeedbackGenerator(style: .medium)
                feedback.prepare()
                feedback.impactOccurred()
                
                let imagesNC = UINavigationController()
                let layout = UICollectionViewFlowLayout()
                let imagesVC = ImagesViewController(collectionViewLayout: layout)
                imagesNC.pushViewController(imagesVC, animated: true)
                imagesVC.context = context
                imagesVC.AODCollectionViewHeight = collectionView.frame.height

                UIApplication.shared.isIdleTimerDisabled = false
                
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

extension AODViewController: UICollectionViewDataSource{
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
            let operationQueue = DispatchQueue(label: "AODUpdater")
            operationQueue.async {
                let fetchRequest = Image.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "indexPathRow == %@", argumentArray: [Int16(indexPath.row)])
                var fetchedImages: Image?
                do {
                    fetchedImages = try self.context.fetch(fetchRequest).first!
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    guard let picture = fetchedImages!.picture else {return}
                    cell.pictureView.layer.cornerRadius = 50
                    cell.pictureView.image = UIImage(data: (picture))
                }
            }
        }
        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension AODViewController: UICollectionViewDelegate{
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

extension AODViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
}

// Mark - Delegate for ImagesViewController which reload Data


extension AODViewController: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadImagesFromCoreData()
        collectionView.reloadData()
    }
}


// Mark - First start checker

extension AODViewController{
    
    private func firstStartChecker(){

        let firstStartRequest = FirstStart.fetchRequest()

        do{
            guard try context.count(for: firstStartRequest) == 0 else {return}

        }catch let error as NSError{
            print(error.localizedDescription)
        }
        _ = FirstStart(context: context)
        
        let startPictures = ["cosmo", "journalist", "cowboy"]
        for i in 0...(startPictures.count-1){
            let image = UIImage(named: startPictures[i])
            let newSize = CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {return}
            UIGraphicsEndImageContext()
            let item = Image(context: context)
            item.picture = newImage.pngData()
            item.wasChosen = true
            item.indexPathRow = Int16(i)
        }

        do{
            try context.save()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
}
