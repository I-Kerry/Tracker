

import Foundation

final class CategoryViewModel {
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private var categories: [TrackerCategory] = [] {
        didSet {
            categoriesBinding?(categories)
        }
    }
    
    var selectedIndex: Int?
    
    var numberOfCategories: Int {
        categories.count
    }
    
    var isEmpty: Bool { categories.isEmpty }

    var categoriesBinding: Binding<[TrackerCategory]>? {
        didSet {
            categoriesBinding?(categories)
        }
    }
    
    func loadCategories() {
        categories = trackerCategoryStore.fetchCategories()
    }
    
    func addCategory(title: String) {
        trackerCategoryStore.addCategory(title: title)
        loadCategories()
    }
    
    func category(at index: Int) -> TrackerCategory {
        categories[index]
    }
    
    func deleteCategory(at index: Int) {
        trackerCategoryStore.deleteCategory(at: index)
        loadCategories()
    }
    
    func updateCategory(at index: Int, newTitle: String) {
        trackerCategoryStore.updateCategory(at: index, newTitle: newTitle)
        loadCategories()
    }
}
