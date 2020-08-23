import Foundation

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
