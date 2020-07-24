import Foundation
import NaturalLanguage

/// Represents an entity to retrieve food information from a remote server.
public protocol RemoteFoodRetriever {
    /**
     Asynchronously retrieves food information given a barcode.  When finished, the results are passed to a callback function.
     - Parameter barcode: the barcode identifying a food product.
     - Parameter completionHandler: the function which is called when the retrieval has ended.
     - Parameter food: the food item retrieved. It will be nil in case of failure.
     - Parameter error: in case of failure, RemoteFoodRetrievalError will contain information about the error. Otherwise it is nil.
     */
    func fetchFood(barcode: String, completionHandler: @escaping (_ food: Food?, _ error: RemoteFoodRetrievalError?) -> Void)
}

/// Represents an entity to upload food information to a remote server.
public protocol RemoteFoodUploader {
    /**
     Uploads  a food product into the remote server.
     - Parameter food: the food object containing the information to upload.
     */
    func upload(food: Food, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

public class OpenFoodFacts: RemoteFoodRetriever, RemoteFoodUploader {
    /// Range of HTTP codes signifying a successful response.
    private let HTTPSuccessCodes = 200...299
    /// String specifying the user agent for an HTTP request.
    private let userAgent = "User-Agent: Alter Eco - iOS"
    /// Address of the OpenFoodFacts API for retrieval. Should be terminated with a string representing a numeric barocode and a json extension.
    private let APIRetrievalBaseAddress = "https://world.openfoodfacts.org/api/v0/product/"
    /// Termination of the OpenFoodFacts API for retrieval. Contains a json extension and the fields of interest.
    private let APIRetrievalExtensionAndFields = ".json?fields=product_name,categories_tags,quantity,image_front_small_url"
    /// Address of the OpenFoodFacts API for upload. Should be terminated with a barcode and the fields to upload.
    private let APIUploadBaseAddress = "https://world.openfoodfacts.org/cgi/product_jqm2.pl?code="

    private let foodCarbonConverter = FoodToCarbonConverter()
    /// Contains words which are filtered out during preprocessing.
    private let STOPWORDS = Set(["a", "the", "and", "or", "nor", "neither", "product", "products", "food", "foods",
    "tree", "based", "their", "beverage", "beverages", "grocery", "groceries", "with"])

    private var foodRetrievedHandler: (Food?, RemoteFoodRetrievalError?) -> Void = { _,_ in }

    public func upload(food: Food, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let name = food.name?.replacingOccurrences(of: " ", with: "%20") ?? ""
        let quantity = food.quantity?.description.replacingOccurrences(of: " ", with: "%20") ?? ""
        let category = food.types?.first?.replacingOccurrences(of: " ", with: "%20") ?? ""
        let url = URL(string: "https://world.openfoodfacts.org/cgi/product_jqm2.pl?code=" + food.barcode +
        "&user_id=altereco&password=altereco&product_name=" + name + "&quantity=" + quantity + "&categories=" + category)!
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "Authorization")
        request.setValue("close", forHTTPHeaderField: "Connection")
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }

    public func fetchFood(barcode: String, completionHandler: @escaping (Food?, RemoteFoodRetrievalError?) -> Void) {
        self.foodRetrievedHandler = completionHandler
        print("fetching food item " + barcode)
        let url = URL(string: APIRetrievalBaseAddress + barcode + APIRetrievalExtensionAndFields)!
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "Authorization")
        request.setValue("close", forHTTPHeaderField: "Connection")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            self.onHTTPGETCompleted(barcode: barcode, data: data, response: response, error: error) })
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

    private func onHTTPGETCompleted(barcode: String, data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            foodRetrievedHandler(nil, RemoteFoodRetrievalError.network(localizedDescription: error.localizedDescription))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            foodRetrievedHandler(nil, RemoteFoodRetrievalError.httpFailure(localizedDescription: "Invalid server response."))
            return
        }
        
        guard HTTPSuccessCodes.contains(httpResponse.statusCode) else {
            foodRetrievedHandler(nil, RemoteFoodRetrievalError.httpFailure(localizedDescription:
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
                        
            if let imageLocation = product.imageFrontSmallUrl, let URL = URL(string: imageLocation) {
                var request = URLRequest(url: URL)
                request.setValue(userAgent, forHTTPHeaderField: "Authorization")
                request.setValue("close", forHTTPHeaderField: "Connection")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else { return }
                    let food = Food(barcode: barcode, name: product.productName,
                                    quantity: Food.Quantity(quantity: product.quantity ?? ""), types: matchingTypes,
                                    image: data)
                    self.foodRetrievedHandler(food, nil)
                }
                
                task.resume()
            } else {
                let food = Food(barcode: barcode, name: product.productName,
                                quantity: Food.Quantity(quantity: product.quantity ?? ""), types: matchingTypes)
                self.foodRetrievedHandler(food, nil)
            }
            
        } else {
            foodRetrievedHandler(nil, RemoteFoodRetrievalError.foodNotFound(barcode: barcode))
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
}

/// Enumeration of possible errors which can occur when retrieving food from a remote database.
public enum RemoteFoodRetrievalError: LocalizedError {
    /// A generic network error with a description.
    case network(localizedDescription: String)
    /// An error related specifically to a failed HTTP request, with a description.
    case httpFailure(localizedDescription: String)
    /// An error signifying the food item requested was not found in the database.
    case foodNotFound(barcode: String)
    
    /// A string description associated with this error.
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
