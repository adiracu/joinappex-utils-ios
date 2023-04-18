import Foundation

public protocol BoxKey {
    var rawValue: String { get }

    init?(rawValue: String)
}

extension String: BoxKey {
    public var rawValue: String { self }

    public init?(rawValue: String) {
        self.init(rawValue)
    }
}

public protocol Storage {
    associatedtype Key

    var key: String { get }
    var type: BoxType { get }

    var allKeys: [Key] { get }

    func set(object: Any, forKey key: Key)
    func get(forKey key: Key) ->  Any?

    func delete(forKey key: Key)
    func clearStorage()
}

public extension Storage {
    func isExistObject(forKey key: Key) -> Bool {
        return get(forKey: key) != nil
    }

    func setIfNotExists(object: Any, forKey key: Key) {
        guard !isExistObject(forKey: key) else { return }
        set(object: object, forKey: key)
    }

    func set<T>(encodable value: T, forKey key: Key) where T: Encodable {
        do {
            let data = try JSONEncoder().encode(value)
            set(object: data, forKey: key)
        } catch {
            assertionFailure("Setting value for key \(key) failed with an error: \(error).")
        }
    }
    
    func get<T>(decodable type: T.Type, forKey key: Key) -> T? where T: Decodable {
        guard let data = get(forKey: key) as? Data else {
            return nil
        }
        let decodedValue = try? JSONDecoder().decode(T.self, from: data)
        return decodedValue
    }

    func get<T>(_ type: T.Type, forKey key: Key) -> T? {
        return get(forKey: key) as? T
    }

    func get<T>(_ type: T.Type, forKey key: Key, default value: T) -> T {
        guard let storedValue = get(forKey: key) as? T else {
            return value
        }
        return storedValue
    }

    func get<T>(_ type: T.Type, forKey key: Key, andSetDefault value: T) -> T {
        guard let storedValue = get(forKey: key) as? T else {
            set(object: value, forKey: key)
            return value
        }
        return storedValue
    }
}

public extension Storage {
    func getInt(forKey key: Key) -> Int? {
        get(forKey: key) as? Int
    }
    
    func getDouble(forKey key: Key) -> Double? {
        get(forKey: key) as? Double
    }
    
    func getFloat(forKey key: Key) -> Float? {
        get(forKey: key) as? Float
    }
    
    func getString(forKey key: Key) -> String? {
        get(forKey: key) as? String
    }
    
    func getBool(forKey key: Key) -> Bool {
        get(forKey: key) as? Bool ?? false
    }
    
    func getData(forKey key: Key) -> Data? {
        get(forKey: key) as? Data
    }
    
    func getUrl(forKey key: Key) -> URL? {
        get(forKey: key) as? URL
    }
    
    func getArray(forKey key: Key) -> [Any]? {
        get(forKey: key) as? [Any]
    }
    
    func getDictionary(forKey key: Key) -> [String : Any]? {
        get(forKey: key) as? [String : Any]
    }
}

