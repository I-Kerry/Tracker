import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateTrackerCategory(_ update: TrackerCategoryStoreUpdate)
}

struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private let colorMarshalling = ColorMarshalling()
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "header", ascending: true)]
        
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
    
    func addNewTrackerCategory(_ trackerCategory: TrackerCategory, with tracker: Tracker) {
        let trackerCategoryCD = TrackerCategoryCoreData(context: context)
        trackerCategoryCD.header = trackerCategory.header
        
        let trackerCD = TrackerCoreData(context: context)
        
//        trackerCategoryCD.trackers =
        
        try? context.save()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        guard let object = fetchedResultsController.fetchedObjects else { return [] }
        var results: [TrackerCategory] = []
        
        for trackerCategoryCD in object {
            let trackerArray = trackerCategoryCD.trackers?.allObjects as? [TrackerCoreData] ?? []
            
            var trackers: [Tracker] = []
            
            for trackerCD in trackerArray {
                let tracker = Tracker(id: trackerCD.id ?? UUID(),
                                      name: trackerCD.name ?? "",
                                      color: colorMarshalling.color(from: trackerCD.color ?? "00000"),
                                      emoji: trackerCD.emoji ?? "",
                                      schedule: (trackerCD.schedule as? [Int])?.compactMap { value in
                    Weekday.allCases.first(where: { $0.numberValue == value })
                } ?? []
                )
                trackers.append(tracker)
            }
            let category = TrackerCategory(header: trackerCategoryCD.header ?? "", trackerArray: trackers)
            results.append(category)
            
        }
        return results
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdateTrackerCategory(TrackerCategoryStoreUpdate(insertedIndexes: insertedIndexes!,
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
