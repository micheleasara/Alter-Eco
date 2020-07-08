import Foundation
import NaturalLanguage

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
        request.setValue("close", forHTTPHeaderField: "Connection")
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
            // convert keywords into matching food types for which a carbon value is available
            let matchingTypes = foodCarbonConverter.keywordsToTypes(keywords)
            
            // TODO: - change Food contructor's category with categories or join types and categories
            
            if let imageLocation = product.imageFrontSmallUrl, let URL = URL(string: imageLocation) {
                var request = URLRequest(url: URL)
                request.setValue(USER_AGENT, forHTTPHeaderField: "Authorization")
                request.setValue("close", forHTTPHeaderField: "Connection")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else { return }
                    let food = Food(barcode: barcode, name: product.productName,
                                    quantity: self.parseQuantity(product.quantity), types: matchingTypes,
                                    image: data, category: FoodToCarbonConverter.foodTypesInfo[matchingTypes?.first ?? ""]?.category)
                    self.completionHandler(food, nil)
                }
                
                task.resume()
            } else {
                let food = Food(barcode: barcode, name: product.productName,
                                quantity: self.parseQuantity(product.quantity), types: matchingTypes, category: FoodToCarbonConverter.foodTypesInfo[matchingTypes?.first ?? ""]?.category)
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
