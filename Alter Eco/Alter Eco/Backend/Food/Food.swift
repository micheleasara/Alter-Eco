import Foundation

/// Represents a food product.
public class Food: Hashable, ObservableObject {
    /// The name of this food product.
    public var name: String?
    /// The quantity associated to this food product.
    @Published public var quantity: Quantity?
    /// A list of food types to which this product may belong. The list is sorted in ascending order proportionally to the likelihood of the food belonging to a given type.
    @Published public private(set) var types: [String]?
    /// A small image representing this food product.
    public var image: Data?
    /// A barcode identifying this product.
    public let barcode: String
    /// The broad category (e.g. meats, diaries etc.) calculated from the first type in the list of possible types.
    public var category: Category? {
        return FoodToCarbonManager.foodTypesInfo[types?.first ?? ""]?.category
    }
    
    public init(barcode: String, name: String? = nil,
                quantity: Quantity? = nil, types: [String]? = nil,
                image: Data? = nil) {
        self.barcode = barcode
        self.name = name
        self.quantity = quantity
        self.types = types
        self.image = image
    }
    
    /// Sets the given type as the most likely for this food product. If the type does not already exist, it is inserted in the list.
    public func setAsMostLikelyType(_ type: String) {
        if var types = types {
            types = types.filter{ $0 != type }
            types.insert(type, at: 0)
            self.types = types
        } else {
            types = [type]
        }
    }
    
    public static func == (lhs: Food, rhs: Food) -> Bool {
        return lhs.name == rhs.name &&
            lhs.quantity == rhs.quantity &&
            lhs.types == rhs.types &&
            lhs.barcode == rhs.barcode &&
            lhs.image == rhs.image
    }
    
    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self).hashValue)
    }
}

extension Food {
    /// Represents a numerical quantity with an associated unit, specifically for food. Units can be either mass or volume units.
    public struct Quantity: Hashable, CustomStringConvertible {
        /// A mapping of lowercase symbols to their units.
        public static let SUPPORTED_UNITS: Dictionary<String, Unit> = ["g": UnitMass.grams,
                                                                       "kg": UnitMass.kilograms,
                                                                       "lb": UnitMass.pounds,
                                                                       "oz": UnitMass.ounces,
                                                                       "l": UnitVolume.liters,
                                                                       "dl": UnitVolume.deciliters,
                                                                       "cl": UnitVolume.centiliters,
                                                                    "ml": UnitVolume.milliliters]
        /// String representation in the format "value unit-symbol". The value is printed up to two decimal places and only if needed.
        public var description: String {
            return String(format: "%g %@", (value / 0.01).rounded() * 0.01, unit.symbol)
        }
        
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
        
        public init?(quantity: String) {
            // match a number optionally separated by whitespaces and terminated with a unit of max 3 chars
            let regex = try! NSRegularExpression(pattern: #"(?<value>[0-9]+(?:[.,,][0-9]+)?)\s*(?<unit>[A-z]{1,3})"#, options: [])
            let nsrange = NSRange(quantity.startIndex..<quantity.endIndex, in: quantity)
            guard let match = regex.firstMatch(in: quantity, options: [], range: nsrange) else { return nil }
            
            // ensure both named groups are found
            let nsRangeVal = match.range(withName: "value")
            let nsRangeUnit = match.range(withName: "unit")
            guard nsRangeVal.location != NSNotFound && nsRangeUnit.location != NSNotFound,
                let rangeVal = Range(nsRangeVal, in: quantity),
                let rangeUnit = Range(nsRangeUnit, in: quantity) else { return nil }
            
            // perform a final check for the validity of the parsed strings
            guard let valueNum = Double(String(quantity[rangeVal])) else { return nil }
            self.init(value: valueNum, unit: String(quantity[rangeUnit]))
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
