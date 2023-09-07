import Foundation
import UIKit

private typealias CacheType = [String: Any]

/// Box is storage for specified BoxKey
///
/// You can use Box as secure and insceure storage to save different types of data
///
///     enum MyKeys: String, BoxKeys {
///         case firstValueKey
///         case secondValueKey
///     }
///
///     let box = Box<MyKeys>.load(type: .secure)
///     box.set("some value", forKey: .firstValueKey)
///     box.set(100, forKey: .secondValueKey)
///
///     let firstValue = box.string(forKey: .firstValueKey)
///     let secondValue = box.int(forKey: .secondValueKey)
///     
public class Box<Key>: Storage where Key: BoxKey {
    private let storageQueue: DispatchQueue
    private var timer: Timer?

    private var storeService: StoreService
    private var cache: CacheType

    /// A key which used to load the box from common storage
    public let key: String
    /// Type of secure
    public let type: BoxType
    /// A number of all keys which stored in box
    public var allKeys: [Key] { cache.keys.compactMap { Key(rawValue: $0) } }

    init(key: String? = nil, type: BoxType, storeService: StoreService) {
        self.type = type
        self.storeService = storeService
        self.key = key ?? String(describing: Key.self)

        cache = .init()
        storageQueue = DispatchQueue(label: "StoreBox.\(self.key).storageQueue", qos: .userInitiated)

        loadStorage()

        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            self?.storageQueue.sync {
                self?.save()
            }
        }

        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            self?.storageQueue.sync {
                self?.save()
            }
        }
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
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: cache,
                                                            requiringSecureCoding: false)
            try storeService.save(value: data, forKey: key)
        } catch {
            assertionFailure("Box \(key) saving failed with an error: \(error).")
        }
    }

    private func scheduleSave() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            self.storageQueue.async { [self] in
                self.save()
            }
        }
    }

    /// Setting `Any` value by specified key
    ///
    /// - Parameters:
    ///   - value: Any value to store
    ///   - key: Key which will used to store value in the box
    public func set(_ value: Any, forKey key: Key) {
        storageQueue.sync { [self] in
            cache[key.rawValue] = value
            scheduleSave()
        }
    }

    /// Get `Any` value by specified key
    ///
    /// - Parameters:
    ///   - key: Key which will used to get value
    /// - Returns: Any value if present in the box by specified key or nil
    public func get(forKey key: Key) ->  Any? {
        return cache[key.rawValue]
    }

    /// Remove value in the box by specified key
    ///
    /// - Parameters:
    ///   - key: Key which will used to remove value
    public func remove(forKey key: Key) {
        storageQueue.sync {
            cache.removeValue(forKey: key.rawValue)
            scheduleSave()
        }
    }

    /// Remove `all` values in the box
    public func clearStorage() {
        storageQueue.sync {
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
                remove(forKey: key)
                return
            }
            set(newValue, forKey: key)
        }
    }
}
