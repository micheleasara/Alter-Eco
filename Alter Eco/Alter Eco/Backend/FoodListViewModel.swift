import SwiftUI

public class FoodListViewModel: ObservableObject {
    @Published private(set) public var categorised: [Food]!
    @Published private(set) public var notInDatabase: [Food]!
    @Published private(set) public var uncategorised: [Food]!
    
    public init(foods: [Food] = [], notFound: [Food] = []) {
        update(foods: foods, notFound: notFound)
    }
    
    public var count: Int {
        return categorised.count + notInDatabase.count + uncategorised.count
    }
    
    public func update(foods: [Food], notFound: [Food]) {
        var categorised: [Food] = []
        var uncategorised: [Food] = []
        for food in foods {
            if food.categories?.isEmpty ?? true {
                uncategorised.append(food)
           } else {
                categorised.append(food)
           }
        }
        self.categorised = categorised
        self.uncategorised = uncategorised
        self.notInDatabase = notFound
    }
}
