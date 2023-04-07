//
//  SelectionViewController.swift
//  AOD
//
//  Created by Михаил Шекунов on 15.03.2023.
//

import UIKit
import CoreData
import PhotosUI
import UniformTypeIdentifiers


class SelectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var allImages: [Item] = []
    private var imagesForRemove: [Item] = []
    private var lastChosenElement: Int!
    private var isDeleting = false
    
    var context: NSManagedObjectContext!
    var AODCollectionViewHeight: CGFloat = 0.0
    
    private var cancelButtonItem = UIBarButtonItem()
    private var doneButtonItem = UIBarButtonItem()
    private var okButtonItem = UIBarButtonItem()
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        getImagesFromCoreData()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allImages.endIndex
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectionImageCell", for: indexPath) as! SelectionImageCell
        cell.isDeleting = self.isDeleting
        // Add async to get rid of lags in collectionView
        let operationQueue = OperationQueue()
        operationQueue.addOperation {
            let AODImage = self.allImages[indexPath.row]
            cell.image = AODImage
            OperationQueue.main.addOperation {
                cell.pictureView.layer.cornerRadius = 25

                if let image = AODImage.image{
                    cell.pictureView.image = UIImage(data: image)
                }
                if self.imagesForRemove.contains(cell.image!){
                    cell.animateDeleter()
                }
                else{
                    cell.animateDeleter(isCollectionViewReloadData: true)
                }
               
                
            }
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !isDeleting{
            choseElementToDisplay(indexPath: indexPath)
        }
        else{
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? SelectionImageCell else { return }
            let feedback = UIImpactFeedbackGenerator(style: .rigid)
            feedback.prepare()
            feedback.impactOccurred()
            cell.animateDeleter()
            guard let image = cell.image else {return}
            imagesForRemove.append(image)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if !isDeleting{
            choseElementToDisplay(indexPath: indexPath)
        }
        else{
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? SelectionImageCell else { return }
            UISelectionFeedbackGenerator().selectionChanged()
            cell.animateDeleter()
            guard let image = cell.image else {return}
            guard let index = imagesForRemove.firstIndex(of: image) else{return}
            imagesForRemove.remove(at: index)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SelectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 4, height: collectionView.frame.width / 4)
    }
}

// Mark: - CoreData

extension SelectionViewController{
    
    private func getImagesFromCoreData() {
        
        let fetchRequestChosen = Item.fetchRequest()
        fetchRequestChosen.predicate = NSPredicate(format: "wasChosen == %@", argumentArray: [true])
        
        let fetchRequestAll = Item.fetchRequest()
        fetchRequestAll.predicate = NSPredicate(format: "image != nil")
        
        do {
            lastChosenElement = try context.count(for: fetchRequestChosen) - 1
            let requestAll = try context.fetch(fetchRequestAll)
            if !requestAll.isEmpty{
                allImages = requestAll.sorted { $0.indexPathRow < $1.indexPathRow }
            }
        }catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func saveContext(){
        do{
            try context.save()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
}

// Mark - Actions

extension SelectionViewController{
    
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        guard !isDeleting else {return}
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: collectionView)
            if collectionView.indexPathForItem(at: point) != nil {
                isDeleting = true
                for i in 0...allImages.count-1{
                    guard let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? SelectionImageCell else{continue}
                    cell.isDeleting = true
                    cell.shakeCell()
                    cell.animateChecker(isWasSelected: true)
                }
                reverseVisibleNavButtons()
            }
        }
    }
    
    // Cancel button action
    
    @objc private func cancelButtonTapped() {
        
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.prepare()
        feedback.impactOccurred()
        
        self.isDeleting = false
        
        // Denimating shaking, animating checkers and deleters
        
        for i in 0...allImages.count-1{
            guard let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? SelectionImageCell else{continue}
            cell.isDeleting = self.isDeleting
            cell.shakeCell()
            cell.animateChecker(isWasSelected: false)
            guard let image = cell.image else {continue}
            cell.isSelected = false
            if imagesForRemove.contains(image){
                cell.animateDeleter()
            }
        }
        for i in imagesForRemove{
            imagesForRemove.remove(at: imagesForRemove.firstIndex(of: i)!)
        }
        
        reverseVisibleNavButtons()
    }
    
