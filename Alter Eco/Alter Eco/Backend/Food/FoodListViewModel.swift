import SwiftUI

public class FoodListViewModel: ObservableObject {
    /// Defines the default quantity for foods for which the real quantity is unknown.
    public let defaultQuantity = Food.Quantity(value: 100, unit: UnitMass.grams)
    
    // private setters as the logic for what is considered categorised
    // and what isn't should be concentrated within this class only
    /// The food products having at least one type.
    @Published private(set) public var productsWithTypes: [Food]!
    /// The food products that were not found in the database.
    @Published private(set) public var productsNotInDB: [Food]!
    /// The food products which are in the database, but for which no type could be determined.
    @Published private(set) public var typelessProducts: [Food]!
    
    /// Returns the total amount of carbon for the food products with at least one type. Products with no quantity are given a default specified by defaultQuantity.
    public var totalCarbon: Measurement<UnitMass> {
        return converter.getCarbon(fromFoods: replaceNilQuantitiesWithDefault(in: productsWithTypes))
    }
    
    private let converter: FoodToCarbonConverter
    private let uploader: RemoteFoodUploader
    private let DBMS: DBWriter
    
    public init(foods: [Food] = [], notFound: [Food] = [],
                converter: FoodToCarbonConverter,
                uploader: RemoteFoodUploader,
                DBMS: DBWriter) {
        self.DBMS = DBMS
        self.converter = converter
        self.uploader = uploader
        update(foods: foods, notFound: notFound)
    }
    
    /**
     Returns the carbon equivalent for the given food, or nil if not enough information is available.
     - Parameter forFood: food product to use to calculate a carbon equivalent value in kilograms.
     */
    public func getCarbon(forFood food: Food) -> Measurement<UnitMass>? {
        return converter.getCarbon(fromFood: food)
    }
    
    /// Returns whether all food containers are empty.
    public var isEmpty: Bool {
        return productsWithTypes.isEmpty &&
            typelessProducts.isEmpty &&
            productsNotInDB.isEmpty
    }
    
    /**
     Updates the model with the given products and automatically assigns each food item to its corresponding list.
     - Parameter foods: products which were found in the database.
     - Parameter notFound: products which were not found in the database.
     */
    public func update(foods: [Food], notFound: [Food]) {
        var withTypes: [Food] = []
        var typeless: [Food] = []
        for food in foods {
            if isTypeless(food) {
                typeless.append(food)
           } else {
                withTypes.append(food)
           }
        }
        self.productsWithTypes = withTypes
        self.typelessProducts = typeless
        self.productsNotInDB = notFound
    }
    
    /// Updates the model by checking if food products have changed state (e.g. given a type) and puts them in the corresponding group.
    public func update() {
        update(foods: productsWithTypes+typelessProducts, notFound: productsNotInDB)
        productsNotInDB = productsNotInDB.filter {
            if !isTypeless($0) {
                productsWithTypes.append($0)
                return false
            }
            return true
        }
    }
    
    /**
     Removes all instances of food products with the given barcode.
     - Parameter withBarcode: a barcode identifying the food products to be removed.
     */
    public func removeFood(withBarcode barcode: String) {
        let closure: (Food) -> Bool = { $0.barcode != barcode }
        productsWithTypes = productsWithTypes.filter(closure)
        typelessProducts = typelessProducts.filter(closure)
        productsNotInDB = productsNotInDB.filter(closure)
    }
    
    /// Removes a product with at least one type corresponding to the given index.
    public func removeProductWithType(at index: Int) {
        productsWithTypes.remove(at: index)
    }
    
    /// Removes an uncategorised food product corresponding to the given index.
    public func removeTypeless(at index: Int) {
        typelessProducts.remove(at: index)
    }
    
    /// Removes a food product not found in the database and corresponding to the given index.
    public func removeProductNotInDB(at index: Int) {
        productsNotInDB.remove(at: index)
    }
    
    /// Starts an asynchronous request to upload the information contained in the given food product.
    public func uploadProductInfo(food: Food) {
        uploader.upload(food: food, completionHandler: {_,_,_ in })
    }
    
    /// Saves the products with types in the database. Products with no quantity are given a default specified by defaultQuantity.
    public func save() {
        try? DBMS.append(foods: replaceNilQuantitiesWithDefault(in: productsWithTypes), withDate: Date())
    }
    
    private func replaceNilQuantitiesWithDefault(in foods: [Food]) -> [Food] {
        var newFoods: [Food] = []
        for food in foods {
            let quantity = food.quantity ?? defaultQuantity
            let food = Food(barcode: food.barcode, name: food.name, quantity: quantity, types: food.types, image: food.image)
            newFoods.append(food)
        }
        return newFoods
    }
    
    private func isTypeless(_ food: Food) -> Bool {
        return food.types?.isEmpty ?? true
    }
}
