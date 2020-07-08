import Foundation

/// Represents a food product.
public struct Food: Hashable {
    /// The name of this food product.
    public var name: String?
    /// The quantity associated to this food product.
    public var quantity: Quantity?
    /// A list of food types to which this product may belong. The list is sorted in ascending order proportionally to the likelihood of the food belonging to a given type.
    public var types: [String]?
    /// A small image representing this food product.
    public var image: Data?
    /// A barcode identifying this product.
    public var barcode: String
    /// The broad category of this product (e.g. meats, diaries etc.).
    public var category: Category?
    
    public init(barcode: String, name: String? = nil,
                quantity: Quantity? = nil, types: [String]? = nil,
                image: Data? = nil, category: Category? = nil) {
        self.barcode = barcode
        self.name = name
        self.quantity = quantity
        self.types = types
        self.image = image
        self.category = category
    }
}

extension Food {
    /// Represents a numerical quantity with an associated unit, specifically for food. Units can be either mass or volume units.
    public struct Quantity: Hashable {
        /// A mapping of lowercase symbols to their units.
        public static let SUPPORTED_UNITS: Dictionary<String, Unit> = ["g": UnitMass.grams,
                                                                       "kg": UnitMass.kilograms,
                                                                       "lb": UnitMass.pounds,
                                                                       "oz": UnitMass.ounces,
                                                                       "l": UnitVolume.liters,
                                                                       "dl": UnitVolume.deciliters,
                                                                       "cl": UnitVolume.centiliters,
                                                                       "ml": UnitVolume.milliliters]
        /// The numeric value of the quantity.
        public private(set) var value: Double
        /// The mass or volume unit of this food quantity.
        public private(set) var unit: Unit
        
        /// Initializes a food quantity from a numeric value and a unit. If the unit is not supported, nil is returned.
        public init?(value: Double, unit: String) {
            let unitLow = unit.lowercased()
            guard let unitFinal = Quantity.SUPPORTED_UNITS[unitLow] else { return nil }
            self.value = value
            self.unit = unitFinal
        }
        
        /// Initializes a food quantity from a numeric value and a unit.
        public init(value: Double, unit: Unit) {
            self.value = value
            self.unit = unit
        }
    }
}

extension Food {
    /// Represents the set of broad categories to which a food type may belong.
    public enum Category: String {
        /// For vegetables and derived products.
        case vegetablesAndDerived = "vegetables and derived"
        /// For fruits.
        case fruits = "fruits"
        /// For legumes.
        case legumes = "legumes"
        /// For animal meats, without including seafood.
        case meats = "meats"
        /// For seafood.
        case seafood = "seafood"
        /// For dairies (i.e. milk-derived products) and eggs.
        case dairiesAndEggs = "dairies and eggs"
        /// For products containing a high quantity of carbohydrates (e.g. desserts, pasta, rice etc.)
        case carbohydrates = "carbohydrates"
        /// For beverages.
        case beverages = "beverages"
        /// For any product which is not clearly classified by the other enumerations.
        case others = "others"
    }
}