    // "Ok" button action
    
    @objc private func doneButtonTapped(){
        
        guard let selectedItemsIndexes = collectionView.indexPathsForSelectedItems else {return}
        
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.prepare()
        feedback.impactOccurred()
        
        self.isDeleting = false
        
        for i in imagesForRemove{
            allImages.remove(at: allImages.firstIndex(of: i)!)
            imagesForRemove.remove(at: imagesForRemove.firstIndex(of: i)!)
            if i.wasChosen{
                lastChosenElement -= lastChosenElement == -1 ? 0 : 1
               
            }
            context.delete(i)
        }
        collectionView.deleteItems(at: selectedItemsIndexes)
        
        
        // Denimating shaking, animating checkers and deleters
        for i in -1...allImages.count{
            guard let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? SelectionImageCell else{continue}
            cell.isDeleting = self.isDeleting
            cell.shakeCell()
            cell.animateChecker(isWasSelected: false)
            guard let image = cell.image else {continue}
            if imagesForRemove.contains(image){
                cell.animateDeleter()
            }
        }
        for i in 0..<allImages.count{
            self.allImages[i].indexPathRow = Int16(i)
        }

        self.saveContext()
        reverseVisibleNavButtons()
    }
    
    
    private func choseElementToDisplay(indexPath: IndexPath){
        UISelectionFeedbackGenerator().selectionChanged()
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? SelectionImageCell else { return }
        guard let image = cell.image else { return }
        cell.isSelected = false
        var selectToRow: Int
        if image.wasChosen{
            selectToRow = lastChosenElement
            lastChosenElement -= 1
        }
        else{
            lastChosenElement += self.allImages.count != lastChosenElement ? 1 : 0
            selectToRow = lastChosenElement
        }
        
        // Updating CoreData
        image.wasChosen = !image.wasChosen
        self.allImages.remove(at: allImages.firstIndex(of: image)!)
        self.allImages.insert(image, at: selectToRow)
        for i in 0 ..< self.allImages.count {
            self.allImages[i].indexPathRow = Int16(i)
        }
        self.saveContext()
            
        self.collectionView.moveItem(at: indexPath, to: [indexPath.startIndex, selectToRow])
        self.collectionView.reloadData()
        cell.animateChecker(isWasSelected: true)
    }
    
    private func reverseVisibleNavButtons(){
        let okAnimation = UIViewPropertyAnimator(duration: 0.1, curve: .linear)
        let cancelDoneAnimation = UIViewPropertyAnimator(duration: 0.1, curve: .linear)
        var okWasAnimated = false
        var cancelDoneWasAnimated = false
        
        okAnimation.addAnimations {[unowned self] in
            guard let isHidden = navigationItem.rightBarButtonItem?.isHidden else {return}

            if isHidden{
                navigationItem.rightBarButtonItem?.isHidden = false
                navigationItem.rightBarButtonItem?.customView?.alpha = 1.0
            }
            else{
                navigationItem.rightBarButtonItem?.customView?.alpha = 0.0
            }
            okWasAnimated = true
        }
        okAnimation.addCompletion({[unowned self] _ in
            guard !cancelDoneWasAnimated else {return}
            if navigationItem.rightBarButtonItem?.customView?.alpha == 0.0{
                
                navigationItem.leftBarButtonItem = cancelButtonItem
                navigationItem.rightBarButtonItem = doneButtonItem
                
                navigationItem.leftBarButtonItem?.isHidden = true
                navigationItem.rightBarButtonItem?.isHidden = true

            }
            cancelDoneAnimation.startAnimation()
        })
        
        cancelDoneAnimation.addAnimations {[unowned self] in
            guard let isHidden = navigationItem.leftBarButtonItem?.isHidden else {return}
            if isHidden{
                navigationItem.leftBarButtonItem?.isHidden = false
                navigationItem.rightBarButtonItem?.isHidden = false
                navigationItem.leftBarButtonItem?.customView?.alpha = 1.0
                navigationItem.rightBarButtonItem?.customView?.alpha = 1.0
            }
            else{
                navigationItem.leftBarButtonItem?.customView?.alpha = 0.0
                navigationItem.rightBarButtonItem?.customView?.alpha = 0.0
            }
            cancelDoneWasAnimated = true
        }
        cancelDoneAnimation.addCompletion({[unowned self] _ in
            if navigationItem.leftBarButtonItem?.customView?.alpha == 0.0{
                navigationItem.leftBarButtonItem?.isHidden = true
                navigationItem.rightBarButtonItem = okButtonItem
                navigationItem.rightBarButtonItem?.isHidden = true
            }
            guard !okWasAnimated else {return}
            okAnimation.startAnimation()
        })
        
        if navigationItem.rightBarButtonItem! == okButtonItem{
            okAnimation.startAnimation()
        }
        else{
            cancelDoneAnimation.startAnimation()
        }
    }
}

