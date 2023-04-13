import Foundation

class InsecureStoreService: StoreService {
    private let defaults = UserDefaults.standard
    
    init() {}
    
    func save(value: Data, forKey key: String) throws {
        defaults.set(value, forKey: key)
    }
    
    func load(forKey key: String) throws -> Data {
        guard let value = defaults.object(forKey: key) as? Data else {
            throw InsecureStoreServiceError.loadValueError
        }
        return value
    }
    
    func remove(forKey key: String) throws {
        defaults.removeObject(forKey: key)
    }
}

extension InsecureStoreService {
    enum InsecureStoreServiceError: Error, LocalizedError {
        case loadValueError
        
        public var errorDescription: String? {
            switch self {
            case .loadValueError:
                return NSLocalizedString("Loading value Error.", comment: "There isn't value for this key")
            }
        }
    }
}
