import Foundation

private typealias CacheType = [String: Any]

public class Box<Key>: Storage where Key: BoxKey {
    private let storageQueue: DispatchQueue
    private let storeQueue: DispatchQueue

    private var storeService: StoreService
    private var cache: CacheType

    public let key: String
    public let type: BoxType
    public var allKeys: [Key] { cache.keys.compactMap { Key(rawValue: $0) } }

    init(key: String? = nil, type: BoxType, storeService: StoreService) {
        self.type = type
        self.storeService = storeService
        self.key = key ?? String(describing: Key.self)

        cache = .init()
        storageQueue = DispatchQueue(label: "StoreBox.\(self.key).storageQueue", qos: .userInitiated)
        storeQueue = DispatchQueue(label: "StoreBox.\(self.key).storeQueue", qos: .userInitiated)

        loadStorage()
    }

    private func loadStorage() {
        do {
            let data = try storeService.load(forKey: key)

            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = false
            let decodedCache = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? CacheType

            cache = decodedCache ?? [:]
        } catch {
            cache = [:]
        }
    }

    private func save() {
        storageQueue.async { [self] in
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: cache,
                                                                requiringSecureCoding: false)
                try storeService.save(value: data, forKey: key)
            } catch {
                assertionFailure("Box \(key) saving failed with an error: \(error).")
            }
        }
    }

    public func set(object: Any, forKey key: Key) {
        storeQueue.sync { [self] in
            cache[key.rawValue] = object
            save()
        }
    }

    public func get(forKey key: Key) ->  Any? {
        return cache[key.rawValue]
    }

    public func delete(forKey key: Key) {
        storeQueue.sync {
            cache.removeValue(forKey: key.rawValue)
            save()
        }
    }

    public func clearStorage() {
        storeQueue.sync {
            do {
                try storeService.remove(forKey: key)
                cache.removeAll()
            } catch {
                assertionFailure("Box wasn't clear.")
            }
        }
    }

    public subscript(key: Key) -> Any? {
        get { get(forKey: key) }
        set {
            guard let newValue else {
                delete(forKey: key)
                return
            }
            set(object: newValue, forKey: key)
        }
    }
}