// Mark - Configurations

extension SelectionViewController{
    
    private func configureNavigationBar() {
        
        self.title = "Выберите изображения"
        
        let buttonColor = UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1.0)
        
        navigationController?.navigationBar.backgroundColor = .darkGray
        navigationController?.navigationBar.barTintColor = .darkGray
        
        // Cancel, done, ok buttons settings
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.setTitleColor(buttonColor, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButtonItem =  UIBarButtonItem(customView: cancelButton)
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.leftBarButtonItem?.customView?.alpha = 0.0
        navigationItem.leftBarButtonItem?.isHidden = true

        let doneButton = UIButton(type: .custom)
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(buttonColor, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButtonItem =  UIBarButtonItem(customView: doneButton)
        
        let okButton = UIButton(type: .custom)
        okButton.setTitle("⊕", for: .normal)
        okButton.sizeToFit()
        okButton.setTitleColor(buttonColor, for: .normal)
        okButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        okButton.addTarget(self, action: #selector(pickImages), for: .touchUpInside)
        okButtonItem =  UIBarButtonItem(customView: okButton)
        navigationItem.rightBarButtonItem = okButtonItem
        navigationItem.rightBarButtonItem?.customView?.alpha = 1.0
        navigationItem.rightBarButtonItem?.isHidden = false
        
    }
    
    private func configureCollectionView() {

        collectionView.backgroundColor = .darkGray
        collectionView.register(SelectionImageCell.self, forCellWithReuseIdentifier: "selectionImageCell")
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 1
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.allowsMultipleSelection = true
        let layout = UICollectionViewFlowLayout()
        let inset: CGFloat = view.frame.width/20 // значение отступа
        layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        collectionView.collectionViewLayout = layout
    }
}

// Mark - PHPicker

extension SelectionViewController: PHPickerViewControllerDelegate, SelectionViewControllerDelegate{
    
    @objc private func pickImages(_ sender: Any) {
        
        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.prepare()
        feedback.impactOccurred()
        
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 10
        
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.overrideUserInterfaceStyle = .dark
        
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let phPicker = PHPicker(self)
        phPicker.getImage(results, AODCollectionViewHeight)
        dismiss(animated: true, completion: nil)
    }

    func imagesWasLoaded(_ newItemsArray: [UIImage]) {
        var indexPathes = [IndexPath]()
        for newItem in newItemsArray{
            lastChosenElement += 1
            let item = Item(context: context)
            item.image = newItem.pngData()
            item.wasChosen = true
            item.indexPathRow = Int16(lastChosenElement)
            allImages.insert(item, at: lastChosenElement)
            saveContext()
            indexPathes.append(IndexPath(row: lastChosenElement, section: 0))
        }
        
        collectionView.insertItems(at: indexPathes)
    }
}
