//func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
//    
//    let operationQueue = OperationQueue()
//    operationQueue.addOperation {
//        let fetchRequest = Image.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "indexPathRow == %@", argumentArray: [Int16(indexPath.row)])
//        var fetchedImages: Image?
//        do {
//            fetchedImages = try self.context.fetch(fetchRequest).first!
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
//        OperationQueue.main.addOperation {
//            cell.pictureView.image = UIImage(data: (fetchedImages!.picture)!)
//        }
//    }
//    
//    if imageArray.count == 0{
//        cell.pictureView.tintColor = .darkGray
//        cell.pictureView.image = UIImage(systemName: "nosign")
//    }
//
//    
//    return cell
//}
