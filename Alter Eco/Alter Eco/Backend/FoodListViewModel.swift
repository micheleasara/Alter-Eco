import SwiftUI

public class FoodListViewModel: ObservableObject {
    @Published public var totalCarbon: Measurement<UnitMass>!
    // private setters as the logic for what is considered categorised
    // and what isn't should be concentrated within this class only
    @Published private(set) public var categorised: [Food]!
    @Published private(set) public var notInDatabase: [Food]!
    @Published private(set) public var uncategorised: [Food]!
    private let converter = FoodToCarbonConverter()
    
    public init(foods: [Food] = [], notFound: [Food] = []) {
        update(foods: foods, notFound: notFound)
    }
    
    public func getCarbon(forFood food: Food) -> Measurement<UnitMass>? {
        return converter.getCarbon(fromFood: food)
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
        
        totalCarbon = getTotalCarbon()
    }
    
    // apply law of demeter
    
    public func removeFromCategorised(at index: Int) {
        categorised.remove(at: index)
    }
    
    public func removeFromUncategorised(at index: Int) {
        uncategorised.remove(at: index)
    }
    
    public func removeFromNotInDatabase(at index: Int) {
        notInDatabase.remove(at: index)
    }
    
    private func getTotalCarbon() -> Measurement<UnitMass> {
        let zeroKg = Measurement<UnitMass>(value: 0, unit: UnitMass.kilograms)
        var total = zeroKg
        for food in categorised {
            total = total + (converter.getCarbon(fromFood: food) ?? zeroKg)
        }
        return total
    }
}
