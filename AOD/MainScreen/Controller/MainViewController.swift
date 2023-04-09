//
//  AODViewController.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit
import CoreData

class MainViewController: UIViewController{
    
    private var mainView: MainView!
    private var mainViewModel: MainViewModel!
    
    private var numberOfImages = 0
    private var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchedResultsController: NSFetchedResultsController<Item>!

    private var previousMinute: String = ""
    private var isMovingToTop = true
    
    private var clocktimer: Timer?
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView = MainView(frame: view.bounds, delegate: self)
        mainView.collectionView.dataSource = self
        mainView.collectionView.delegate = self
        mainViewModel = MainViewModel(sizeOfCell: mainView.collectionView.frame.height, delegate: self)
        self.view.addSubview(mainView)
        setTimer()
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
    
    func setTimer() {
        previousMinute = mainView.clock.text ?? ""
        clocktimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired(_:)), userInfo: nil, repeats: true)
    }

    @objc func timerFired(_ timer: Timer) {
        let clock = mainView.clock
        let date = mainView.date

        let clockFormatter = DateFormatter()
        clockFormatter.dateFormat = "HH:mm"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        clock.text = clockFormatter.string(from: Date())
        date.text = dateFormatter.string(from: Date())
        guard clock.text! != previousMinute else { return }
        previousMinute = clock.text ?? ""

        if isMovingToTop, clock.frame.minY > (view.frame.minY + view.safeAreaInsets.top) {
            clock.center.y -= 5
            date.center.y -= 5
            mainView.collectionView.center.y -= 5
        } else if !isMovingToTop, mainView.collectionView.frame.maxY < (view.frame.maxY - view.safeAreaInsets.bottom - view.frame.height / 8) {
            clock.center.y += 5
            date.center.y += 5
            mainView.collectionView.center.y += 5
        } else {
            isMovingToTop = !isMovingToTop
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MainViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages == 0 ? 1: numberOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainImageCell", for: indexPath) as! MainImageCell
        
        if numberOfImages == 0{
            cell.pictureView.tintColor = .darkGray
            cell.pictureView.image = UIImage(systemName: "nosign")
        }
        else{
            // Подгружаем данные из СoreData
            let operationQueue = DispatchQueue(label: "AODUpdater")
            operationQueue.async {
                let fetchRequest = Item.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "indexPathRow == %@", argumentArray: [Int16(indexPath.row)])
                var fetchedImages: Item?
                do {
                    fetchedImages = try self.context.fetch(fetchRequest).first!
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    guard let image = fetchedImages!.image else {return}
                    cell.pictureView.layer.cornerRadius = 50
                    cell.pictureView.image = UIImage(data: (image))
                }
            }
        }
        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: collectionView.frame.width / 4, bottom: 0, right: collectionView.frame.width / 4)
    }

    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let flowLayout = mainView.collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
              let firstVisibleCell = mainView.collectionView.visibleCells.first else {
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

extension MainViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
}

// MARK: - Long Press Gesture Handling

extension MainViewController: MainViewDelegate{
    
    func didSelectItemAtLongPress() {
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.prepare()
        feedback.impactOccurred()
        
        let imagesNC = UINavigationController()
        let layout = UICollectionViewFlowLayout()
        let imagesVC = SelectionViewController(collectionViewLayout: layout)
        imagesNC.pushViewController(imagesVC, animated: true)
        imagesVC.context = context
        imagesVC.AODCollectionViewHeight = mainView.collectionView.frame.height
        
        UIApplication.shared.isIdleTimerDisabled = false
        present(imagesNC, animated: true)
    }
}

// MARK: - CoreData updated Delegate

extension MainViewController: MainViewModelDelegate{
    func didCollectionChanged(numberOfImages: Int) {
        self.numberOfImages = numberOfImages
        mainView.collectionView.reloadData()
    }

}
