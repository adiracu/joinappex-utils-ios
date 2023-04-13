import Foundation

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
            guard let box = secureBoxes[key] as? Box<Keys> else {
                let box = Box<Keys>(key: key, type: type, storeService: InsecureStoreService())
                secureBoxes[key] = box
                return box
            }
            return box
        }
    }
}

extension Box {
    public static func load(type: BoxType) -> Box {
        BoxManager.shared.box(keysType: Key.self, key: String(describing: Key.self), type: type)
    }

    public static func load(boxKey: String, type: BoxType) -> Box {
        BoxManager.shared.box(keysType: Key.self, key: boxKey, type: type)
    }
}
