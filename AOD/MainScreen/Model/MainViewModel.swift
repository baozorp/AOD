//
//  MainViewModel.swift
//  AOD
//
//  Created by Михаил Шекунов on 09.04.2023.
//

import UIKit
import CoreData

protocol MainViewModelDelegate{
    func didCollectionChanged(numberOfImages: Int)
}

class MainViewModel: NSObject {

    private var sizeOfCell: CGFloat
    
    private var delegate: MainViewModelDelegate
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fetchedResultsController: NSFetchedResultsController<Item>
    
    init(sizeOfCell: CGFloat, delegate: MainViewModelDelegate) {
        self.sizeOfCell = sizeOfCell
        self.fetchedResultsController = NSFetchedResultsController()
        self.delegate = delegate
        super.init()
        firstStartChecker()
        self.delegate.didCollectionChanged(numberOfImages: countImagesInCoreData())
        self.fetchedResultsController = createNSFetchRequestResultsController()
    }
    
    private func createNSFetchRequestResultsController() -> NSFetchedResultsController<Item>{
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "wasChosen", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
          try fetchedResultsController.performFetch()
        } catch {
          print("Error fetching data: \(error)")
        }
        return fetchedResultsController
    }
    
    private func countImagesInCoreData() -> Int{
        let fetchRequest = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "wasChosen == %@", argumentArray: [true])
        do {
            let numberOfImages = try context.count(for: fetchRequest)
            return numberOfImages
        } catch let error as NSError {
            print(error.localizedDescription)
            return 0
        }

    }
    
    
    // Mark - First start checker
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
            let newSize = CGSize(width: sizeOfCell, height: sizeOfCell)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {return}
            UIGraphicsEndImageContext()
            let item = Item(context: context)
            item.image = newImage.pngData()
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


extension MainViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate.didCollectionChanged(numberOfImages: countImagesInCoreData())
    }
}
