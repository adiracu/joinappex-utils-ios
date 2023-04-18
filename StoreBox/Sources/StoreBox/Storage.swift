import Foundation

public protocol BoxKey: RawRepresentable where RawValue == String { }

extension String: BoxKey {
    public var rawValue: String { self }

    public init?(rawValue: String) {
        self.init(rawValue)
    }
}

/// Storage is a main protocol implemented by ``Box``
public protocol Storage {
    associatedtype Key

    var key: String { get }
    var type: BoxType { get }

    var allKeys: [Key] { get }

    func set(_ value: Any, forKey key: Key)
    func get(forKey key: Key) ->  Any?
    func remove(forKey key: Key)

    func clearStorage()
}

public extension Storage {
    /// Checking if does value exist in the storage
    ///
    /// - Parameters:
    ///   - key: The key which will used to check value in the storage
    /// - Returns: `True` if value exist in the storage and `False` if not
    func valueExists(forKey key: Key) -> Bool {
        return get(forKey: key) != nil
    }

    /// Setting value by specified key it it not present in storage
    ///
    /// - Parameters:
    ///   - value: Any value to store
    ///   - key: The key which will used to check and store value
    func setIfDoesNotExist(_ value: Any, forKey key: Key) {
        guard !valueExists(forKey: key) else { return }
        set(value, forKey: key)
    }

    /// Setting ``Encodable`` object by specified key
    ///
    /// - Parameters:
    ///   - object: Any ``Encodable`` object to store
    ///   - key: The key which will used to store object
    func setEncodable<T>(_ object: T, forKey key: Key) where T: Encodable {
        do {
            let data = try JSONEncoder().encode(object)
            set(data, forKey: key)
        } catch {
            assertionFailure("Setting value for key \(key) failed with an error: \(error).")
        }
    }

    /// Getting ``Encodable`` object by specified key
    ///
    /// - Parameters:
    ///   - type: The Type of the value to decode
    ///   - key: The key which will used to get object
    /// - Returns: Decoded object if it present and decoded sucessfully
    func getDecodable<T>( type: T.Type, forKey key: Key) -> T? where T: Decodable {
        guard let data = get(forKey: key) as? Data else {
            return nil
        }
        let decodedValue = try? JSONDecoder().decode(T.self, from: data)
        return decodedValue
    }

    /// Getting value by specified key with casting to the specified type
    ///
    /// - Parameters:
    ///   - type: The Type of the value to cast `Any` value to specified `Type`
    ///   - key: Key which will used to get value
    /// - Returns: Value of specified type if it present and casted sucessfully
    func get<T>(_ type: T.Type, forKey key: Key) -> T? {
        return get(forKey: key) as? T
    }

    /// Getting value by specified key with casting to the specified type.
    /// If value does not exist the function will return value from `default` parameter
    ///
    /// - Parameters:
    ///   - type: The Type of the value to cast `Any` value to specified `Type`
    ///   - key: Key which will used to get value
    ///   - default: Default value which returns if get value by key unsuccessful
    /// - Returns: Value of specified type if it present and casted sucessfully or `default` value specified in parameters
    func get<T>(_ type: T.Type, forKey key: Key, default value: T) -> T {
        guard let storedValue = get(forKey: key) as? T else {
            return value
        }
        return storedValue
    }

    /// Getting value by specified key with casting to the specified type.
    /// If value does not exist the function will store `default` value and
    /// than return it
    ///
    /// - Parameters:
    ///   - type: The Type of the value to cast `Any` value to specified `Type`
    ///   - key: Key which will used to get value
    ///   - setDefaultIfDoesNotExist: Default value which using to store and then returns if get value by key unsuccessful
    /// - Returns: Value of specified type if it present and casted sucessfully or `default` value specified in parameters
    func get<T>(_ type: T.Type, forKey key: Key, setDefaultIfDoesNotExist value: T) -> T {
        guard let storedValue = get(forKey: key) as? T else {
            set(value, forKey: key)
            return value
        }
        return storedValue
    }
}

public extension Storage {
    /// Getting `Int` value by specified key or `0` if it does not exist
    ///
    /// - Parameters:
    ///   - key: Key which will used to get value
    /// - Returns: Stored `Int` value or `0` if it does not exist
    func int(forKey key: Key) -> Int {
        get(forKey: key) as? Int ?? 0
    }

    /// Getting `Double` value by specified key or `0` if it does not exist
    ///
    /// - Parameters:
    ///   - key: Key which will used to get value
    /// - Returns: Stored `Double` value or `0` if it does not exist
    func double(forKey key: Key) -> Double {
        get(forKey: key) as? Double ?? 0
    }

    /// Getting `Float` value by specified key or `0` if it does not exist
    ///
    /// - Parameters:
    ///   - key: Key which will used to get value
    /// - Returns: Stored `Float` value or `0` if it does not exist
    func float(forKey key: Key) -> Float {
        get(forKey: key) as? Float ?? 0
    }

    /// Getting `String` value by specified key
    ///
    /// - Parameters:
    ///   - key: Key which will used to get value
    /// - Returns: Stored `String` value or `nil` if it does not exist
    func string(forKey key: Key) -> String? {
        get(forKey: key) as? String
    }

    /// Getting `Bool` value by specified key or `false` if it does not exist
    ///
    /// - Parameters:
    ///   - key: Key which will used to get value
    /// - Returns: Stored `Bool` value or `false` if it does not exist
    func bool(forKey key: Key) -> Bool {
        get(forKey: key) as? Bool ?? false
    }

    /// Getting `Data` value by specified key
    ///
    /// - Parameters:
    ///   - key: Key which will used to get value
    /// - Returns: Stored `Data` value or `nil` if it does not exist
    func data(forKey key: Key) -> Data? {
        get(forKey: key) as? Data
    }

    /// Getting `URL` value by specified key
    ///
    /// - Parameters:
    ///   - key: Key which will used to get value
    /// - Returns: Stored `URL` value or `nil` if it does not exist
    func url(forKey key: Key) -> URL? {
        get(forKey: key) as? URL
    }

    /// Getting `Disctionary<String, Any>` value by specified key
    ///
    /// - Parameters:
    ///   - key: Key which will used to get value
    /// - Returns: Stored `Disctionary<String, Any>` value or `nil` if it does not exist
    func dictionary(forKey key: Key) -> [String : Any]? {
        get(forKey: key) as? [String : Any]
    }
}

