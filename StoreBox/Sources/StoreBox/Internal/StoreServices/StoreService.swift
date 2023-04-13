import Foundation

protocol StoreService {
    func save(value: Data, forKey key: String) throws
    func load(forKey key: String) throws -> Data
    func remove(forKey key: String) throws
}
