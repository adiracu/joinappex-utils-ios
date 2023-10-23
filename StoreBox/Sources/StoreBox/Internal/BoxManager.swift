import Foundation

/// Type of ``Box`` Secure level
///
///   - secure: Used to save values in `keychain`
///   - insecure: Used to save values in `UserDefaults`
public enum BoxType {
    case secure
    case insecure
}

class BoxManager {
    static let shared = BoxManager()
    
    private var secureBoxes = [String: any Storage]()
    private var insecureBoxes = [String: any Storage]()
    
    private init() {}
    
    func box<Keys>(keysType: Keys.Type, key: String, type: BoxType) -> Box<Keys> where Keys: BoxKey {
        switch type {
        case .secure:
            guard let box = secureBoxes[key] as? Box<Keys> else {
                let box = Box<Keys>(key: key, type: type, storeService: SecureStoreService())
                secureBoxes[key] = box
                return box
            }
            return box

        case .insecure:
            guard let box = insecureBoxes[key] as? Box<Keys> else {
                let box = Box<Keys>(key: key, type: type, storeService: InsecureStoreService())
                insecureBoxes[key] = box
                return box
            }
            return box
        }
    }
}

extension Box {
    /// Load new or existing Box for specified ``BoxType``
    ///
    /// Describing of your BoxKey used as key to load box: `Box<MyKey>.load(...)`
    /// - Parameters:
    ///   - type: Type of secure level ``BoxType``
    /// - Returns: New or existing Box
    public static func load(type: BoxType) -> Box {
        BoxManager.shared.box(keysType: Key.self, key: String(describing: Key.self), type: type)
    }

    /// Load new or existing Box for specified ``BoxType`` and `boxKey`
    ///
    /// - Parameters:
    ///   - boxKey: Key to load Box from common storage
    ///   - type: Type of secure level ``BoxType``
    /// - Returns: New or existing Box
    public static func load(boxKey: String, type: BoxType) -> Box {
        BoxManager.shared.box(keysType: Key.self, key: boxKey, type: type)
    }
}
