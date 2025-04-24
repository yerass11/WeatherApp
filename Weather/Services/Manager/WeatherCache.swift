import Foundation

class WeatherCache {
    static let shared = WeatherCache()
    
    private init() {}
    
    private var cache: [String: (data: Any, timestamp: Date)] = [:]
    
    func getCachedData<T>(for key: String, expiration: TimeInterval) -> T? {
        if let cached = cache[key] as? (data: T, timestamp: Date) {
            if Date().timeIntervalSince(cached.timestamp) < expiration {
                return cached.data
            } else {
                cache[key] = nil
            }
        }
        return nil
    }
    
    func setCachedData<T>(data: T, for key: String) {
        cache[key] = (data: data, timestamp: Date())
    }
}
