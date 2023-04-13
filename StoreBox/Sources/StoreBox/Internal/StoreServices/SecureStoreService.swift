import Foundation
import Security

class SecureStoreService: StoreService {
    private func error(from status: OSStatus) -> SecureStoreServiceError {
        let message = NSLocalizedString("Unhandled Error: \(status)", comment: "")
        return SecureStoreServiceError.unhandledError(message: message)
    }
    
    func save(value: Data, forKey key: String) throws {
        var query: [String: Any ] = [String(kSecClass): kSecClassGenericPassword,
                                     String(kSecAttrAccount) : key]
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        
        switch status {
        case errSecSuccess:
            let attributesToUpdate: [String: Any ] = [String(kSecValueData): value]
            status = SecItemUpdate(query as CFDictionary,
                                   attributesToUpdate as CFDictionary)
            if status != errSecSuccess {
                throw error(from: status)
            }
        case errSecItemNotFound:
            query[String(kSecValueData)] = value
            status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                throw error(from: status)
            }
        default:
            throw error(from: status)
        }
    }
    
    func load(forKey key: String) throws -> Data {
        let query: [String: Any ] = [String(kSecMatchLimit): kSecMatchLimitOne,
                                     String(kSecReturnAttributes): true,
                                     String(kSecReturnData): true,
                                     String(kSecClass): kSecClassGenericPassword,
                                     String(kSecAttrAccount): key]
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }

        switch status {
        case errSecSuccess:
            guard
                let queriedItem = queryResult as? [String: Any],
                let valueData = queriedItem[String(kSecValueData)] as? Data else {
                throw SecureStoreServiceError.unhandledError(message: "Cant't load value.")
            }
            return valueData
        case errSecItemNotFound:
            throw SecureStoreServiceError.valueNotFoundError
        default:
            throw error(from: status)
        }
    }
    
    func remove(forKey key: String) throws {
        let query: [String: Any] = [String(kSecClass): kSecClassGenericPassword,
                                     String(kSecAttrAccount): key]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw error(from: status)
        }
    }

}

extension SecureStoreService {
    enum SecureStoreServiceError: Error, LocalizedError {
        case valueNotFoundError
        case unhandledError(message: String)
        
        var errorDescription: String? {
            switch self {
            case .valueNotFoundError:
                return NSLocalizedString("Value not found Error.", comment: "")
            case .unhandledError(let message):
                return NSLocalizedString(message, comment: "")
            }
        }
    }
}
