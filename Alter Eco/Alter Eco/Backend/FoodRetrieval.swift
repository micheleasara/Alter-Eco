import Foundation
import NaturalLanguage

/// Represents a food product.
public struct Food: Hashable {
    /// The name of this food product.
    public var name: String?
    /// The quantity associated to this food product.
    public var quantity: Quantity?
    /// A list of categories to which this food product may belong. The categories are sorted in ascending order proportionally the likelihood of the food belonging to a given category.
    public var categories: [String]?
    /// A small image representing this food product.
    public var image: Data?
    /// A barcode identifying this product.
    public var barcode: String
    
    public init(barcode: String, name: String? = nil,
                quantity: Quantity? = nil, categories: [String]? = nil, image: Data? = nil) {
        self.barcode = barcode
        self.name = name
        self.quantity = quantity
        self.categories = categories
        self.image = image
    }
    
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

/// Enumeration of possible errors which can occur when retrieving food from a remote database.
public enum RemoteFoodRetrievalError: LocalizedError {
    /// A generic network error with a description.
    case network(localizedDescription: String)
    /// An error related specifically to a failed HTTP request, with a description.
    case httpFailure(localizedDescription: String)
    /// An error signifying the food item requested was not found in the database.
    case foodNotFound(barcode: String)
    
    public var errorDescription: String? {
        switch self {
        case .network(localizedDescription: let description):
            return description
        case .httpFailure(localizedDescription: let description):
            return description
        case .foodNotFound(barcode: let barcode):
            return barcode
        }
    }
}

/// Represents an entity to retrieve food information from a remote server.
public protocol RemoteFoodRetriever {
    /// Asynchronously retrieves food information given a barcode. When finished, the results are passed to a callback function.
    func fetchFood(barcode: String, completionHandler: @escaping (Food?, RemoteFoodRetrievalError?) -> Void)
}

public class OpenFoodFacts: RemoteFoodRetriever {
    /// Range of HTTP codes signifying a successful response.
    private let HTTP_SUCCESS_CODES = 200...299
    private let USER_AGENT = "User-Agent: Alter Eco - iOS"
    /// Address of the OpenFoodFacts API. Should be terminated with a string representing a numeric barocode and a json extension.
    private let API_BASE_ADDRESS = "https://world.openfoodfacts.org/api/v0/product/"
    /// Termination of the OpenFoodFacts API. Contains a json extension and the fields of interest.
    private let API_EXTENSION_AND_FIELDS = ".json?fields=product_name,categories_tags,quantity,image_front_small_url"
    
    private let foodCarbonConverter = FoodToCarbonConverter()
    /// Contains words which are filtered out during preprocessing.
    private let STOPWORDS = Set(["a", "the", "and", "or", "nor", "neither", "product", "products", "food", "foods",
    "tree", "based", "their", "beverage", "beverages", "grocery", "groceries", "with"])
    
    private var completionHandler: (Food?, RemoteFoodRetrievalError?) -> Void = { _,_ in }
    
    public func fetchFood(barcode: String, completionHandler: @escaping (Food?, RemoteFoodRetrievalError?) -> Void) {
        self.completionHandler = completionHandler
        print("fetching food item " + barcode)
        let url = URL(string: API_BASE_ADDRESS + barcode + API_EXTENSION_AND_FIELDS)!
        var request = URLRequest(url: url)
        request.setValue(USER_AGENT, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            self.onHTTPRequestCompleted(barcode: barcode, data: data, response: response, error: error) })
        task.resume()
    }
    
    /// Contains OpenFoodFacts information about a product.
    public struct Product: Hashable, Decodable {
        public var productName: String?
        public var categoriesTags: [String]?
        public var quantity: String?
        public var imageFrontSmallUrl: String?
    }

    /// Represents a server response from OpenFoodFacts.
    public struct Response: Decodable {
        public var statusVerbose: String?
        public var product: Product?
        public var code: String?
        public var status: Int?
    }
    
    private func onHTTPRequestCompleted(barcode: String, data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            completionHandler(nil, RemoteFoodRetrievalError.network(localizedDescription: error.localizedDescription))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completionHandler(nil, RemoteFoodRetrievalError.httpFailure(localizedDescription: "Invalid server response."))
            return
        }
        
        guard HTTP_SUCCESS_CODES.contains(httpResponse.statusCode) else {
            completionHandler(nil, RemoteFoodRetrievalError.httpFailure(localizedDescription:
                "Unexpected server response with code \(httpResponse.statusCode). Try again later."))
                return
        }

        if let data = data {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let foodResponse = try? decoder.decode(OpenFoodFacts.Response.self, from: data)
            onFoodRetrieval(barcode: barcode, product: foodResponse?.product)
        }
    }
    
    private func onFoodRetrieval(barcode: String, product: OpenFoodFacts.Product?) {
        if let product = product {
            // preprocess OpenFoodFacts categories to extract the most important keywords
            let keywords = getKeywords(categories: product.categoriesTags ?? [])
            // convert keywords into matching food categories for which a carbon value is available
            let matchingCategories = foodCarbonConverter.keywordsToCategories(keywords)
            
            if let imageLocation = product.imageFrontSmallUrl, let URL = URL(string: imageLocation) {
                let task = URLSession.shared.dataTask(with: URL) { data, response, error in
                    guard let data = data, error == nil else { return }
                    let food = Food(barcode: barcode, name: product.productName,
                                    quantity: self.parseQuantity(product.quantity), categories: matchingCategories,
                                    image: data)
                    self.completionHandler(food, nil)
                }
                task.resume()
            } else {
                let food = Food(barcode: barcode, name: product.productName,
                                quantity: self.parseQuantity(product.quantity), categories: matchingCategories)
                self.completionHandler(food, nil)
            }
            
        } else {
            completionHandler(nil, RemoteFoodRetrievalError.foodNotFound(barcode: barcode))
        }
    }
    
    /// Returns unique keywords from OpenFoodFacts category tags.
    private func getKeywords(categories: [String]) -> [String] {
        var words: [String] = []
        for category in categories {
            words += category.replacingOccurrences(of: "en:", with: "").components(separatedBy: "-")
        }
        words = Array(Set(words)) // remove duplicates (order not maintained)
        words = words.filter { !STOPWORDS.contains($0) }
        return words
    }
    
    private func parseQuantity(_ quantity: String?) -> Food.Quantity? {
        guard let quantity = quantity else { return nil }
        
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
        return filterUnsupportedMeasurements(value: String(quantity[rangeVal]), unit: String(quantity[rangeUnit]))
    }
    
    private func filterUnsupportedMeasurements(value: String, unit: String) -> Food.Quantity? {
        guard let valueNum = Double(value) else { return nil }
        // unsupported units are taken care of by the Food.Quantity initializer
        return Food.Quantity(value: valueNum, unit: unit)
    }
}
