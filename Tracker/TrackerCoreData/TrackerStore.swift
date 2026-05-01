
import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrakerStore(_ update: TrackerStoreUpdate)
}

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private let colorMarshalling = ColorMarshalling()
    
    weak var delegate: TrackerStoreDelegate?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    func addNewTracker(_ tracker: Tracker, with categoryHeader: String) throws {
        let trackerCD = TrackerCoreData(context: context)
        trackerCD.color = colorMarshalling.hexString(from: tracker.color)
        trackerCD.emoji = tracker.emoji
        trackerCD.id = tracker.id
        trackerCD.name = tracker.name
        trackerCD.schedule = tracker.schedule.map { $0.numberValue } as NSArray
        
        let categoryRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        categoryRequest.predicate = NSPredicate(format: "header == %@", categoryHeader)
        let fetched = try? context.fetch(categoryRequest)
        let categoryCD: TrackerCategoryCoreData = fetched?.first ?? {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.header = categoryHeader
            return newCategory
        }()
        
        categoryCD.addToTrackers(trackerCD)
        
        try context.save()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdateTrakerStore(TrackerStoreUpdate(insertedIndexes: insertedIndexes!,
                                                          deletedIndexes: deletedIndexes!)
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
